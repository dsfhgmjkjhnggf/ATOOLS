local stream = require("LAB-6/stream")
local bigData = {}
for i = 1, 10000 do
    bigData[i] = {
        id = i,
        name = "Player_" .. i,
        dist = math.random(1, 500),
        hp = math.random(1, 100)
    }
end

local result = stream.collect(
    stream.take(
        stream.map(
            stream.filter(
                stream.from(bigData),
                function(p) return p.dist < 100 and p.hp < 50 end
            ),
            function(p) return p.name .. " | dist:" .. p.dist .. " hp:" .. p.hp end
        ),
        5
    )
)
for _, v in ipairs(result) do
    print(v)
end

local page2 = stream.collect(
    stream.take(
        stream.skip(stream.from(bigData), 10),
        10
    )
)
print("2:", #page2, "елементів")

-- Demo 3: forEach без collect — не завантажує в пам'ять
local count = 0
stream.forEach(
    stream.filter(stream.from(bigData), function(p) return p.hp == 100 end),
    function(p)
        count = count + 1
    end
)
print("Player full HP:", count)

-- Demo 4: генератор як джерело (нескінченний стрім)
local function infiniteNumbers()
    local n = 0
    return function()
        n = n + 1
        return n
    end
end

local first10even = stream.collect(
    stream.take(
        stream.filter(
            stream.from(infiniteNumbers()),
            function(n) return n % 2 == 0 end
        ),
        10
    )
)
print("Первые 10 парных:", table.concat(first10even, ", "))