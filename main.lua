local imgui = require 'mimgui'
local new = imgui.new

local faicons = require('fAwesome6')
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local wMain = new.bool(true)
local sizeX, sizeY = getScreenResolution()

local ffi = require('ffi') 
local getbonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

local mem = require "memory"

-- Текст меню
local tab = imgui.new.int(1)
local tabs = {
    faicons('CLIPBOARD_LIST')            .. u8' NRP Nick',
    faicons('COMPUTER_MOUSE_SCROLLWHEEL').. u8' Click Warp',
    faicons('CIRCLE_PLUS')               .. u8' Auto Heal',
    faicons('WINDOW_MAXIMIZE')           .. u8' Info Window',
    faicons('EYE')                       .. u8' Wall Hack',
    faicons('GHOST')                     .. u8' Invisible',
    faicons('BULLSEYE_ARROW')            .. u8' Tracer',
    faicons('EYE_SLASH')                 .. u8' Hide Chat',
}

-- Линии
local Lines_Active = new.bool(true)
local Lines_Color = new.float[4](1.0, 1.0, 1.0, 1.0)
local Lines_Thickness = new.int(1)

---- Кости
local Bones_Active = new.bool(true)
local Bones_Color = new.float[4](1.0, 1.0, 1.0, 1.0)
local Bones_Thickness = new.int(1)

---- Концы костей
local BoneEnds_Color = new.float[4](1.0, 1.0, 1.0, 1.0)
local BoneEnds_Active = new.bool(true)
local BoneEnds_Type = new.int()
local BoneEnds_TypeList = {u8'Квадрат', u8'Круг', u8'Треугольник', u8'Пятиугольник'}
local ImItems = imgui.new['const char*'][#BoneEnds_TypeList](BoneEnds_TypeList)
local BoneEnds_Size = new.int(15)
local BoneEnds_Rotation = new.int(0)
local BoneEnds_SizeDynamic = new.bool(true)

-- Теги
local Tag_Active = new.bool(false)
local Tag_VisibilityWall = new.bool(false)
local Tag_VisibilityDistance = new.float()
local VisibilityWall = 0

local newFrame = imgui.OnFrame(function() return wMain[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(700, 400), imgui.Cond.FirstUseEver)
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
    imgui.Begin("##WM", wMain, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)

    -- Боковое меню
    imgui.SetCursorPos(imgui.ImVec2(0, 25))
    imgui.CustomMenu(tabs, tab, imgui.ImVec2(120, 40))

    -- Чилд 
    imgui.SetCursorPos(imgui.ImVec2(160, 50))
    imgui.BeginChild('Name', imgui.ImVec2(525, 300), true)
        -- Кости
        imgui.SetCursorPos(imgui.ImVec2(10, 10))
        imgui.Checkbox(u8'Кости', Bones_Active)
        imgui.SetCursorPos(imgui.ImVec2(30, 40))
        imgui.ColorEdit4(u8("Цвет##Color_Bones"), Bones_Color, imgui.ColorEditFlags.NoInputs)
        imgui.SameLine()
        imgui.PushItemWidth(35)
        imgui.DragInt(u8'Толщина##Bones_Thickness', Bones_Thickness, 0, 1, 3)
        imgui.PopItemWidth()

        -- Концы костей
        imgui.SetCursorPos(imgui.ImVec2(10, 80))
        imgui.Checkbox(u8'Концы костей', BoneEnds_Active)
        imgui.SetCursorPos(imgui.ImVec2(30, 110))
        imgui.ColorEdit4(u8("Цвет##Color_BoneEnds"), BoneEnds_Color, imgui.ColorEditFlags.NoInputs)
        imgui.SameLine()
        imgui.PushItemWidth(110)
        imgui.Combo("", BoneEnds_Type, ImItems, #BoneEnds_TypeList)
        imgui.SameLine()
        imgui.PopItemWidth()
        imgui.PushItemWidth(35)
        imgui.DragInt(u8'Размер', BoneEnds_Size, 0, 0, 30)
        imgui.SameLine()
        imgui.Checkbox(u8'Динам. размер', BoneEnds_SizeDynamic)
        imgui.SameLine()
        imgui.DragInt(u8'Поворот', BoneEnds_Rotation, 0, 0, 360)
        imgui.PopItemWidth()
        
        

        -- Линии
        imgui.SetCursorPos(imgui.ImVec2(10, 150))
        imgui.Checkbox(u8'Линии', Lines_Active)
        imgui.SameLine()
        imgui.SetCursorPos(imgui.ImVec2(30, 180))
        imgui.ColorEdit4(u8("Цвет линий"), Lines_Color, imgui.ColorEditFlags.NoInputs)
        imgui.SameLine()
        imgui.PushItemWidth(35)
        imgui.DragInt(u8'Толщина##Lines_Thickness', Lines_Thickness, 0, 1, 3)
        imgui.PopItemWidth()

        -- Теги
        imgui.SetCursorPos(imgui.ImVec2(10, 220))
        if imgui.Checkbox(u8'Теги', Tag_Active) then
            if Tag_Active[0] then
                nameTagON()
            else
                nameTagOFF()
            end
        end
        imgui.SetCursorPos(imgui.ImVec2(30, 250))
        if imgui.Checkbox(u8'Видимость через стены', Tag_VisibilityWall) then
            if not Tag_VisibilityWall[0] then
                VisibilityWall = 1
                mem.setint8(sampGetServerSettingsPtr() + 47, 1)
            else
                VisibilityWall = 0
                mem.setint8(sampGetServerSettingsPtr() + 47, 0)
            end
        end
        imgui.SameLine()
        imgui.PushItemWidth(35)
        if imgui.DragFloat(u8'Дальность прорисовки ников##Tag_VisibilityDistance', Tag_VisibilityDistance, 1, 0, 1000, "%.1f") then
            mem.setfloat(sampGetServerSettingsPtr() + 39, Tag_VisibilityDistance[0])
        end
        imgui.PopItemWidth()
    imgui.EndChild()
    imgui.End()
end)


imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    
    -- Налаштування іконок
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('light'), 14, config, iconRanges) -- solid - тип иконок, так же есть thin, regular, light и duotone
end)



