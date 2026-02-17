-- Lib:
local imgui = require 'mimgui'

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local faicons = require('fAwesome6')


local tab = imgui.new.int(1)
local tabs = {
    {icon = faicons('CLIPBOARD_LIST'), text = "NRP Nick"},
    {icon = faicons('COMPUTER_MOUSE_SCROLLWHEEL'), text = "Click Warp"},
    {icon = faicons('CIRCLE_PLUS'), text = "Auto Heal"},
    {icon = faicons('WINDOW_MAXIMIZE'), text = "Info Window"},
    {icon = faicons('EYE'), text = "Wall Hack"},
    {icon = faicons('GHOST'), text = "Invisible"},
    {icon = faicons('BULLSEYE_ARROW'), text = "Tracer"},
    {icon = faicons('EYE_SLASH'), text = "Hide Chat"}
}


local menu_items = {
    {icon = faicons('CLIPBOARD_LIST'), text = "NRP Nick"},
    {icon = faicons('COMPUTER_MOUSE_SCROLLWHEEL'), text = "Click Warp"},
    {icon = faicons('CIRCLE_PLUS'), text = "Auto Heal"},
    {icon = faicons('WINDOW_MAXIMIZE'), text = "Info Window"},
    {icon = faicons('EYE'), text = "Wall Hack"},
    {icon = faicons('GHOST'), text = "Invisible"},
    {icon = faicons('BULLSEYE_ARROW'), text = "Tracer"},
    {icon = faicons('EYE_SLASH'), text = "Hide Chat"}
}

local current_item = 1

local new = imgui.new

local wMain = new.bool(true)
local sizeX, sizeY = getScreenResolution()

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local style = imgui.GetStyle()
    local colors = style.Colors
    theme()
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('light'), 14, config, iconRanges) -- solid - тип иконок, так же есть thin, regular, light и duotone
end)

local newFrame = imgui.OnFrame(function() return wMain[0] end, function(player)
       imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
       imgui.SetNextWindowSize(imgui.ImVec2(700, 400), imgui.Cond.FirstUseEver)

  --     imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
       imgui.Begin("##WM", wMain, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)
  --      imgui.SetCursorPos(imgui.ImVec2(0, 58))
  --      imgui.BeginChild('Name', imgui.ImVec2(148, 0), true)
  --      imgui.PushStyleVarVec2(imgui.StyleVar.SelectableTextAlign, imgui.ImVec2(0.2, 0.5))
  ---      for i = 1, #menu_items do
  --          if imgui.Selectable(menu_items[i].icon.."   "..u8(menu_items[i].text), current_item == i, 0, imgui.ImVec2(148, 38)) then
  ---              current_item = i
  --          end
       -- end
        --imgui.PopStyleVar(2)
        ---imgui.EndChild()

        imgui.SetCursorPos(imgui.ImVec2(-2, 25))
        imgui.CustomMenu(tabs, tab, imgui.ImVec2(200, 40))
        imgui.End()
    end)

function main()
    wait(-1)
end

function imgui.CustomMenu(items, selected, size, speed, centering)
    local bool = false
    speed = speed or 0.2
    local radius = size.y * 0.50
    local draw_list = imgui.GetWindowDrawList()
    if LastActiveTime == nil then LastActiveTime = {} end
    if LastActive == nil then LastActive = {} end
    local function ImSaturate(f)
        return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
    end

    for i, item in ipairs(items) do
        local c = imgui.GetCursorPos()
        local p = imgui.GetCursorScreenPos()
        if imgui.InvisibleButton(item.text..'##'..i, size) then
            selected[0] = i
            LastActiveTime[item.text] = os.clock()
            LastActive[item.text] = true
            bool = true
        end
        imgui.SetCursorPos(c)

        local t = selected[0] == i and 1.0 or 0.0
        if LastActive[item.text] then
            local time = os.clock() - LastActiveTime[item.text]
            if time <= 0.3 then
                local t_anim = ImSaturate(time / speed)
                t = selected[0] == i and t_anim or 1.0 - t_anim
            else
                LastActive[item.text] = false
            end
        end

        local col_bg = imgui.GetColorU32Vec4(selected[0] == i and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImVec4(0,0,0,0))
        local col_box = imgui.GetColorU32Vec4(selected[0] == i and imgui.ImVec4(1.00, 0.50, 1.00, 0.50) or imgui.ImVec4(0,0,0,0))
        local col_hovered = imgui.GetStyle().Colors[imgui.Col.ButtonHovered]
        local col_hovered = imgui.GetColorU32Vec4(imgui.ImVec4(col_hovered.x, col_hovered.y, col_hovered.z, (imgui.IsItemHovered() and 0.2 or 0)))

        draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/6, p.y), imgui.ImVec2(p.x + (radius * 0.65) + t * size.x, p.y + size.y), col_bg, 0)
        draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/6, p.y), imgui.ImVec2(p.x + (radius * 0.65) + size.x, p.y + size.y), col_hovered, 0)
        draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x+10, p.y + size.y), col_box)

        -- Центрування іконки
        local icon_size = imgui.CalcTextSize(item.icon)
        imgui.SetCursorPos(imgui.ImVec2(c.x + 10, c.y + (size.y - icon_size.y) / 2))
        imgui.Text(item.icon)

        -- Текст з відступом справа
        local text_size = imgui.CalcTextSize(item.text)
        imgui.SameLine()
        imgui.SetCursorPos(imgui.ImVec2(c.x + 40, c.y + (size.y - text_size.y) / 2))
        imgui.Text(item.text)

        imgui.SetCursorPos(imgui.ImVec2(c.x, c.y+size.y))
    end
    return bool
