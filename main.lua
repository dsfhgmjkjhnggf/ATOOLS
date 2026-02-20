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

local cjc = require("carbjsonconfig")

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

local Lines_ClrTypeArray = {u8'Стандарный (TAB)', u8'Статический', u8'Динамический', u8'Индикатор стены'}
local Lines_ClrTypeItems = imgui.new['const char*'][#Lines_ClrTypeArray](Lines_ClrTypeArray)
--
local Bones_ClrTypeArray = {u8'Стандарный (TAB)', u8'Статический', u8'Динамический', u8'Индикатор стены'}
local Bones_ClrTypeItems = imgui.new['const char*'][#Bones_ClrTypeArray](Bones_ClrTypeArray)
--
local BoneEnds_ClrTypeArray = {u8'Стандарный (TAB)', u8'Статический', u8'Динамический', u8'Индикатор стены'}
local BoneEnds_ClrTypeItems = imgui.new['const char*'][#BoneEnds_ClrTypeArray](BoneEnds_ClrTypeArray)
--
local BoneEnds_FigureArray = {u8'Квадрат', u8'Круг', u8'Треугольник', u8'Пятиугольник'}
local BoneEnds_FigureItems = imgui.new['const char*'][#BoneEnds_FigureArray](BoneEnds_FigureArray)

local Set={
    Vis = {
        Lines = {
            Active = new.bool(true),
            ClrType = new.int(1),
            ClrStdAlph = new.int(255),
            ClrStat = new.float[4](1.0, 1.0, 1.0, 1.0),
            ClrDynAlph = new.int(255),
            ClrDynSpeed = new.float(2),
            ClrDynShift = new.bool(true),
            Thickness = new.int(1),
            VisDistance = new.int(300)
        },
        Bones = {
            Active = new.bool(true),
            ClrType = new.int(1),
            ClrStdAlph = new.int(255),
            ClrStat = new.float[4](1.0, 1.0, 1.0, 1.0),
            ClrDynAlph = new.int(255),
            ClrDynSpeed = new.float(2),
            ClrDynShift = new.bool(true),
            Thickness = new.float(1),
            VisDistance = new.int(300)
        },
        BoneEnds = {
            Active = new.bool(true),
            ClrType = new.int(1),
            ClrStdAlph = new.int(255),
            ClrStat = new.float[4](1.0, 1.0, 1.0, 1.0),
            ClrDynAlph = new.int(255),
            ClrDynSpeed = new.float(2),
            ClrDynShift = new.bool(true),
            Size = new.int(15),
            Rotation = new.int(0),
            Figure = new.int(1)
        },
        Tag = {
            Active = new.bool(false),
            VisWall = new.bool(true),
            VisDistance = new.float(300)
        }
    }
}


local Stats = {}
local Stats_Defaults  = {pm = 0, Kick = 0, mute = 0, v_mute = 0, f_mute = 0, jail = 0, gunban = 0, warn = 0, ban = 0, sban = 0}

function initDay()
    local t = os.date('*t')
    local key = string.format('%04d-%02d-%02d', t.year, t.month, t.day)
    if not Stats[key] then
        Stats[key] = {}
        for k, v in pairs(Stats_Defaults) do
            Stats[key][k] = v
        end
        Stats()
    end
end


local newFrame = imgui.OnFrame(function() return wMain[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(700, 400), imgui.Cond.FirstUseEver)
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
    imgui.Begin("##WM", wMain, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)

    -- Боковое меню
    imgui.SetCursorPos(imgui.ImVec2(0, 25))
    fps = math.floor(imgui.GetIO().Framerate)
    imgui.Text(""..fps)
    imgui.CustomMenu(tabs, tab, imgui.ImVec2(120, 40))

    -- Чилд 
    imgui.SetCursorPos(imgui.ImVec2(160, 50))
    imgui.BeginChild('Name', imgui.ImVec2(525, 300), true)
        
        -- Кости
        imgui.SetCursorPos(imgui.ImVec2(10, 10))
        imgui.Checkbox(u8'Скелет  '..faicons('GEAR') , Set.Vis.Bones.Active) if imgui.IsItemClicked(1) then imgui.OpenPopup('ESP_Bones') end
        if imgui.BeginPopup('ESP_Bones') then
            imgui.Text(u8"Общие настройки:")
            imgui.PushItemWidth(35)
            imgui.DragInt(u8'Дистанция отрисовки##Bones_VisDistance', Set.Vis.Bones.VisDistance, 1, 1, 1000) imgui.NewLine()
            imgui.Text(u8"Настройки костей:") imgui.Separator()
            imgui.PushItemWidth(135) imgui.Combo(u8"Режим цвета##Bones_ClrType", Set.Vis.Bones.ClrType, Bones_ClrTypeItems, #Bones_ClrTypeArray) imgui.PopItemWidth() imgui.SameLine()
            if imgui.Button(u8"Sync с костями") then
                Set.Vis.BoneEnds.ClrType[0] = Set.Vis.Bones.ClrType[0]
                if Set.Vis.Bones.ClrType[0] == 0 then Set.Vis.BoneEnds.ClrStdAlph[0] = Set.Vis.Bones.ClrStdAlph[0]
                elseif Set.Vis.Bones.ClrType[0] == 1 then for i = 0, 3 do Set.Vis.BoneEnds.ClrStat[i] = Set.Vis.Bones.ClrStat[i] end
                elseif Set.Vis.Bones.ClrType[0] == 2 then
                    Set.Vis.BoneEnds.ClrDynAlph[0] = Set.Vis.Bones.ClrDynAlph[0]
                    Set.Vis.BoneEnds.ClrDynSpeed[0] = Set.Vis.Bones.ClrDynSpeed[0]
                    Set.Vis.BoneEnds.ClrDynShift[0] = Set.Vis.Bones.ClrDynShift[0]
                end
            end
            if Set.Vis.Bones.ClrType[0] == 0 then imgui.DragInt(u8'Прозрачность##Bones_ClrStdAlph', Set.Vis.Bones.ClrStdAlph, 0, 0, 255)
            elseif Set.Vis.Bones.ClrType[0] == 1 then imgui.ColorEdit4(u8("Цвет##Bones_ClrStat"), Set.Vis.Bones.ClrStat, imgui.ColorEditFlags.NoInputs)
            elseif Set.Vis.Bones.ClrType[0] == 2 then
                imgui.Checkbox(u8'Сдвиг палитры по ID##Bones_ClrDynShift', Set.Vis.Bones.ClrDynShift)
                imgui.SameLine()
                imgui.DragInt(u8'Прозрачность##Bones_ClrDynAlph', Set.Vis.Bones.ClrDynAlph, 0, 0, 255)
                imgui.SameLine()
                imgui.DragFloat(u8'Скорость##Bones_ClrDynSpeed', Set.Vis.Bones.ClrDynSpeed, 0, 0, 10, "%.1f") end
            imgui.Separator()
            imgui.DragFloat(u8'Толщина##Bones_Thickness', Set.Vis.Bones.Thickness, 0, 1, 3, "%.1f")
            imgui.NewLine()
            imgui.Text(u8"Настройки конца костей:")
            imgui.Checkbox(u8'Концы костей', Set.Vis.BoneEnds.Active)
            imgui.Separator()
            imgui.PushItemWidth(135)
            imgui.Combo(u8"Режим цвета##BoneEnds_ClrType", Set.Vis.BoneEnds.ClrType, BoneEnds_ClrTypeItems, #BoneEnds_ClrTypeArray)
            imgui.PopItemWidth()
            if Set.Vis.BoneEnds.ClrType[0] == 0 then
                imgui.DragInt(u8'Прозрачность##BoneEnds_ClrStdAlph', Set.Vis.BoneEnds.ClrStdAlph, 0, 0, 255)
            elseif Set.Vis.BoneEnds.ClrType[0] == 1 then
                imgui.ColorEdit4(u8("Цвет##BoneEnds_ClrStat"), Set.Vis.BoneEnds.ClrStat, imgui.ColorEditFlags.NoInputs)
            elseif Set.Vis.BoneEnds.ClrType[0] == 2 then
                imgui.Checkbox(u8'Сдвиг палитры по ID##BoneEnds_ClrDynShift', Set.Vis.BoneEnds.ClrDynShift)
                imgui.SameLine()
                imgui.DragInt(u8'Прозрачность##BoneEnds_ClrDynAlph', Set.Vis.BoneEnds.ClrDynAlph, 0, 0, 255)
                imgui.SameLine()
                imgui.DragFloat(u8'Скорость##BoneEnds_ClrDynSpeed', Set.Vis.BoneEnds.ClrDynSpeed, 0, 0, 10, "%.1f")
            end
            imgui.Separator()
            imgui.PushItemWidth(110) imgui.Combo(u8"Фигура", Set.Vis.BoneEnds.Figure, BoneEnds_FigureItems, #BoneEnds_FigureArray) imgui.PopItemWidth()
            imgui.SameLine()
            imgui.DragInt(u8'Размер', Set.Vis.BoneEnds.Size, 0, 0, 30)
            imgui.SameLine()
            imgui.DragInt(u8'Поворот', Set.Vis.BoneEnds.Rotation, 0, 0, 360)

            imgui.PopItemWidth()
            imgui.EndPopup()
        end
        imgui.SameLine()

        -- Линии
        imgui.Checkbox(u8'Линии  '..faicons('GEAR'), Set.Vis.Lines.Active) if imgui.IsItemClicked(1) then imgui.OpenPopup('ESP_Lines') end
        if imgui.BeginPopup('ESP_Lines') then
            imgui.Text(u8"Настройки линий:")
            imgui.PushItemWidth(135) imgui.Combo(u8"Режим цвета##Lines_ClrType", Set.Vis.Lines.ClrType, Lines_ClrTypeItems, #Lines_ClrTypeArray) imgui.PopItemWidth() imgui.SameLine()
            if imgui.Button(u8"Sync от костей") then
                Set.Vis.Lines.ClrType[0] = Set.Vis.Bones.ClrType[0]
                if Set.Vis.Bones.ClrType[0] == 0 then Set.Vis.Lines.ClrStdAlph[0] = Set.Vis.Bones.ClrStdAlph[0]
                elseif Set.Vis.Bones.ClrType[0] == 1 then for i = 0, 3 do Set.Vis.Lines.ClrStat[i] = Set.Vis.Bones.ClrStat[i] end
                elseif Set.Vis.Bones.ClrType[0] == 2 then
                    Set.Vis.Lines.ClrDynAlph[0] = Set.Vis.Bones.ClrDynAlph[0]
                    Set.Vis.Lines.ClrDynSpeed[0] = Set.Vis.Bones.ClrDynSpeed[0]
                    Set.Vis.Lines.ClrDynShift[0] = Set.Vis.Bones.ClrDynShift[0]
                end
            end
            imgui.PushItemWidth(35)
            if Set.Vis.Lines.ClrType[0] == 0 then imgui.DragInt(u8'Прозрачность##Lines_ClrStdAlph', Set.Vis.Lines.ClrStdAlph, 0, 0, 255)
            elseif Set.Vis.Lines.ClrType[0] == 1 then imgui.ColorEdit4(u8("Цвет##Lines_ClrStat"), Set.Vis.Lines.ClrStat, imgui.ColorEditFlags.NoInputs)
            elseif Set.Vis.Lines.ClrType[0] == 2 then
                imgui.Checkbox(u8'Сдвиг палитры по ID##Bones_ClrDynShift', Set.Vis.Lines.ClrDynShift) imgui.SameLine()
                imgui.DragInt(u8'Прозрачность##Bones_ClrDynAlph', Set.Vis.Lines.ClrDynAlph, 0, 0, 255) imgui.SameLine()
                imgui.DragFloat(u8'Скорость##Bones_ClrDynSpeed', Set.Vis.Lines.ClrDynSpeed, 0, 0, 10, "%.1f") end
            imgui.Separator()
            imgui.DragInt(u8'Толщина##Lines_Thickness', Set.Vis.Lines.Thickness, 0, 1, 3)
            imgui.DragInt(u8'Дистанция отрисовки##Lines_VisDistance', Set.Vis.Lines.VisDistance, 1, 1, 1000)
            imgui.PopItemWidth()
            imgui.EndPopup()
        end
        imgui.SameLine()

        -- Теги
        if imgui.Checkbox(u8'Теги  '..faicons('GEAR'), Set.Vis.Tag.Active) then if Set.Vis.Tag.Active[0] then nameTagON() else nameTagOFF() end end if imgui.IsItemClicked(1) then imgui.OpenPopup('ESP_Tags') end
        if imgui.BeginPopup('ESP_Tags') then
            imgui.Text(u8"Настройки тегов:")
            if imgui.Checkbox(u8'Видимость через стены', Set.Vis.Tag.VisWall) and Set.Vis.Tag.Active[0] then nameTagON() end
            imgui.PushItemWidth(35)
            if imgui.DragFloat(u8'Дальность прорисовки ников##Tag_VisDistance', Set.Vis.Tag.VisDistance, 1, 40, 1000, "%.1f") and Set.Vis.Tag.Active[0] then nameTagON() end
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


function Visual()
    -- ESP на утки
    local ID_DUCK = 0 --------------------------------ТУТ ID нужно
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
                    --local font = renderCreateFont("Verdana", 9, 5) -- В глобал--------------------------------------
                    --renderFontDrawText(font, string.format("Утка\nДистанция: %.1fm", dist), objPossScreen2[1], objPossScreen2[2], 0xFFFFFFFF) -- Отрисовываем дистанцию по координатам утки
                    --renderDrawPolygon(objPossScreen2[1], objPossScreen2[2], 15, 15, 3, 0, -1) -- Отрисовываем фигуру по координатам утки
                end
            end
        end
    end
    -- ESP на игроков
    local myPos = {GetBodyPartCoordinates(3, PLAYER_PED)}
    for i = 0, sampGetMaxPlayerId(true) do -- Цикл по всем ID игроков на сервере
        if sampIsPlayerConnected(i) then -- Проверка подключён ли игрок
            local find, handle = sampGetCharHandleBySampPlayerId(i) -- Получаем handle персонажа по ID игрока
            if find and doesCharExist(handle) and isCharOnScreen(handle)  then -- Игрок найден | персонаж существует | персонаж в зоне видимости
                local sampPlayerColor = sampGetPlayerColor(i) -- Поулчаем десятичное значение samp цвета
                local aa, rr, gg, bb = explode_argb(sampPlayerColor) -- Разбиваем десятичное значение samp цвета в argb, из-за разницы в форматах напрямую передать нельзя
                local enPos = {GetBodyPartCoordinates(3, handle)}     -- Координаты точки игрока
                local distance = getDistanceBetweenCoords3d(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3])
                -- Линии
                if Set.Vis.Lines.Active[0] and distance < Set.Vis.Lines.VisDistance[0] then
                    local color
                    if Set.Vis.Lines.ClrType[0] == 0 then
                        color = join_argb(Set.Vis.Lines.ClrStdAlph[0], rr, gg, bb)
                    elseif Set.Vis.Lines.ClrType[0] == 1 then
                        color = join_rgba(Set.Vis.Lines.ClrStat[0], Set.Vis.Lines.ClrStat[1], Set.Vis.Lines.ClrStat[2], Set.Vis.Lines.ClrStat[3])
                    elseif Set.Vis.Lines.ClrType[0] == 2 then
                        if Set.Vis.Lines.ClrDynShift[0] then color = rainbow(Set.Vis.Lines.ClrDynSpeed[0], Set.Vis.Lines.ClrDynAlph[0], i*20) else color = rainbow(Set.Vis.Lines.ClrDynSpeed[0], Set.Vis.Lines.ClrDynAlph[0]) end
                    end
                    local myPosScreen = {convert3DCoordsToScreen(myPos[1], myPos[2], myPos[3])} -- 2D координаты моего персонажа
                    local enPosScreen = {convert3DCoordsToScreen(enPos[1], enPos[2], enPos[3])} -- 2D координаты игрока
                    renderDrawLine(myPosScreen[1], myPosScreen[2], enPosScreen[1], enPosScreen[2], Set.Vis.Lines.Thickness[0], color) -- Отрисовываем
                end

                -- Кости
                if Set.Vis.Bones.Active[0] and distance < Set.Vis.Bones.VisDistance[0] then
                    local color
                    if Set.Vis.Bones.ClrType[0] == 0 then
                        color = join_argb(Set.Vis.Bones.ClrStdAlph[0], rr, gg, bb)
                    elseif Set.Vis.Bones.ClrType[0] == 1 then
                        color = join_rgba(Set.Vis.Bones.ClrStat[0], Set.Vis.Bones.ClrStat[1], Set.Vis.Bones.ClrStat[2], Set.Vis.Bones.ClrStat[3])
                    elseif Set.Vis.Bones.ClrType[0] == 2 then
                        if Set.Vis.Bones.ClrDynShift[0] then color = rainbow(Set.Vis.Bones.ClrDynSpeed[0], Set.Vis.Bones.ClrDynAlph[0], i*20) else color = rainbow(Set.Vis.Bones.ClrDynSpeed[0], Set.Vis.Bones.ClrDynAlph[0]) end
                    end

                    local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}  -- Список ID костей
                    local pos1Screen
                    for v = 1, #t do
                        local pos1 = {GetBodyPartCoordinates(t[v], handle)} -- Координаты первой кости
                        local pos2 = {GetBodyPartCoordinates(t[v] + 1, handle)} -- Координаты второй кости
                        pos1Screen = {convert3DCoordsToScreen(pos1[1], pos1[2], pos1[3])} -- 3D > 2D первой кости
                        local pos2Screen = {convert3DCoordsToScreen(pos2[1], pos2[2], pos2[3])} -- 3D > 2D второй кости
                        renderDrawLine(pos1Screen[1], pos1Screen[2], pos2Screen[1], pos2Screen[2], Set.Vis.Bones.Thickness[0], color)
                    end
                    for v = 4, 5 do -- Дополнительные соединения
                        local pos2 = {GetBodyPartCoordinates(v * 10 + 1, handle)}
                        local pos2Screen = {convert3DCoordsToScreen(pos2[1], pos2[2], pos2[3])}
                        renderDrawLine(pos1Screen[1], pos1Screen[2], pos2Screen[1], pos2Screen[2], Set.Vis.Bones.Thickness[0], color)
                    end

                    -- Концы костей
                    if Set.Vis.BoneEnds.Active[0] then
                        local color
                        if Set.Vis.BoneEnds.ClrType[0] == 0 then
                            color = join_argb(Set.Vis.BoneEnds.ClrStdAlph[0], rr, gg, bb)
                        elseif Set.Vis.BoneEnds.ClrType[0] == 1 then
                            color = join_rgba(Set.Vis.BoneEnds.ClrStat[0], Set.Vis.BoneEnds.ClrStat[1], Set.Vis.BoneEnds.ClrStat[2], Set.Vis.BoneEnds.ClrStat[3])
                        elseif Set.Vis.BoneEnds.ClrType[0] == 2 then
                            if Set.Vis.BoneEnds.ClrDynShift[0] then color = rainbow(Set.Vis.BoneEnds.ClrDynSpeed[0], Set.Vis.BoneEnds.ClrDynAlph[0], i*20) else color = rainbow(Set.Vis.BoneEnds.ClrDynSpeed[0], Set.Vis.BoneEnds.ClrDynAlph[0]) end
                        end
                        local FigureTypes = {4, 30, 3, 5}
                        local Ends_Type = FigureTypes[Set.Vis.BoneEnds.Figure[0] + 1]
                        local t = {53, 43, 24, 34, 6}
                        for v = 1, #t do
                            local pos = {GetBodyPartCoordinates(t[v], handle)} -- Координаты конечной кости
                            local pos1Screen = {convert3DCoordsToScreen(pos[1], pos[2], pos[3])} -- 3D > 2D
                            local size = Set.Vis.BoneEnds.Size[0] / math.sqrt(distance / 2)
                            if size < 2 then size = 2 end
                            if size > Set.Vis.BoneEnds.Size[0] then size = Set.Vis.BoneEnds.Size[0] end
                            renderDrawPolygon(pos1Screen[1],pos1Screen[2], size, size, Ends_Type, Set.Vis.BoneEnds.Rotation[0], color)
                        end
                    end
                end
            end
        end
    end
    return false
end


-- Главаня функция
function main()
    if not doesDirectoryExist(getWorkingDirectory()..'/config/IRA') then
        createDirectory(getWorkingDirectory()..'/config/IRA')
    end
    cjc.load("config/IRA/Settings.json", Set)
    cjc.load("config/IRA/Stats.json", Stats)
    initDay()
    sampRegisterChatCommand('cc',function() wMain[0] = not wMain[0] end)
    if Set.Vis.Tag.Active[0] then nameTagON() else nameTagOFF() end
    lua_thread.create(Visual)
    while true do
        wait(0)
    end
end


local _boneVec = ffi.new("float[3]")
-- Функция для получения костей
function GetBodyPartCoordinates(id, handle)
    if doesCharExist(handle) then
        local pedptr = getCharPointer(handle)
        getbonePosition(ffi.cast("void*", pedptr), _boneVec, id, true)
        return _boneVec[0], _boneVec[1], _boneVec[2]
    end
    return 0, 0, 0
end


-- Tag functions:
function nameTagON()
	local pStSet = sampGetServerSettingsPtr()
    local Tag_VisWallInt = Set.Vis.Tag.VisWall[0] and 0 or 1
	mem.setfloat(pStSet + 39, Set.Vis.Tag.VisDistance[0])
	mem.setint8(pStSet + 47, Tag_VisWallInt)
	mem.setint8(pStSet + 56, 0)
end

function nameTagOFF()
	local pStSet = sampGetServerSettingsPtr()
	mem.setfloat(pStSet + 39, 40)
	mem.setint8(pStSet + 47, 1)
	mem.setint8(pStSet + 56, 1)
end


-- Color functions:
function rainbow(speed, alpha, modify) -- Возвращает переливающейся дисятичный argb.
    if not modify then modify = 0 end
    local time = os.clock() + modify
    local r = math.floor(math.sin(time * speed) * 127 + 128)
    local g = math.floor(math.sin(time * speed + 2) * 127 + 128)
    local b = math.floor(math.sin(time * speed + 4) * 127 + 128)
    return bit.bor(bit.lshift(alpha, 24), bit.lshift(r, 16), bit.lshift(g, 8), b)
end

function explode_argb(argb) -- Принимает Num, возвращает A/R/G/B
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function join_argb(a, r, g, b, f_type) -- Принимает A/R/G/B, возвращает дисятичное argb
    return bit.bor(bit.lshift(a, 24), bit.lshift(r, 16), bit.lshift(g, 8), b)
end

function join_rgba(r, g, b, a) -- Принимает R/G/B/A(1.0), возвращает дисятичное argb
    a = math.floor(a * 255)
    r = math.floor(r * 255)
    g = math.floor(g * 255)
    b = math.floor(b * 255)
    return bit.bor(bit.lshift(a, 24), bit.lshift(r, 16), bit.lshift(g, 8), b)
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