local bipq = {}
function bipq.new()
    local pq = {}
    pq._data = {}
    pq._counter = 0

    function pq:enqueue(item, priority)
        self._counter = self._counter + 1
        table.insert(self._data, {
            item = item,
            priority = priority,
            order = self._counter
        })
    end
    function pq:peek(mode)
        if #self._data == 0 then return nil end
        local result = self._data[1]
        for _, entry in ipairs(self._data) do
            if mode == "highest" and entry.priority > result.priority then
                result = entry
            elseif mode == "lowest" and entry.priority < result.priority then
                result = entry
            elseif mode == "oldest" and entry.order < result.order then
                result = entry
            elseif mode == "newest" and entry.order > result.order then
                result = entry
            end
        end
        return result.item, result.priority, result.order
    end
    function pq:dequeue(mode)
        if #self._data == 0 then return nil end
        local result_idx = 1
        local result = self._data[1]
        for idx, entry in ipairs(self._data) do
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
        table.remove(self._data, result_idx)
        return result.item, result.priority, result.order
    end
    return pq
end
return bipq