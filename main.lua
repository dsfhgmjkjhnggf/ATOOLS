-- Lib:
local imgui = require 'mimgui'

local new = imgui.new

local wMain = new.bool(true)
local sizeX, sizeY = getScreenResolution()

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
end)

local newFrame = imgui.OnFrame(
    function() return wMain[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(200, 150), imgui.Cond.FirstUseEver)
        imgui.Begin("Main Window", wMain)
        imgui.End()
    end
)

function main()
    wait(-1)
end