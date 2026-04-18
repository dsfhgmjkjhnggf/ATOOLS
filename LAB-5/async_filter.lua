local async_filter = {}
function async_filter.newAbortToken()
    local token = {}
    token.aborted = false
    function token:abort()
        self.aborted = true
    end
    return token
end
function async_filter.filter(arr, predicate)
    local result = {}
    for i, v in ipairs(arr) do
        if predicate(v, i) then
            table.insert(result, v)
        end
    end
    return result
end
function async_filter.filterCallback(arr, predicate, callback, token)
    local co = coroutine.create(function()
        local result = {}
        for i, v in ipairs(arr) do
            if token and token.aborted then
                callback("aborted", nil)
                return
            end
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
    local _resolve_val, _reject_val
    local _resolved, _rejected = false, false
    local _then_cb, _catch_cb
    function promise:andThen(cb)
        _then_cb = cb
        if _resolved then cb(_resolve_val) end
        return self
    end
    function promise:catch(cb)
        _catch_cb = cb
        if _rejected then cb(_reject_val) end
        return self
    end
    local function resolve(value)
        _resolved = true
        _resolve_val = value
        if _then_cb then _then_cb(value) end
    end
    local function reject(err)
        _rejected = true
        _reject_val = err
        if _catch_cb then _catch_cb(err) end
    end
    fn(resolve, reject)
    return promise
end
function async_filter.filterPromise(arr, predicate, token)
    return newPromise(function(resolve, reject)
        async_filter.filterCallback(arr, predicate, function(err, result)
            if err then
                reject(err)
            else
                resolve(result)
            end
        end, token)
    end)
end
return async_filter