local G = {}
function G.fibonacci()
    local a, b = 0, 1
    return function()
        local val = a
        a, b = b, a + b
        return val
    end
end

function G.random(a, b)
    math.randomseed(os.time())
    return function()
        return math.random(a, b)
    end
end

function G.round_robin(list)
    local index = 1
    return function()
        local val = list[index]
        index = index + 1
        if index > #list then
            index = 1
        end
        return val
    end
end

function G.counter_generator(start, step)
    local val = (start or 0) - (step or 1)
    return function()
        val = val + (step or 1)
        return val
    end
end

local Charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
function G.random_string(min_len, max_len)
    return function()
        local len = math.random(min_len, max_len)
        local s = {}
        for i = 1, len do
            local index = math.random(1, #Charset)
            s[i] = Charset:sub(index, index)
        end
        return table.concat(s)
    end
end
return G