-- Главаня функция
function main()
    sampRegisterChatCommand('cc',function()
        wMain[0] = not wMain[0]
    end)
    lua_thread.create(Visual)
    while true do
        wait(0)
    end
end


-- WH
function Visual()
    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local find, handle = sampGetCharHandleBySampPlayerId(i)
            if find then
                 if isCharOnScreen(handle) then
                    -- Линии 
                    if Lines_Active[0] then
                        local myPosScreen = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, PLAYER_PED))}
                        local enPosScreen = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, handle))}
                        renderDrawLine(myPosScreen[1], myPosScreen[2], enPosScreen[1], enPosScreen[2], Lines_Thickness[0], colorToHex(Lines_Color[0], Lines_Color[1], Lines_Color[2], Lines_Color[3]))
                    end
                    -- Кости
                    if Bones_Active[0] then
                        local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
						for v = 1, #t do
							pos1 = {GetBodyPartCoordinates(t[v], handle)}
							pos2 = {GetBodyPartCoordinates(t[v] + 1, handle)}
							pos1Screen = {convert3DCoordsToScreen(pos1[1], pos1[2], pos1[3])}
							pos2Screen = {convert3DCoordsToScreen(pos2[1], pos2[2], pos2[3])}
							renderDrawLine(pos1Screen[1], pos1Screen[2], pos2Screen[1], pos2Screen[2], Bones_Thickness[0], colorToHex(Bones_Color[0], Bones_Color[1], Bones_Color[2], Bones_Color[3]))
						end
						for v = 4, 5 do
							pos2 = {GetBodyPartCoordinates(v * 10 + 1, handle)}
							pos2Screen = {convert3DCoordsToScreen(pos2[1], pos2[2], pos2[3])}
							renderDrawLine(pos1Screen[1], pos1Screen[2], pos2Screen[1], pos2Screen[2], Bones_Thickness[0], colorToHex(Bones_Color[0], Bones_Color[1], Bones_Color[2], Bones_Color[3]))
						end
						local t = {53, 43, 24, 34, 6}
                        if BoneEnds_Active[0] then
                            if BoneEnds_Type[0] == 0 then Ends_Type = 4 end
                            if BoneEnds_Type[0] == 1 then Ends_Type = 30 end
                            if BoneEnds_Type[0] == 2 then Ends_Type = 3 end
                            if BoneEnds_Type[0] == 3 then Ends_Type = 5 end
                            local px, py, pz = getCharCoordinates(PLAYER_PED)
                            local tx, ty, tz = getCharCoordinates(handle)
                            local dist = getDistanceBetweenCoords3d(px, py, pz, tx, ty, tz)
	                        for v = 1, #t do
		                        pos = {GetBodyPartCoordinates(t[v], handle)}
		                        pos1Screen = {convert3DCoordsToScreen(pos[1], pos[2], pos[3])}
                                local size
                                if BoneEnds_SizeDynamic[0] then
                                    size = BoneEnds_Size[0] / math.sqrt(dist / 2)
                                    if size < 2 then size = 2 end
                                    if size > BoneEnds_Size[0] then size = BoneEnds_Size[0] end
                                else size = BoneEnds_Size[0] end
                                renderDrawPolygon(pos1Screen[1],pos1Screen[2], size, size, Ends_Type, BoneEnds_Rotation[0], colorToHex(BoneEnds_Color[0], BoneEnds_Color[1], BoneEnds_Color[2], BoneEnds_Color[3]))
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end


-- Функция для получения костей
function GetBodyPartCoordinates(id, handle)
    if doesCharExist(handle) then
        local pedptr = getCharPointer(handle)
        local vec = ffi.new("float[3]")
        getbonePosition(ffi.cast("void*", pedptr), vec, id, true)
        return vec[0], vec[1], vec[2]
    end
