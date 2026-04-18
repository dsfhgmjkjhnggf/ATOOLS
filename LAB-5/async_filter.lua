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
function async_filter.filterCallback(arr, predicate, callback)
    local co = coroutine.create(function()
        local result = {}
        for i, v in ipairs(arr) do
            local ok = predicate(v, i)
            coroutine.yield()
            if ok then
                table.insert(result, v)
            end
        end
        callback(nil, result)
    end)
    local function step()
        local ok, err = coroutine.resume(co)
        if not ok then
            callback(err, nil)
        end
    end
    step()
    while coroutine.status(co) == "suspended" do
        step()
    end
end
return async_filter