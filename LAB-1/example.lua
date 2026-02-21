local generator = require "LAB-1/generators" -- Путь стоит из-за переноса проекта в игру
local status = nil

function main()
    sampRegisterChatCommand("test", function()
        if not status then
            status = generator.fibonacci()
        else
            status = nil
        end
    end)
    while true do
        wait(500)
        if status then sampAddChatMessage("Финабоччи:"..status(), -1) end
    end
end