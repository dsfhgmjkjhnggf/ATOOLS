-- Lib:
local imgui = require 'mimgui'

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local menu_items = {
    'NRP Nick',
    'Click Warp',
    'Auto Heal',
    'Info Window',
    'Wall Hack',
    'Invisible',
    'Tracer'
}

local current_item = 1

local new = imgui.new

local wMain = new.bool(true)
local sizeX, sizeY = getScreenResolution()

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local style = imgui.GetStyle()
    local colors = style.Colors
end)

local newFrame = imgui.OnFrame(function() return wMain[0] end, function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(700, 400), imgui.Cond.FirstUseEver)

        imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
        imgui.Begin("##WM", wMain, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)
        imgui.SetCursorPos(imgui.ImVec2(0, 42))
        imgui.BeginChild('Name', imgui.ImVec2(148, 0), true)
        imgui.PushStyleVarVec2(imgui.StyleVar.SelectableTextAlign, imgui.ImVec2(0.1, 0.5))
        for i = 1, #menu_items do
            if imgui.Selectable(u8(menu_items[i]), current_item == i, 0, imgui.ImVec2(148, 38)) then
                current_item = i
            end
        end
        imgui.PopStyleVar(2)
        imgui.EndChild()
        imgui.End()
    end)

function main()
    wait(-1)
end