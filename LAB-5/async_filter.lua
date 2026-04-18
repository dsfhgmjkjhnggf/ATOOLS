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
local function newPromise(fn)
    local promise = {}
    local _resolve, _reject
    local _then_cb, _catch_cb
    function promise:andThen(cb)
        _then_cb = cb
        return self
    end
    function promise:catch(cb)
        _catch_cb = cb
        return self
    end
    _resolve = function(value)
        if _then_cb then _then_cb(value) end
    end
    _reject = function(err)
        if _catch_cb then _catch_cb(err) end
    end
    fn(_resolve, _reject)
    return promise
end

function async_filter.filterPromise(arr, predicate)
    return newPromise(function(resolve, reject)
        async_filter.filterCallback(arr, predicate, function(err, result)
            if err then
                reject(err)
            else
                resolve(result)
            end
        end)
    end)
end
return async_filter