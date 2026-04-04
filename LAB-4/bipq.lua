local bipq = {}
function bipq.new()
    local pq = {}
    pq._data = {}
    pq._counter = 0
    local function find_entry(data, mode)
        if #data == 0 then return nil, nil end
        local result_idx = 1
        local result = data[1]
        for idx, entry in ipairs(data) do
            if mode == "highest" and entry.priority > result.priority then
                result = entry
                result_idx = idx
            elseif mode == "lowest" and entry.priority < result.priority then
                result = entry
                result_idx = idx
            elseif mode == "oldest" and entry.order < result.order then
                result = entry
                result_idx = idx
            elseif mode == "newest" and entry.order > result.order then
                result = entry
                result_idx = idx
            end
        end

        return result, result_idx
    end
    function pq:enqueue(item, priority)
        self._counter = self._counter + 1
        table.insert(self._data, {
            item = item,
            priority = priority,
            order = self._counter
        })
    end
    function pq:peek(mode)
        local entry = find_entry(self._data, mode)
        if not entry then return nil end
        return entry.item, entry.priority, entry.order
    end
    function pq:dequeue(mode)
        local entry, idx = find_entry(self._data, mode)
        if not entry then return nil end
        table.remove(self._data, idx)
        return entry.item, entry.priority, entry.order
    end
    function pq:size()
        return #self._data
    end
    function pq:isEmpty()
        return #self._data == 0
    end
    return pq
end
return bipq