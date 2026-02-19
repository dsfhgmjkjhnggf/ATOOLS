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
local Lines_VisibilityDistance = new.int(300)

-- Скелет
--------- Кости
local Bones_Active = new.bool(true)

local Bones_ColorType = new.int(1)
local Bones_ColorTypeArray = {u8'Стандарный (TAB)', u8'Статический', u8'Динамический', u8'Индикатор стены'}
local Bones_ColorTypeItems = imgui.new['const char*'][#Bones_ColorTypeArray](Bones_ColorTypeArray)

local Bones_ShiftColor = new.bool(true)

local Bones_Color = new.float[4](1.0, 1.0, 1.0, 1.0)
local Bones_ColorAlphaTAB = new.int(255)
local Bones_ColorAlphaDynamic = new.int(255)
local Bones_ColorDynamicSpeed = new.int(5)

local Bones_Thickness = new.int(1)

local Bones_VisibilityDistance = new.int(300)


--------- Концы костей
local BoneEnds_Active = new.bool(true)

local BoneEnds_ColorType = new.int(1)
local BoneEnds_ColorTypeArray = {u8'Стандарный (TAB)', u8'Статический', u8'Динамический', u8'Индикатор стены'}
local BoneEnds_ColorTypeItems = imgui.new['const char*'][#BoneEnds_ColorTypeArray](BoneEnds_ColorTypeArray)

local BoneEnds_ShiftColor = new.bool(true)

local BoneEnds_Color = new.float[4](1.0, 1.0, 1.0, 1.0)
local BoneEnds_ColorAlphaTAB = new.int(255)
local BoneEnds_ColorAlphaDynamic = new.int(255)
local BoneEnds_ColorDynamicSpeed = new.int(5)

local BoneEnds_Size = new.int(15)
local BoneEnds_SizeDynamic = new.bool(true)
local BoneEnds_Rotation = new.int(0)

local BoneEnds_Figure = new.int(1)
local BoneEnds_FigureArray = {u8'Квадрат', u8'Круг', u8'Треугольник', u8'Пятиугольник'}
local BoneEnds_FigureItems = imgui.new['const char*'][#BoneEnds_FigureArray](BoneEnds_FigureArray)



-- Теги
local Tag_Active = new.bool(true)
local Tag_VisibilityWall = new.bool(true)
local Tag_VisibilityDistance = new.float(300)
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
        imgui.Checkbox(u8'Скелет  '..faicons('GEAR') , Bones_Active) if imgui.IsItemClicked(1) then imgui.OpenPopup('ESP_Bones') end
        if imgui.BeginPopup('ESP_Bones') then
            imgui.Text(u8"Настройки костей:")
            imgui.Combo(u8"Режим цвета##Bones_ColorType", Bones_ColorType, Bones_ColorTypeItems, #Bones_ColorTypeArray)
            if Bones_ColorType[0] == 0 then
                imgui.DragInt(u8'Прозрачность##Bones_ColorAlphaTAB', Bones_ColorAlphaTAB, 0, 0, 255)
            elseif Bones_ColorType[0] == 1 then
                imgui.ColorEdit4(u8("Цвет##Bones_Color"), Bones_Color, imgui.ColorEditFlags.NoInputs)
            elseif Bones_ColorType[0] == 2 then
                imgui.Checkbox(u8'Сдвиг палитры по ID##Bones_ShiftColor', Bones_ShiftColor)
                imgui.DragInt(u8'Прозрачность##Bones_ColorAlphaDynamic', Bones_ColorAlphaDynamic, 0, 0, 255)
                imgui.DragInt(u8'Скорость##Bones_ColorDynamicSpeed', Bones_ColorDynamicSpeed, 0, 0, 10)
            end
            
            imgui.PushItemWidth(35)
            imgui.DragInt(u8'Толщина##Bones_Thickness', Bones_Thickness, 0, 1, 3)
            imgui.DragInt(u8'Дистанция отрисовки##Bones_VisibilityDistance', Bones_VisibilityDistance, 1, 1, 1000)
            imgui.PopItemWidth()

            imgui.NewLine()
            imgui.Text(u8"Настройки конца костей:")
            imgui.Checkbox(u8'Концы костей', BoneEnds_Active)
            imgui.Combo(u8"Режим цвета##BoneEnds_ColorType", BoneEnds_ColorType, BoneEnds_ColorTypeItems, #BoneEnds_ColorTypeArray)
            if BoneEnds_ColorType[0] == 0 then
                imgui.DragInt(u8'Прозрачность##BoneEnds_ColorAlphaTAB', BoneEnds_ColorAlphaTAB, 0, 0, 255)
            elseif BoneEnds_ColorType[0] == 1 then
                imgui.ColorEdit4(u8("Цвет##BoneEnds_Color"), BoneEnds_Color, imgui.ColorEditFlags.NoInputs)
            elseif BoneEnds_ColorType[0] == 2 then
                imgui.Checkbox(u8'Сдвиг палитры по ID##BoneEnds_ShiftColor', BoneEnds_ShiftColor)
                imgui.DragInt(u8'Прозрачность##BoneEnds_ColorAlphaDynamic', BoneEnds_ColorAlphaDynamic, 0, 0, 255)
                imgui.DragInt(u8'Скорость##BoneEnds_ColorDynamicSpeed', BoneEnds_ColorDynamicSpeed, 0, 0, 10)
            end
            imgui.PushItemWidth(110)
            imgui.Combo(u8"Фигура", BoneEnds_Figure, BoneEnds_FigureItems, #BoneEnds_FigureArray)
            imgui.PopItemWidth()
            imgui.PushItemWidth(35)
            imgui.DragInt(u8'Размер', BoneEnds_Size, 0, 0, 30)
            imgui.SameLine()
            imgui.Checkbox(u8'Динам. размер', BoneEnds_SizeDynamic)
            imgui.DragInt(u8'Поворот', BoneEnds_Rotation, 0, 0, 360)
            imgui.PopItemWidth()
            imgui.EndPopup()
        end
        imgui.SameLine()

        -- Линии
        imgui.Checkbox(u8'Линии  '..faicons('GEAR'), Lines_Active) if imgui.IsItemClicked(1) then imgui.OpenPopup('ESP_Lines') end
        if imgui.BeginPopup('ESP_Lines') then
            imgui.Text(u8"Настройки линий:")
            imgui.ColorEdit4(u8("Цвет##Lines_Color"), Lines_Color, imgui.ColorEditFlags.NoInputs)
            imgui.PushItemWidth(35)
            imgui.DragInt(u8'Толщина##Lines_Thickness', Lines_Thickness, 0, 1, 3)
            imgui.DragInt(u8'Дистанция отрисовки##Lines_VisibilityDistance', Lines_VisibilityDistance, 1, 1, 1000)
            imgui.PopItemWidth()
            imgui.EndPopup()
        end
        imgui.SameLine()

        -- Теги
        if imgui.Checkbox(u8'Теги  '..faicons('GEAR'), Tag_Active) then if Tag_Active[0] then nameTagON() else nameTagOFF() end end if imgui.IsItemClicked(1) then imgui.OpenPopup('ESP_Tags') end
        if imgui.BeginPopup('ESP_Tags') then
            imgui.Text(u8"Настройки тегов:")
            if imgui.Checkbox(u8'Видимость через стены', Tag_VisibilityWall) and Tag_Active[0] then nameTagON() end
            imgui.PushItemWidth(35)
            if imgui.DragFloat(u8'Дальность прорисовки ников##Tag_VisibilityDistance', Tag_VisibilityDistance, 1, 40, 1000, "%.1f") and Tag_Active[0] then nameTagON() end
            imgui.PopItemWidth()
            imgui.EndPopup()
        end      
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

local ssamp_color = 0
local ID_DUCK = 0
-- Главаня функция
function main()
    sampRegisterChatCommand('cc',function() wMain[0] = not wMain[0] end)
    sampRegisterChatCommand('ssp', arge)
    if Tag_Active[0] then nameTagON() else nameTagOFF() end
    lua_thread.create(Visual)
    while true do
        wait(0)
    end
end

function arge(ffff)
    ID_DUCK = ffff
end

local font = renderCreateFont("Verdana", 9, 5)

function Visual()
    -- ESP на утки
    local D_find, D_handle = sampGetCharHandleBySampPlayerId(ID_DUCK) -- Получаем Handle по ID (временно нужно вводить через команду, далее реализация через /sp get ID)
    if D_find then
        for k, v in pairs(getAllObjects()) do
            if doesObjectExist(v) and getObjectModel(v) == 10809 and isObjectOnScreen(v) then
                local objPossScreen3 = {getObjectCoordinates(v)} -- Позиция объекта (3D)
                if objPossScreen3[1] then
                    local objPossScreen2 = {convert3DCoordsToScreen(objPossScreen3[2], objPossScreen3[3], objPossScreen3[4])}
                    local enPosScreen2 = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, D_handle))} -- Координаты точки игрока 3D, использую для подсчета дистанции между наблюдаемым игроком и уткой
                    renderDrawLine(enPosScreen2[1], enPosScreen2[2], objPossScreen2[1], objPossScreen2[2], 1.0, -1) -- Отрисовываем лининию от игрока к утке

                    local enPosScreen3 = {GetBodyPartCoordinates(3, D_handle)} -- Координаты точки игрока 3D, использую для подсчета дистанции между наблюдаемым игроком и уткой
                    local dist = getDistanceBetweenCoords3d(objPossScreen3[2], objPossScreen3[3], objPossScreen3[4], enPosScreen3[1], enPosScreen3[2], enPosScreen3[3]) -- Получае
                    renderFontDrawText(font, string.format("Утка\nДистанция: %.1fm", dist), objPossScreen2[1], objPossScreen2[2], 0xFFFFFFFF) -- Отрисовываем дистанцию по координатам утки
                    --renderDrawPolygon(objPossScreen2[1], objPossScreen2[2], 15, 15, 3, 0, -1) -- Отрисовываем фигуру по координатам утки
                end
            end
        end
    end
    -- ESP на игроков
    for i = 0, sampGetMaxPlayerId(true) do -- Цикл по всем ID игроков на сервере
        if sampIsPlayerConnected(i) then -- Проверка подключён ли игрок
            local find, handle = sampGetCharHandleBySampPlayerId(i) -- Получаем handle персонажа по ID игрока
            if find and doesCharExist(handle) and isCharOnScreen(handle)  then -- Игрок найден | персонаж существует | персонаж в зоне видимости
                local sampPlayerColor = sampGetPlayerColor(i) -- Поулчаем десятичное значение samp цвета
                local aa, rr, gg, bb = explode_argb(sampPlayerColor) -- Разбиваем десятичное значение samp цвета в argb, из-за разницы в форматах напрямую передать нельзя
                
                local myPos = {GetBodyPartCoordinates(3, PLAYER_PED)} -- Координаты моей точки
                local enPos = {GetBodyPartCoordinates(3, handle)}     -- Координаты точки игрока
                local distance = getDistanceBetweenCoords3d(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3])
                -- Линии
                if Lines_Active[0] and distance < Lines_VisibilityDistance[0] then
                    local myPosScreen = {convert3DCoordsToScreen(myPos[1], myPos[2], myPos[3])} -- 2D координаты моего персонажа
                    local enPosScreen = {convert3DCoordsToScreen(GetBodyPartCoordinates(3, handle))} -- 2D координаты игрока
                    renderDrawLine(myPosScreen[1], myPosScreen[2], enPosScreen[1], enPosScreen[2], Lines_Thickness[0], -1) -- Отрисовываем
                end

                -- Кости
                if Bones_Active[0] and distance < Bones_VisibilityDistance[0] then
                    if Bones_ColorType[0] == 0 then
                        color = join_argb(Bones_ColorAlphaTAB[0], rr, gg, bb, false)
                    elseif Bones_ColorType[0] == 1 then
                        color = join_argb(Bones_Color[3], Bones_Color[0], Bones_Color[1], Bones_Color[2], true)
                    elseif Bones_ColorType[0] == 2 then
                        if Bones_ShiftColor[0] then color = rainbow(Bones_ColorDynamicSpeed[0], Bones_ColorAlphaDynamic[0], i*20) else color = rainbow(Bones_ColorDynamicSpeed[0], Bones_ColorAlphaDynamic[0]) end
                    end

                    local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}  -- Список ID костей
                    for v = 1, #t do
                        pos1 = {GetBodyPartCoordinates(t[v], handle)} -- Координаты первой кости
                        pos2 = {GetBodyPartCoordinates(t[v] + 1, handle)} -- Координаты второй кости
                        pos1Screen = {convert3DCoordsToScreen(pos1[1], pos1[2], pos1[3])} -- 3D > 2D первой кости
                        pos2Screen = {convert3DCoordsToScreen(pos2[1], pos2[2], pos2[3])} -- 3D > 2D второй кости
                        renderDrawLine(pos1Screen[1], pos1Screen[2], pos2Screen[1], pos2Screen[2], Bones_Thickness[0], color)
                    end
                    for v = 4, 5 do -- Дополнительные соединения
                        pos2 = {GetBodyPartCoordinates(v * 10 + 1, handle)}
                        pos2Screen = {convert3DCoordsToScreen(pos2[1], pos2[2], pos2[3])}
                        renderDrawLine(pos1Screen[1], pos1Screen[2], pos2Screen[1], pos2Screen[2], Bones_Thickness[0], color)
                    end

                    -- Концы костей
                    if BoneEnds_Active[0] then
                        if BoneEnds_ColorType[0] == 0 then
                            color = join_argb(BoneEnds_ColorAlphaTAB[0], rr, gg, bb, false)
                        elseif BoneEnds_ColorType[0] == 1 then
                            color = join_argb(BoneEnds_Color[3], BoneEnds_Color[0], BoneEnds_Color[1], BoneEnds_Color[2], true)
                        elseif BoneEnds_ColorType[0] == 2 then
                            if BoneEnds_ShiftColor[0] then color = rainbow(BoneEnds_ColorDynamicSpeed[0], BoneEnds_ColorAlphaDynamic[0], i*20) else color = rainbow(BoneEnds_ColorDynamicSpeed[0], BoneEnds_ColorAlphaDynamic[0]) end
                        end
                        local FigureTypes = {4, 30, 3, 5}
                        local Ends_Type = FigureTypes[BoneEnds_Figure[0] + 1]
                        local t = {53, 43, 24, 34, 6}
                        for v = 1, #t do
                            pos = {GetBodyPartCoordinates(t[v], handle)} -- Координаты конечной кости
                            pos1Screen = {convert3DCoordsToScreen(pos[1], pos[2], pos[3])} -- 3D > 2D
                            local size
                            if BoneEnds_SizeDynamic[0] then
                                size = BoneEnds_Size[0] / math.sqrt(distance / 2)
                                if size < 2 then size = 2 end
                                if size > BoneEnds_Size[0] then size = BoneEnds_Size[0] end
                            else size = BoneEnds_Size[0] end
                            renderDrawPolygon(pos1Screen[1],pos1Screen[2], size, size, Ends_Type, BoneEnds_Rotation[0], color)
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


   -- function rainbow(speed, alpha)
   --     local time = os.clock()
   --     return math.floor(math.sin(time * speed) * 127 + 128), math.floor(math.sin(time * speed + 2) * 127 + 128), math.floor(math.sin(time * speed + 4) * 127 + 128), alpha
    --end


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
    if Tag_VisibilityWall[0] then VisibilityWall = 0 else VisibilityWall = 1 end
	mem.setfloat(pStSet + 39, Tag_VisibilityDistance[0])
	mem.setint8(pStSet + 47, VisibilityWall)
	mem.setint8(pStSet + 56, 0)
end

function nameTagOFF()
	local pStSet = sampGetServerSettingsPtr()
	mem.setfloat(pStSet + 39, 40)
	mem.setint8(pStSet + 47, 1)
	mem.setint8(pStSet + 56, 1)
end



-- Для ESP представлено три режима раюботы цветов
-- 1. Стандарный (TAB) >> альфа канал
-- 2. Пользовательский
-- 3. Динамичечкий >> сдвиг + альфа канал
-- 4. Идикатор стены





----------------------------------
function rainbow(speed, alpha, modify) -- Возвращает дисятичное argb.
    if not modify then modify = 0 end
    local time = os.clock() + modify
    local r = math.floor(math.sin(time * speed) * 127 + 128)
    local g = math.floor(math.sin(time * speed + 2) * 127 + 128)
    local b = math.floor(math.sin(time * speed + 4) * 127 + 128)
    return bit.bor(bit.lshift(alpha, 24), bit.lshift(r, 16), bit.lshift(g, 8), b)
end

function explode_argb(argb)
  local a = bit.band(bit.rshift(argb, 24), 0xFF)
  local r = bit.band(bit.rshift(argb, 16), 0xFF)
  local g = bit.band(bit.rshift(argb, 8), 0xFF)
  local b = bit.band(argb, 0xFF)
  return a, r, g, b
end


function join_argb(a, r, g, b, f_type) -- Принимает ARGB, возвращает NUM
    if f_type then
        a = math.floor(a * 255)
        r = math.floor(r * 255)
        g = math.floor(g * 255)
        b = math.floor(b * 255)
    end
    return bit.bor(bit.lshift(a, 24), bit.lshift(r, 16), bit.lshift(g, 8), b)
end


-- Т-к думал, что render принимает только HEX сделал её, пока что она не нунжа.
--function join_argb_to_hex(a, r, g, b) -- Принимает ARGB, возвращает HEX
    --local ri = math.floor(r * 255)
    --local gi = math.floor(g * 255)
    --local bi = math.floor(b * 255)
    --local ai = math.floor(a * 255)
    --return string.format("0x%02X%02X%02X%02X", a, r, g, b)
--end