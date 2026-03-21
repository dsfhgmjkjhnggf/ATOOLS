local m = {}
local function make_key(args)
    local parts = {}
    for i = 1, #args do
        parts[i] = tostring(args[i])
    end
    return table.concat(parts, "|")
end
function memoize.new(fn)
    local cache = {}
    return function(...)
        local args = {...}
        local key = make_key(args)
        if cache[key] ~= nil then
            return cache[key]
        end
        local result = fn(...)
        cache[key] = result
        return result
    end
end
return m