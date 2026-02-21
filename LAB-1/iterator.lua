local G = require "LAB-1/generators"
local iterator = {}
function iterator.timeout_iterator(iter, timeout, callback)
    local start = os.clock()
    local count = 0
    local sum = 0
    while true do
        local elapsed = os.clock() - start
        if elapsed >= timeout then break end

        local value = iter()
        count = count + 1

        if type(value) == "number" then
            sum = sum + value
            local avg = sum / count
            if callback then
                callback(value, count, sum, avg, elapsed)
            end
        else
            if callback then
                callback(value, count, nil, nil, elapsed)
            end
        end
    end
    return count, sum
end
return iterator