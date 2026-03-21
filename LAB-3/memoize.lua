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
function memoize.new(fn, options)
    options = options or {}
    local max_size = options.max_size
    local cache = {}
    return function(...)
        local args = {...}
        local key = make_key(args)
        if cache[key] ~= nil then
            return cache[key]
        end
        if max_size and get_size(cache) >= max_size then
            return fn(...)
        end
        local result = fn(...)
        cache[key] = result
        return result
    end
end
return m