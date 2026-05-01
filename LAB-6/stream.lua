local stream = {}
local function newStream(producer)
    return {
        _producer = producer
    }
end
function stream.from(source)
    if type(source) == "table" then
        local co = coroutine.create(function()
            for i, v in ipairs(source) do
                coroutine.yield(v, i)
            end
        end)
        return newStream(function()
            if coroutine.status(co) == "dead" then return nil end
            local ok, value, index = coroutine.resume(co)
            if not ok or value == nil then return nil end
            return value, index
        end)
    elseif type(source) == "function" then
        return newStream(source)
    end
end
function stream.next(s)
    return s._producer()
end
return stream