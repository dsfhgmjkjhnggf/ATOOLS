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
return G