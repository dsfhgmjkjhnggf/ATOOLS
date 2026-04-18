local async_filter = {}
function async_filter.filter(arr, predicate)
    local result = {}
    for i, v in ipairs(arr) do
        if predicate(v, i) then
            table.insert(result, v)
        end
    end
    return result
end
return async_filter