end



function theme()
    imgui.SwitchContext()
    local ImVec4 = imgui.ImVec4
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1

    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1
    imgui.GetStyle().WindowRounding = 8
    imgui.GetStyle().ChildRounding = 8
    imgui.GetStyle().FrameRounding = 8
    imgui.GetStyle().PopupRounding = 8
    imgui.GetStyle().ScrollbarRounding = 8
    imgui.GetStyle().GrabRounding = 8
    imgui.GetStyle().TabRounding = 8

    imgui.GetStyle().Colors[imgui.Col.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 0.43);
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 0.90);
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = ImVec4(1.00, 1.00, 1.00, 0.07);
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 0.94);
    imgui.GetStyle().Colors[imgui.Col.Border]                 = ImVec4(1.00, 1.00, 1.00, 0.00);
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = ImVec4(1.00, 0.00, 0.00, 0.32);
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.09);
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = ImVec4(1.00, 1.00, 1.00, 0.17);
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = ImVec4(1.00, 1.00, 1.00, 0.26);
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = ImVec4(0.19, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = ImVec4(0.46, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = ImVec4(0.20, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = ImVec4(0.14, 0.03, 0.03, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = ImVec4(0.19, 0.00, 0.00, 0.53);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.11);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.24);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = ImVec4(1.00, 1.00, 1.00, 0.35);
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = ImVec4(1.00, 0.00, 0.00, 0.34);
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = ImVec4(1.00, 0.00, 0.00, 0.51);
    imgui.GetStyle().Colors[imgui.Col.Button]                 = ImVec4(1.00, 0.00, 0.00, 0.19);
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = ImVec4(1.00, 0.00, 0.00, 0.31);
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = ImVec4(1.00, 0.00, 0.00, 0.46);
    imgui.GetStyle().Colors[imgui.Col.Header]                 = ImVec4(1.00, 0.00, 0.00, 0.19);
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = ImVec4(1.00, 0.00, 0.00, 0.30);
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = ImVec4(1.00, 0.00, 0.00, 0.50);
    imgui.GetStyle().Colors[imgui.Col.Separator]              = ImVec4(1.00, 0.00, 0.00, 0.41);
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.78);
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = ImVec4(0.19, 0.00, 0.00, 0.53);
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = ImVec4(0.43, 0.00, 0.00, 0.75);
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = ImVec4(0.53, 0.00, 0.00, 0.95);
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = ImVec4(1.00, 0.00, 0.00, 0.27);
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = ImVec4(1.00, 0.00, 0.00, 0.48);
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = ImVec4(1.00, 0.00, 0.00, 0.60);
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = ImVec4(1.00, 0.00, 0.00, 0.27);
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = ImVec4(1.00, 0.00, 0.00, 0.54);
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35);
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = ImVec4(1.00, 1.00, 0.00, 0.90);
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = ImVec4(0.26, 0.59, 0.98, 1.00);
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = ImVec4(1.00, 1.00, 1.00, 0.70);
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = ImVec4(0.80, 0.80, 0.80, 0.20);
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = ImVec4(0.80, 0.80, 0.80, 0.35);
end