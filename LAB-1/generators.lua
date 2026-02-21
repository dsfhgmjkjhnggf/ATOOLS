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
return G