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

    return pq
end
return bipq