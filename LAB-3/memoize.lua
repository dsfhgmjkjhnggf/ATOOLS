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
    for k, m in pairs(meta) do
        if m.last_used < oldest_time then
            oldest_time = m.last_used
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
    for k, m in pairs(meta) do
        if m.freq < min_freq then
            min_freq = m.freq
            min_key = k
        end
    end
    if min_key then
        cache[min_key] = nil
        meta[min_key] = nil
    end
end
function memoize.new(fn, options)
    options = options or {}
    local max_size = options.max_size
    local policy = options.policy or "lru"
    local cache = {}
    local meta = {}
    local clock = 0
    return function(...)
        local args = {...}
        local key = make_key(args)
        clock = clock + 1
        if cache[key] ~= nil then
            if meta[key] then
                meta[key].last_used = clock
                meta[key].freq = meta[key].freq + 1
            end
            return cache[key]
        end
        if max_size and get_size(cache) >= max_size then
            if policy == "lru" then
                evict_lru(cache, meta)
            elseif policy == "lfu" then
                evict_lfu(cache, meta)
            end
        end
        local result = fn(...)
        cache[key] = result
        meta[key] = { last_used = clock, freq = 1 }
        return result
    end
end
return m