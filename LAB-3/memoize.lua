local m = {}
local function make_key(args)
    local parts = {}
    for i = 1, #args do
        parts[i] = tostring(args[i])
    end
    return table.concat(parts, "|")
end
local function get_size(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end
local function evict_lru(cache, meta)
    local oldest_key = nil
    local oldest_time = math.huge
    for k, v in pairs(meta) do
        if v.last_used < oldest_time then
            oldest_time = v.last_used
            oldest_key = k
        end
    end
    if oldest_key then
        cache[oldest_key] = nil
        meta[oldest_key] = nil
    end
end
local function evict_lfu(cache, meta)
    local min_key = nil
    local min_freq = math.huge
    for k, v in pairs(meta) do
        if v.freq < min_freq then
            min_freq = v.freq
            min_key = k
        end
    end
    if min_key then
        cache[min_key] = nil
        meta[min_key] = nil
    end
end
local function cleanup_expired(cache, meta, ttl)
    local now = os.time()
    for k, v in pairs(meta) do
        if now - v.created_at >= ttl then
            cache[k] = nil
            meta[k] = nil
        end
    end
end
function m.new(fn, options)
    options = options or {}
    local max_size = options.max_size
    local policy = options.policy or "lru"
    local ttl = options.ttl
    local cache = {}
    local meta = {}
    local clock = 0
    local hits = 0
    local misses = 0
    local function do_evict()
        if type(policy) == "function" then
            policy(cache, meta)
        elseif policy == "lru" then
            evict_lru(cache, meta)
        elseif policy == "lfu" then
            evict_lfu(cache, meta)
        end
    end
    local memoized = {}
    memoized.call = function(...)
        local args = {...}
        local key = make_key(args)
        clock = clock + 1
        if ttl then
            cleanup_expired(cache, meta, ttl)
        end
        if cache[key] ~= nil then
            hits = hits + 1
            if meta[key] then
                meta[key].last_used = clock
                meta[key].freq = meta[key].freq + 1
            end
            return table.unpack(cache[key])
        end
        misses = misses + 1
        if max_size and get_size(cache) >= max_size then
            do_evict()
        end
        local results = {fn(...)}
        cache[key] = results
        meta[key] = { last_used = clock, freq = 1, created_at = os.time() }
        return table.unpack(results)
    end
    memoized.stats = function()
        return {
            size = get_size(cache),
            hits = hits,
            misses = misses,
            policy = type(policy) == "function" and "custom" or policy,
            max_size = max_size or "unlimited",
            ttl = ttl or "none"
        }
    end
    memoized.clear = function()
        for k in pairs(cache) do cache[k] = nil end
        for k in pairs(meta) do meta[k] = nil end
        hits = 0
        misses = 0
        clock = 0
    end
    setmetatable(memoized, {
        __call = function(_, ...)
            return memoized.call(...)
        end
    })
    return memoized
end
return m