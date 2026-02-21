local generator = require "LAB-1/generators"
local gen_fibonacci = nil
local gen_random = nil
local gen_round_robin = nil
local counter_generator = nil
local random_string = nil
local day_round_robin = nil
local day_list = {"Понеділок", "Вівторок", "Середа", "Четверг", "П'ятниця", "Субота", "Недаля"}

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

    sampRegisterChatCommand("gen-4", function(arg)
        if not counter_generator then
            local arg1, arg2 = arg:match("^(%S+)%s+(%S+)$")
            if not arg1 or not arg2 then
                sampAddChatMessage("/gen-4 [Начальное] [Шаг]", -1)
                return
            end
            counter_generator = generator.counter_generator(arg1, arg2)
        else counter_generator = nil end
    end)
    sampRegisterChatCommand("gen-5", function(arg)
        if not random_string then
            local arg1, arg2 = arg:match("^(%S+)%s+(%S+)$")
            if not arg1 or not arg2 then
                sampAddChatMessage("/gen-5 [Мин. длина] [Макс. длина]", -1)
                return
            end
            random_string = generator.random_string(arg1, arg2)
        else random_string = nil end
    end)
    sampRegisterChatCommand("gen-6", function() if not day_round_robin then day_round_robin = generator.round_robin(day_list) else day_round_robin = nil end end)
    while true do
        wait(500)
        if gen_fibonacci then sampAddChatMessage("Финабоччи:"..gen_fibonacci(), -1) end
        if gen_random then sampAddChatMessage("Рандом: "..gen_random(), -1) end
        if gen_round_robin then sampAddChatMessage("round_robin лист: "..gen_round_robin(), -1) end
        if counter_generator then sampAddChatMessage("Счетчик "..counter_generator(), -1) end
        if random_string then sampAddChatMessage("Строка "..random_string(), -1) end
        if day_round_robin then sampAddChatMessage("День неділі:  "..day_round_robin(), -1) end
    end
end