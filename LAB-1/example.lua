local generator = require "LAB-1/generators"
local gen_fibonacci = nil
local gen_random = nil
local gen_round_robin = nil

function main()
    sampRegisterChatCommand("gen-1", function() if not gen_fibonacci then gen_fibonacci = generator.fibonacci() else gen_fibonacci = nil end end)

    sampRegisterChatCommand("gen-2", function(arg)
        if not gen_random then
            local arg1, arg2 = arg:match("^(%S+)%s+(%S+)$")
            if not arg1 or not arg2 then
                sampAddChatMessage("/gen-2 [От] [До]", -1)
                return
            end
            sampAddChatMessage("Рандом от "..arg1.." до "..arg2, -1)
            gen_random = generator.random(arg1, arg2)
        else gen_random = nil end
    end)

    sampRegisterChatCommand("gen-3", function(arg)
        if not gen_round_robin then
            if #arg == 0 then sampAddChatMessage("/gen-3 [Cписок]", -1) return end
            local list = {}
            for word in arg:gmatch("%S+") do
                table.insert(list, word)
            end
            gen_round_robin = generator.round_robin(list)
        else gen_round_robin = nil end
    end)

    while true do
        wait(500)
        if gen_fibonacci then sampAddChatMessage("Финабоччи:"..gen_fibonacci(), -1) end
        if gen_random then sampAddChatMessage("Рандом: "..gen_random(), -1) end
        if gen_round_robin then sampAddChatMessage("round_robin лист: "..gen_round_robin(), -1) end
    end
end