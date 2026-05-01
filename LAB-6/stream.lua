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
            if not ok then
                error("Stream producer error: " .. tostring(value))
            end
            if value == nil then return nil end
            return value, index
        end)
    elseif type(source) == "function" then
        return newStream(function()
            local ok, value, index = pcall(source)
            if not ok then
                error("Stream producer error: " .. tostring(value))
            end
            return value, index
        end)
    end
end
function stream.next(s)
    return s._producer()
end
function stream.map(s, fn)
    return newStream(function()
        local value, index = s._producer()
        if value == nil then return nil end
        local ok, result = pcall(fn, value, index)
        if not ok then
            error("Stream map error: " .. tostring(result))
        end
        return result, index
    end)
end

function stream.filter(s, predicate, token)
    return newStream(function()
        while true do
            if token and token.aborted then return nil end
            local value, index = s._producer()
            if value == nil then return nil end
            local ok, result = pcall(predicate, value, index)
            if not ok then
                error("Stream filter error: " .. tostring(result))
            end
            if result then
                return value, index
            end
        end
    end)
end
function stream.take(s, n)
    local count = 0
    return newStream(function()
        if count >= n then return nil end
        local value, index = s._producer()
        if value == nil then return nil end
        count = count + 1
        return value, index
    end)
end
function stream.skip(s, n)
    local skipped = false
    return newStream(function()
        if not skipped then
            skipped = true
            for _ = 1, n do
                local value = s._producer()
                if value == nil then return nil end
            end
        end
        return s._producer()
    end)
end

function stream.forEach(s, fn, token)
    while true do
        if token and token.aborted then break end
        local ok, value, index = pcall(s._producer)
        if not ok then
            error("Stream forEach error: " .. tostring(value))
        end
        if value == nil then break end
        local ok2, err = pcall(fn, value, index)
        if not ok2 then
            error("Stream forEach callback error: " .. tostring(err))
        end
    end
end

function stream.collect(s)
    local result = {}
    stream.forEach(s, function(value)
        table.insert(result, value)
    end)
    return result
end
return stream