end


-- Преобразовыем RGBA (1.0) >> RGBA (255) >> Hex
function colorToHex(r, g, b, a)
    r = math.floor(r * 255)
    g = math.floor(g * 255)
    b = math.floor(b * 255)
    a = math.floor(a * 255)
    local hex = bit.bor(bit.lshift(a, 24),
                  bit.lshift(r, 16),
                  bit.lshift(g, 8),
                  b)
    return string.format("0x%02X%02X%02X%02X", bit.rshift(hex, 24), bit.rshift(hex, 16) % 256, bit.rshift(hex, 8) % 256, hex % 256)
end


-- Меню
function imgui.CustomMenu(labels, selected, size, speed, centering)
    local bool = false
    speed = speed or 0.2
    local radius = size.y * 0.50
    local draw_list = imgui.GetWindowDrawList()
    if LastActiveTime == nil then LastActiveTime = {} end
    if LastActive == nil then LastActive = {} end
    if ActivePos == nil then ActivePos = {x = 0, y = 0} end
    if MoveAnim == nil then MoveAnim = {start_pos = {x=0,y=0}, target_pos = {x=0,y=0}, start_time = 0, duration = 0.15} end

    local function ImSaturate(f)
        return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
    end
    local function easeInOut(t)
        return 0.5 - 0.5 * math.cos(math.pi * t)
    end

    for i, v in ipairs(labels) do
        local c = imgui.GetCursorPos()
        local p = imgui.GetCursorScreenPos()

        if imgui.InvisibleButton(v..'##'..i, size) then
            selected[0] = i
            LastActiveTime[v] = os.clock()
            LastActive[v] = true
            bool = true
            MoveAnim.start_pos.x = ActivePos.x
            MoveAnim.start_pos.y = ActivePos.y
            MoveAnim.target_pos.x = p.x
            MoveAnim.target_pos.y = p.y
            MoveAnim.start_time = os.clock()
        end
        imgui.SetCursorPos(c)
        local t = selected[0] == i and 1.0 or 0.0
        if LastActive[v] then
            local time = os.clock() - LastActiveTime[v]
            if time <= 0.3 then
                local t_anim = ImSaturate(time / speed)
                t = selected[0] == i and t_anim or 1.0 - t_anim
            else
                LastActive[v] = false
            end
        end
        local col_bg = imgui.GetColorU32Vec4(selected[0] == i and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImVec4(0,0,0,0))
        local col_box = imgui.GetColorU32Vec4(selected[0] == i and imgui.ImVec4(1,1,1,1) or imgui.ImVec4(0,0,0,0))
        local col_hovered = imgui.GetStyle().Colors[imgui.Col.ButtonHovered]
        local col_hovered = imgui.GetColorU32Vec4(imgui.ImVec4(col_hovered.x, col_hovered.y, col_hovered.z, (imgui.IsItemHovered() and 0.2 or 0)))
        draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/6, p.y), imgui.ImVec2(p.x + (radius * 0.65) + t * size.x, p.y + size.y), col_bg, 0)
        draw_list:AddRectFilled(imgui.ImVec2(p.x-size.x/6, p.y), imgui.ImVec2(p.x + (radius * 0.65) + size.x, p.y + size.y), col_hovered, 0)
        local elapsed = os.clock() - MoveAnim.start_time
        local t_anim = math.min(elapsed / MoveAnim.duration, 1.0)
        local t_eased = easeInOut(t_anim)
        ActivePos.x = MoveAnim.start_pos.x + (MoveAnim.target_pos.x - MoveAnim.start_pos.x) * t_eased
        ActivePos.y = MoveAnim.start_pos.y + (MoveAnim.target_pos.y - MoveAnim.start_pos.y) * t_eased
        draw_list:AddRectFilled(imgui.ImVec2(ActivePos.x, ActivePos.y), imgui.ImVec2(ActivePos.x+7, ActivePos.y + size.y), col_box)
        imgui.SetCursorPos(imgui.ImVec2(c.x+(centering and (size.x-imgui.CalcTextSize(v).x)/2 or 15), c.y+(size.y-imgui.CalcTextSize(v).y)/2))
        imgui.Text(v)
        imgui.SetCursorPos(imgui.ImVec2(c.x, c.y+size.y))
    end

    return bool
end
function nameTagON()
	local pStSet = sampGetServerSettingsPtr()
	mem.setfloat(pStSet + 39, 1000)
	mem.setint8(pStSet + 47, VisibilityWall)
	mem.setint8(pStSet + 56, 0)
end

function nameTagOFF()
	local pStSet = sampGetServerSettingsPtr()
	mem.setfloat(pStSet + 39, 40)
	mem.setint8(pStSet + 47, 1)
	mem.setint8(pStSet + 56, 1)
end