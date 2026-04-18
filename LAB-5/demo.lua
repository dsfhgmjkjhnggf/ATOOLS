local async_filter = require("LAB-5/async_filter")

local players = {
    {name = "Player 1", dist = 15, hp = 80},
    {name = "Player 2", dist = 150, hp = 30},
    {name = "Player 3", dist = 50, hp = 100},
    {name = "Player 4", dist = 200, hp = 10},
    {name = "Player 5", dist = 30, hp = 60},
}

local near = async_filter.filter(players, function(p)
    return p.dist < 100
end)
print("Синхронно близкие:")
for _, p in ipairs(near) do print(p.name, p.dist) end


async_filter.filterCallback(players, function(p)
    return p.hp < 50
end, function(err, result)
    if err then print("Ошибка:", err) return end
    print("Callback — низкое HP:")
    for _, p in ipairs(result) do print(p.name, p.hp) end
end)


async_filter.filterPromise(players, function(p)
    return p.dist < 100
end):andThen(function(result)
    print("{Promise] близкие:")
    for _, p in ipairs(result) do print(p.name, p.dist) end
end):catch(function(err)
    print("[Promise] ошибка:", err)
end)


local token = async_filter.newAbortToken()
token:abort()

async_filter.filterPromise(players, function(p)
    return p.dist < 100
end, token):andThen(function(result)
    print("Не должно выполниться")
end):catch(function(err)
    print("Отменено:", err)
end)