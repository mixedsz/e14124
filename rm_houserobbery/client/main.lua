local SECOND = 1000
local MINUTE = 60 * SECOND

local cancelCooldown
local cancelCooldownTime = (cfg.cooldowns.cancel or 2) * MINUTE

local sprites, job, searching, carryObj, carryPartIndex, weldObj, inside = {}
local rm_tools = exports.rm_tools
local iconPath = cfg.iconPath or ('https://cfx-nui-%s/assets/images/'):format(cache.resource)
local markerColor = cfg.interaction.colors.background

local GetEntityCoords = GetEntityCoords
local GetEntityHeading = GetEntityHeading
local GetGameTimer = GetGameTimer
local IsPlayerFreeAiming = IsPlayerFreeAiming
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local GetScriptTaskStatus = GetScriptTaskStatus
local GetHeadingFromVector_2d = GetHeadingFromVector_2d
local IsPedArmed = IsPedArmed
local DisableControlAction = DisableControlAction
local DisablePlayerFiring = DisablePlayerFiring

local math_floor = math.floor
local math_abs = math.abs
local math_random = math.random

local _, relationshipHash = AddRelationshipGroup('hr_resident')
SetRelationshipBetweenGroups(5, relationshipHash, `PLAYER`)
SetRelationshipBetweenGroups(5, `PLAYER`, relationshipHash)

local safedoorInteractOffset = vec3(-0.349, -0.029, 0.415)
local moneyModel = `v_corp_cashpack`
local deskModel = `bkr_prop_fakeid_table`
local safebodyModel = `ch_prop_ch_arcade_safe_body`
local safedoorModel = `ch_prop_ch_arcade_safe_door`

local openSceneDict = 'anim_heist@arcade_property@arcade_safe_open@male@'

local function countTableElements(t)
    if not t then return 0 end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end
local showBuyMenu = countTableElements(cfg.buy) > 0
local showSellMenu = countTableElements(cfg.sell) > 0

local function _TaskTurnPedToFaceCoord(coords)
    TaskTurnPedToFaceCoord(cache.ped, coords.x, coords.y, coords.z, 2000)

    local threshold = 5.0
    while GetScriptTaskStatus(cache.ped, 0x574BB8F5) ~= 7 do
        local pedCoords = GetEntityCoords(cache.ped)
        local pedHeading = GetEntityHeading(cache.ped)
        local targetHeading = GetHeadingFromVector_2d(coords.x - pedCoords.x, coords.y - pedCoords.y)
        if math_abs(pedHeading - targetHeading) <= threshold then
            break
        end

        Wait(1)
    end
end

local function clearJob(isCancelled, sendServer)
    if not job then return end

    if job.blip and DoesBlipExist(job.blip) then
        RemoveBlip(job.blip)
    end

    job = nil

    if isCancelled then
        notify(locale('job_canceled'), 'info')

        if sendServer then
            TriggerServerEvent('rm_houserobbery:server:cancelJob', nil, true)
        end

        if cancelCooldownTime > 0 then
            cancelCooldown = GetGameTimer() + cancelCooldownTime
            SetTimeout(cancelCooldownTime, function()
                cancelCooldown = false
            end)
        end
    end
end

local function getRemainingCooldown()
    local remainingTime = cancelCooldown - GetGameTimer()
    local minutes = math_floor(remainingTime / MINUTE)
    local seconds = math_floor((remainingTime % MINUTE) / SECOND)

    return minutes, seconds
end

local function quantitySlider(label, min, max)
    min = min or 1
    max = max or 100
    local input = lib.inputDialog(label, {
        { type = 'slider', label = locale('quantity'), required = true, default = min, min = min, max = max },
    })

    if not input or not input[1] then return end

    return input[1]
end

local function buyMenu()
    local options = {}

    for item, data in pairs(cfg.buy) do
        options[#options + 1] = {
            title = data.label,
            description = ('%s: %s%s'):format(locale('unit_price'), locale('currency'), data.price),
            icon = ('%s%s.png'):format(iconPath, item),
            onSelect = function()
                local quantity = quantitySlider(('%s | %s%s'):format(data.label, locale('currency'), data.price), min, max)

                if quantity then
                    TriggerServerEvent('rm_houserobbery:server:buy', item, quantity)
                end
            end,
        }
    end

    table.sort(options, function(a, b)
        return a.title < b.title
    end)

    lib.registerContext({
        id = 'houserobbery_buy',
        title = locale('items'),
        menu = 'houserobbery_main',
        options = options,
    })

    lib.showContext('houserobbery_buy')
end

local function sellMenu()
    local mainId = 'houserobbery_main'
    local subId = 'houserobbery_sell'
    local options = {}

    local showBulkSale = false
    for item, data in pairs(cfg.sell) do
        local price = data.price and data.price > 0 and data.price

        if data.tradeItems then
            local metadata = { ('%s:'):format(locale('items_obtained_from_trade')) }

            for _, data in pairs(data.tradeItems) do
                metadata[#metadata + 1] = ('%sx %s'):format(data.quantity, data.label)
            end

            if price then
                showBulkSale = true

                local id = ('houserobbery_sell_choise_%s'):format(item)
                lib.registerContext({
                    id = id,
                    title = locale('items'),
                    menu = subId,
                    options = {
                        {
                            title = locale('sell'),
                            description = ('%s: %s%s'):format(locale('unit_price'), locale('currency'), price),
                            onSelect = function()
                                local quantity = quantitySlider(('%s | %s%s'):format(data.label, locale('currency'), price))

                                if quantity then
                                    TriggerServerEvent('rm_houserobbery:server:sell', item, quantity)
                                end

                                lib.showContext(id)
                            end,
                        },
                        {
                            title = locale('trade'),
                            description = locale('trade_for_other_items'),
                            metadata = metadata,
                            onSelect = function()
                                local quantity = quantitySlider(data.label)

                                if quantity then
                                    TriggerServerEvent('rm_houserobbery:server:trade', item, quantity)
                                end

                                lib.showContext(id)
                            end,
                        },
                    },
                })

                options[#options + 1] = {
                    title = data.label,
                    icon = ('%s%s.png'):format(iconPath, item),
                    description = ('%s | %s'):format(locale('sell_them_for_each', locale('currency'), price), locale('trade_for_other_items')),
                    onSelect = function()
                        lib.showContext(id)
                    end,
                }
            else
                options[#options + 1] = {
                    title = data.label,
                    icon = ('%s%s.png'):format(iconPath, item),
                    description = locale('trade_for_other_items'),
                    metadata = metadata,
                    onSelect = function()
                        local quantity = quantitySlider(data.label)

                        if quantity then
                            TriggerServerEvent('rm_houserobbery:server:trade', item, quantity)
                        end

                        lib.showContext(subId)
                    end,
                }
            end
        elseif price then
            showBulkSale = true

            options[#options + 1] = {
                title = data.label,
                icon = ('%s%s.png'):format(iconPath, item),
                description = locale('sell_them_for_each', locale('currency'), price),
                onSelect = function()
                    local quantity = quantitySlider(('%s | %s%s'):format(data.label, locale('currency'), price), min, max)

                    if quantity then
                        TriggerServerEvent('rm_houserobbery:server:sell', item, quantity)
                    end

                    lib.showContext(subId)
                end,
            }
        end
    end

    table.sort(options, function(a, b)
        return a.title < b.title
    end)

    if showBulkSale then
        table.insert(options, 1, {
            title = locale('sell_all_items'),
            description = locale('sell_all_items_description'),
            onSelect = function()
                TriggerServerEvent('rm_houserobbery:server:bulkSale')

                lib.showContext(mainId)
            end,
        })
    end

    lib.registerContext({
        id = subId,
        title = locale('sell_trade_items'),
        menu = mainId,
        options = options,
    })

    lib.showContext(subId)
end

local function safeOpenScene(obj)
    if DoesEntityExist(obj) then
        local scenePos = GetOffsetFromEntityInWorldCoords(obj, 6.15, 1.192, -2.38)
        local sceneRot = vec3(0, 0, GetEntityHeading(obj) + 90)

        lib.requestAnimDict(openSceneDict)
        local openScene = NetworkCreateSynchronisedScene(scenePos.x, scenePos.y, scenePos.z, sceneRot.x, sceneRot.y, sceneRot.z, 2, false, false, 1065353216, 0, 0.8)
        NetworkAddPedToSynchronisedScene(cache.ped, openScene, openSceneDict, 'safe_open', 1.5, -4.0, 1 | 2 | 4, 16, 1148846080, 0)
        NetworkAddEntityToSynchronisedScene(obj, openScene, openSceneDict, 'safe_open_safedoor', 4.0, -8.0, 1)

        NetworkStartSynchronisedScene(openScene)

        Wait(7000)

        NetworkStopSynchronisedScene(openScene)
        RemoveAnimDict(openSceneDict)
    end
end

AddEventHandler('rm_tools:usageStarted', function(item)
    if item == 'weld' then
        weldObj = rm_tools:getWeldObject()
    end
end)

AddEventHandler('rm_tools:usageFinished', function(item)
    if item == 'weld' then
        weldObj = nil
    end
end)

local function startKeypadDisrupt()
    if not job then return end

    local keypadCoords = job.coords.keypad
    local progress = 0
    local keypadSprite = createSprite({
        coords = vec3(keypadCoords.x, keypadCoords.y, keypadCoords.z),
        text = '0%',
    })

    CreateThread(function()
        while job and job.coords.keypad do
            local pedCoords = GetEntityCoords(cache.ped)
            if #(pedCoords - keypadCoords.xyz) > 10 then
                Wait(1000)
            else
                keypadSprite:draw(pedCoords)

                if weldObj then
                    if IsPlayerFreeAiming(cache.playerId) and IsDisabledControlPressed(0, 24) then
                        local weldCoord = GetOffsetFromEntityInWorldCoords(weldObj, -0.16, 0.13, 0.0)
                        local dist = #(weldCoord - keypadCoords.xyz)
                        if dist <= 0.5 then
                            if progress < 100 then
                                progress += (cfg.weldingSpeed or 0.03)
                                keypadSprite.text = math_floor(progress) .. '%'
                            else
                                rm_tools:removeWeld()

                                local brokenKeypadNetId = lib.callback.await('rm_houserobbery:server:keypadDisrupted', 10000)
                                if brokenKeypadNetId then
                                    if not NetworkDoesEntityExistWithNetworkId(brokenKeypadNetId) then
                                        pcall(lib.waitFor, function()
                                            Wait(100)
                                            if NetworkDoesEntityExistWithNetworkId(brokenKeypadNetId) then
                                                return true
                                            end
                                        end, '', 10000)
                                    end

                                    local brokenKeypad = NetworkGetEntityFromNetworkId(brokenKeypadNetId)
                                    SetEntityHeading(brokenKeypad, keypadCoords.w)
                                    FreezeEntityPosition(brokenKeypad, true)
                                else
                                    return
                                end

                                RequestScriptAudioBank('DLC_HEIST3/CASINO_HEIST_FINALE_GENERAL_01', false)
                                PlaySoundFromCoord(-1, 'keypad_break', keypadCoords.x, keypadCoords.y, keypadCoords.z, 'dlc_ch_heist_thermal_charge_sounds', true, 2.0, false)
                                ReleaseNamedScriptAudioBank('DLC_HEIST3/CASINO_HEIST_FINALE_GENERAL_01')

                                if cfg.keypadBrokenDispatchChance and dispatch then
                                    local random = math_random(100)
                                    if random <= cfg.keypadBrokenDispatchChance then
                                        dispatch({
                                            type = 'keypad_broken',
                                            job_names = { 'police', 'sasp', 'bcso', 'sheriff' },
                                            job_types = { 'leo' },
                                            coords = keypadCoords,
                                            code = '10-90',
                                            icon = 'fas fa-house',
                                            message = locale('dispatch_house_robbery'),
                                            blip = {
                                                sprite = 40,
                                                color = 5,
                                            },
                                        })
                                    end
                                end

                                break
                            end
                        end
                    end
                end

                Wait(0)
            end
        end
    end)
end

local enterPoints = {}
AddStateBagChangeHandler('hrEnter', nil, function(bagName, key, data, reserved, replicated)
    Wait(500)
    local keypad = GetEntityFromStateBagName(bagName)

    if not cfg.enableMultiplePersonRobbing and data.jobOwner ~= cache.serverId then
        return
    end

    if not data then
        if enterPoints[keypad] then
            enterPoints[keypad]:remove()
            enterPoints[keypad] = nil
        end
        return
    end

    if enterPoints[keypad] then return end
    local shownTextUI = false
    enterPoints[keypad] = lib.points.new({
        coords = vec3(data.enter.x, data.enter.y, data.enter.z + 0.75),
        distance = 15,
        onExit = function()
            textUI.hide()
            shownTextUI = false
        end,
        nearby = function(self)
            if self.currentDistance < 1 then
                if not shownTextUI then
                    shownTextUI = true
                    textUI.show('[ ' .. cfg.interaction.text .. ' ] - ' .. locale('enter_house'))
                else
                    if IsControlJustReleased(0, cfg.interaction.controlId) then
                        textUI.hide()
                        DoScreenFadeOut(500)
                        Wait(400)
                        TriggerServerEvent('rm_houserobbery:server:enterHouse', data.jobOwner)
                        shownTextUI = false
                    end
                end
            elseif shownTextUI then
                textUI.hide()
                shownTextUI = false
            else
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.15, 0.15, 0.15, markerColor.r, markerColor.g, markerColor.b, markerColor.a or 255, false, true, 2, false)
            end
        end,
    })

    while enterPoints[keypad] and DoesEntityExist(keypad) do
        Wait(100)
    end

    if enterPoints[keypad] then
        enterPoints[keypad]:remove()
        enterPoints[keypad] = nil
    end
end)

local function createJobBlip(coords)
    if not job then return end

    local data = cfg.targetHouseBlip or { sprite = 350, color = 17, scale = 0.9 }
    job.blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(job.blip, data.sprite)
    SetBlipColour(job.blip, data.color)
    SetBlipAsShortRange(job.blip, true)
    SetBlipScale(job.blip, data.scale)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(locale('target_house') or 'Target House')
    EndTextCommandSetBlipName(job.blip)
    SetBlipRoute(job.blip, true)
end

local function mainMenu(npc)
    local options = {}

    if showBuyMenu then
        options[#options + 1] = {
            title = locale('buy_items'),
            description = locale('menu_buy_description'),
            icon = 'fa-solid fa-cart-shopping',
            onSelect = buyMenu,
        }
    end

    if showSellMenu then
        options[#options + 1] = {
            title = locale('sell_trade_items'),
            description = locale('menu_sell_description'),
            icon = 'fa-solid fa-money-bill-transfer',
            onSelect = sellMenu,
        }
    end

    if not job then
        local description = locale('menu_get_job_description')
        local icon = 'fa-solid fa-wrench'
        local disabled = searching
        if cancelCooldown then
            local minute, second = getRemainingCooldown()
            description = locale('remaining_cooldown', minute, second)
            icon = 'fa-solid fa-hourglass'
            disabled = true
        elseif cfg.hourCheck then
            local state, _description, _icon = cfg.hourCheck()
            if not state then
                description = _description
                icon = _icon
                disabled = true
            end
        end
        options[#options + 1] = {
            title = locale('get_job'),
            description = description,
            icon = icon,
            disabled = disabled,
            onSelect = function()
                searching = true

                local jobData = lib.callback.await('rm_houserobbery:server:createJob')
                if jobData then
                    job = jobData

                    ClearPedTasks(npc)
                    PlayFacialAnim(npc, 'mic_chatter', 'mp_facial')
                    TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
                    Wait(cfg.jobSearchDuration or 5000)
                    ClearFacialIdleAnimOverride(npc)

                    createJobBlip(jobData.coords.keypad)
                    notify(locale('job_start'), 'info')
                    notify(locale('job_duration', cfg.robberyDuration), 'info')

                    ClearPedTasks(npc)
                    SetTimeout(500, function()
                        TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_LEANING', 0, true)
                    end)

                    startKeypadDisrupt()
                end

                searching = false
            end,
        }
    else
        options[#options + 1] = {
            title = locale('cancel_current_job'),
            description = locale('menu_cancel_current_job_description'),
            icon = 'fa-solid fa-wrench',
            disabled = searching,
            onSelect = function()
                clearJob(true, true)
            end,
        }
    end

    lib.registerContext({
        id = 'houserobbery_main',
        title = locale('houserobbery_menu'),
        options = options,
    })

    lib.showContext('houserobbery_main')
end

RegisterNetEvent('rm_houserobbery:client:createJob', function(jobData)
    job = jobData
    createJobBlip(jobData.coords.keypad)
    notify(locale('job_start'), 'info')
    notify(locale('job_duration', cfg.robberyDuration), 'info')
    startKeypadDisrupt()
end)

CreateThread(function()
    for i = 1, #cfg.missionNPCs do
        local data = cfg.missionNPCs[i]
        lib.requestModel(data.model)
        data.entity = CreatePed(0, data.model, data.coords.x, data.coords.y, data.coords.z - 0.96, data.coords.w, false, true)
        FreezeEntityPosition(data.entity, true)
        SetBlockingOfNonTemporaryEvents(data.entity, true)
        SetEntityInvincible(data.entity, true)
        TaskStartScenarioInPlace(data.entity, 'WORLD_HUMAN_LEANING', 0, true)
        SetModelAsNoLongerNeeded(data.model)

        if data.blip then
            data.blipHandle = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
            SetBlipSprite(data.blipHandle, data.blip.sprite or 380)
            SetBlipColour(data.blipHandle, data.blip.color or 17)
            SetBlipAsShortRange(data.blipHandle, true)
            SetBlipScale(data.blipHandle, data.blip.scale or 0.6)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(data.blip.label or 'House Robbery')
            EndTextCommandSetBlipName(data.blipHandle)
        end

        if cfg.target == false or not target then
            lib.zones.sphere({
                coords = data.coords,
                radius = 1.5,
                onEnter = function()
                    textUI.show('[ ' .. cfg.interaction.text .. ' ] ' .. locale('open_houserobbery_menu'), { icon = 'fa-solid fa-wrench' })
                end,
                onExit = function()
                    textUI.hide()
                end,
                inside = function()
                    if IsControlJustReleased(0, cfg.interaction.controlId) then
                        textUI.hide()
                        mainMenu(data.entity)
                    end
                end,
            })
        else
            target.addLocalEntity(data.entity, {
                label = locale('open_houserobbery_menu'),
                distance = 2.5,
                icon = 'fa-solid fa-bars',
                onSelect = function()
                    mainMenu(data.entity)
                end,
            })
        end
    end

    SendNUIMessage({
        action = 'updateText',
        text = locale('ui.noise'),
    })
end)

if cfg.autoExitOnDeath then
    function onPlayerDeath()
        if not inside then return end
        textUI.hide()
        DoScreenFadeOut(500)
        Wait(400)
        TriggerServerEvent('rm_houserobbery:server:exitHouse', inside.jobOwner)
    end
end

RegisterNetEvent('rm_houserobbery:client:enterHouse', function(_inside)
    if inside then return end

    FreezeEntityPosition(cache.ped, true)

    local interiorId = GetInteriorFromEntity(cache.ped)
    local timeout = GetGameTimer() + 10000
    while interiorId ~= _inside.interior.id and timeout > GetGameTimer() do
        interiorId = GetInteriorFromEntity(cache.ped)
        Wait(10)
    end

    if interiorId == _inside.interior.id then
        RefreshInterior(_inside.interior.id)
        while not HasCollisionLoadedAroundEntity(cache.ped) do
            Wait(0)
        end
        DoScreenFadeIn(100)
        FreezeEntityPosition(cache.ped, false)
    else
        print('^1[Error]^7 interior failed to load, interior id: ' .. _inside.interior.id)
        TriggerServerEvent('rm_houserobbery:server:exitHouse', _inside.jobOwner)
        Wait(100)
        DoScreenFadeIn(100)
        FreezeEntityPosition(cache.ped, false)
        return
    end

    inside = _inside
    local shownTextUI = false
    inside.exitPoint = lib.points.new({
        coords = vec3(inside.exit.x, inside.exit.y, inside.exit.z + 0.75),
        distance = 5,
        onExit = function()
            textUI.hide()
            shownTextUI = false
        end,
        nearby = function(self)
            if self.currentDistance < 1 then
                if not shownTextUI then
                    shownTextUI = true
                    textUI.show('[ ' .. cfg.interaction.text .. ' ] - ' .. locale('exit_house'))
                else
                    if IsControlJustReleased(0, cfg.interaction.controlId) then
                        textUI.hide()
                        DoScreenFadeOut(500)

                        if inside.interior.objects?.create then
                            for i = 1, #inside.interior.objects.create do
                                local obj = inside.interior.objects.create[i].object
                                if obj and DoesEntityExist(obj) then
                                    SetEntityAsMissionEntity(obj)
                                    DeleteEntity(obj)
                                end
                            end
                        end

                        if inside.safe?.objects then
                            for typ, obj in pairs(inside.safe.objects) do
                                if obj and DoesEntityExist(obj) then
                                    SetEntityAsMissionEntity(obj)
                                    DeleteEntity(obj)
                                end
                            end
                        end

                        Wait(400)
                        TriggerServerEvent('rm_houserobbery:server:exitHouse', _inside.jobOwner)
                        shownTextUI = false
                    end
                end
            elseif shownTextUI then
                textUI.hide()
                shownTextUI = false
            else
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.15, 0.15, 0.15, markerColor.r, markerColor.g, markerColor.b, markerColor.a or 255, false, true, 2, false)
            end
        end,
    })

    if inside.interior.objects?.create then
        for i = 1, #inside.interior.objects.create do
            local createData = inside.interior.objects.create[i]
            lib.requestModel(createData.model)
            local obj = CreateObjectNoOffset(createData.model, createData.coord.x, createData.coord.y, createData.coord.z, false, false, createData.doorFlag)
            SetEntityHeading(obj, createData.coord.w)
            FreezeEntityPosition(obj, true)
            inside.interior.objects.create[i].object = obj

            SetModelAsNoLongerNeeded(createData.model)
        end
    end
    if inside.interior.objects?.delete then
        SetTimeout(1000, function()
            if not inside then return end
            for i = 1, #inside.interior.objects.delete do
                local deleteData = inside.interior.objects.delete[i]
                local object = GetClosestObjectOfType(deleteData.coord.x, deleteData.coord.y, deleteData.coord.z, 0.5, deleteData.model, false, false, false)
                if DoesEntityExist(object) then
                    SetEntityAsMissionEntity(object)
                    DeleteEntity(object)
                end
            end
        end)
    end

    if inside.safe then
        SetTimeout(2000, function()
            inside.safe.objects = {}

            local coords = inside.safe.coords
            local money = GetClosestObjectOfType(coords.money.x, coords.money.y, coords.money.z, 0.5, moneyModel, false, false, false)
            if DoesEntityExist(money) then
                inside.safe.objects.money = money
                SetEntityNoCollisionEntity(cache.ped, money, false)
            end
            local desk = GetClosestObjectOfType(coords.desk.x, coords.desk.y, coords.desk.z, 0.5, deskModel, false, false, false)
            if DoesEntityExist(desk) then
                inside.safe.objects.desk = desk
                SetEntityNoCollisionEntity(cache.ped, desk, false)
            end
            local safebody = GetClosestObjectOfType(coords.safebody.x, coords.safebody.y, coords.safebody.z, 0.5, safebodyModel, false, false, false)
            if DoesEntityExist(safebody) then
                inside.safe.objects.safebody = safebody
                SetEntityNoCollisionEntity(cache.ped, safebody, false)
            end
            local safedoor = GetClosestObjectOfType(coords.safedoor.x, coords.safedoor.y, coords.safedoor.z, 0.5, safedoorModel, false, false, false)
            if DoesEntityExist(safedoor) then
                inside.safe.objects.safedoor = safedoor
                SetEntityNoCollisionEntity(cache.ped, safedoor, false)

                inside.safe.coords.safedoorInteract = GetOffsetFromEntityInWorldCoords(safedoor, safedoorInteractOffset.x, safedoorInteractOffset.y, safedoorInteractOffset.z)
            end

            if not inside.safe.broken then
                -- NetworkGetEntityOwner(inside.safe.objects.money) == cache.playerId

                if coords.money.w then
                    SetEntityHeading(inside.safe.objects.money, coords.money.w)
                    FreezeEntityPosition(inside.safe.objects.money, true)
                end
                if coords.desk.w then
                    SetEntityHeading(inside.safe.objects.desk, coords.desk.w)
                    FreezeEntityPosition(inside.safe.objects.desk, true)
                end
                if coords.safebody.w then
                    SetEntityHeading(inside.safe.objects.safebody, coords.safebody.w)
                    FreezeEntityPosition(inside.safe.objects.safebody, true)
                end
                if coords.safedoor.w then
                    SetEntityHeading(inside.safe.objects.safedoor, coords.safedoor.w)
                    FreezeEntityPosition(inside.safe.objects.safedoor, true)

                    inside.safe.coords.safedoorInteract = GetOffsetFromEntityInWorldCoords(safedoor, safedoorInteractOffset.x, safedoorInteractOffset.y, safedoorInteractOffset.z)
                end

                local index = #sprites + 1
                sprites[index] = createSprite({
                    coords = inside.safe.coords.safedoorInteract or inside.safe.coords.safedoor.xyz,
                    text = '0%',
                    range = 2.0,
                    type = 'safe',
                })
                inside.safe.progress = 0
            elseif not inside.safe.opened then
                local index = #sprites + 1
                sprites[index] = createSprite({
                    coords = inside.safe.coords.safedoorInteract or inside.safe.coords.safedoor.xyz,
                    text = cfg.interaction.text,
                    range = 2.0,
                    type = 'safe',
                    onInteract = {
                        controlId = cfg.interaction.controlId,
                        cb = function(self)
                            local interact = lib.table.deepclone(self.onInteract)
                            self.onInteract = nil

                            if minigames and minigames['safe'] and not minigames['safe']() then
                                self.onInteract = interact
                                return
                            end

                            safeOpenScene(inside.safe.objects.safedoor)

                            inside.safe = nil
                            TriggerServerEvent('rm_houserobbery:server:safeOpened', inside.jobOwner)
                        end,
                    },
                })
            end
        end)
    end

    for i = 1, #inside.searchables do
        if not inside.searchables[i].searched then
            local coord = inside.searchables[i].coord
            local index = #sprites + 1
            sprites[index] = createSprite({
                coords = coord,
                text = cfg.interaction.text,
                range = 2,
                type = 'searchables',
                searchableIndex = i,
                onInteract = {
                    controlId = cfg.interaction.controlId,
                    cb = function(self)
                        if not self?.searchableIndex then return end

                        local interact = lib.table.deepclone(self.onInteract)
                        self.onInteract = nil

                        if minigames and minigames['search'] and not minigames['search']() then
                            self.onInteract = interact
                            return
                        end

                        CreateThread(function()
                            _TaskTurnPedToFaceCoord(coord)
                            FreezeEntityPosition(cache.ped, true)

                            local animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@'
                            local animFlag = 1
                            local pedCoords = GetEntityCoords(cache.ped)
                            if pedCoords.z <= coord.z + 0.1 then
                                animFlag = 1 | 16
                            end
                            lib.requestAnimDict(animDict)
                            TaskPlayAnim(cache.ped, animDict, 'machinic_loop_mechandplayer', 3.0, 3.0, -1, animFlag, 0, false, false, false)

                            local duration = (cfg.searchingDuration or 10) * 1000
                            local step = 100 / (duration / 100)
                            local interval = duration / 100

                            for j = 1, 100 do
                                self.text = j .. '%'

                                Wait(interval)
                            end

                            inside.searchables[self.searchableIndex].searched = true
                            TriggerServerEvent('rm_houserobbery:server:locationSearched', inside.jobOwner, self.searchableIndex)

                            FreezeEntityPosition(cache.ped, false)
                            ClearPedTasks(cache.ped)
                            RemoveAnimDict(animDict)
                        end)
                    end,
                },
            })
        end
    end

    for i = 1, #inside.collectables do
        local collectable = inside.collectables[i]

        SetTimeout(1000, function()
            local object = GetClosestObjectOfType(collectable.coord.x, collectable.coord.y, collectable.coord.z, 0.5, collectable.model, false, false, false)
            if DoesEntityExist(object) then
                if collectable.collected then
                    SetEntityAsMissionEntity(object)
                    DeleteEntity(object)
                else
                    FreezeEntityPosition(object, true)
                end
            end
        end)

        if not collectable.collected then
            local coord = collectable.coord
            local index = #sprites + 1
            sprites[index] = createSprite({
                coords = coord,
                text = cfg.interaction.text,
                range = 2,
                type = 'collectables',
                collectableIndex = i,
                onInteract = {
                    controlId = cfg.interaction.controlId,
                    cb = function(self)
                        if not self?.collectableIndex then return end

                        local interact = lib.table.deepclone(self.onInteract)
                        self.onInteract = nil

                        if minigames and minigames['collect'] and not minigames['collect']() then
                            self.onInteract = interact
                            return
                        end

                        CreateThread(function()
                            _TaskTurnPedToFaceCoord(coord)
                            FreezeEntityPosition(cache.ped, true)

                            local animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@'
                            local animFlag = 1
                            local pedCoords = GetEntityCoords(cache.ped)
                            if pedCoords.z <= coord.z + 0.1 then
                                animFlag = 1 | 16
                            end
                            lib.requestAnimDict(animDict)
                            TaskPlayAnim(cache.ped, animDict, 'machinic_loop_mechandplayer', 3.0, 3.0, -1, animFlag, 0, false, false, false)

                            local duration = (cfg.collectingDuration or 10) * 1000
                            local step = 100 / (duration / 100)
                            local interval = duration / 100

                            for j = 1, 100 do
                                self.text = j .. '%'

                                Wait(interval)
                            end

                            inside.collectables[self.collectableIndex].collected = true
                            TriggerServerEvent('rm_houserobbery:server:objectCollected', inside.jobOwner, self.collectableIndex)

                            FreezeEntityPosition(cache.ped, false)
                            ClearPedTasks(cache.ped)
                            RemoveAnimDict(animDict)
                        end)
                    end,
                },
            })
        end
    end

    if inside.resident then
        CreateThread(function()
            if not inside.resident.ped then
                while not NetworkDoesEntityExistWithNetworkId(inside.resident.netId) do
                    Wait(20)
                end
                inside.resident.ped = NetworkGetEntityFromNetworkId(inside.resident.netId)
            end

            if inside.resident.ped and DoesEntityExist(inside.resident.ped) and not IsPedDeadOrDying(inside.resident.ped, true) then
                SetPedDropsWeaponsWhenDead(inside.resident.ped, false)

                if inside.resident.alerted or GetPedAlertness(inside.resident.ped) == 3 then
                    TaskCombatPed(inside.resident.ped, cache.ped, 0, 16)
                else
                    lib.requestAnimDict(inside.resident.anim.dict)

                    if not IsEntityPlayingAnim(inside.resident.ped, inside.resident.anim.dict, inside.resident.anim.clip, 3) then
                        TaskPlayAnim(inside.resident.ped, inside.resident.anim.dict, inside.resident.anim.clip, 1.0, 1.0, -1, inside.resident.anim.flag or 1, 0, false, false, false)
                    end

                    CreateThread(function()
                        SendNUIMessage({
                            action = 'show',
                        })
                        SetPedAudioFootstepQuiet(cache.ped, true)
                        while inside and not inside.resident.alerted and not IsPedDeadOrDying(inside.resident.ped, true) do
                            local noise = GetPlayerCurrentStealthNoise(cache.playerId)
                            if GetPedMovementClipset(cache.ped) == `move_ped_crouched` then
                                noise = noise - 2.0
                            end

                            if IsPedRunning(cache.ped) then
                                noise = noise + 5.0
                            end

                            if NetworkIsPlayerTalking(cache.playerId) then
                                noise = noise + 8.0
                            end

                            if noise > 10 then
                                noise = 10
                            elseif noise < 0 then
                                noise = 0
                            end

                            if noise > 8.0 then
                                TriggerServerEvent('rm_houserobbery:server:residentAlerted', inside.jobOwner)
                                break
                            end

                            SendNUIMessage({
                                action = 'update',
                                noise = math_floor((noise / 10) * 100 + 0.5),
                            })

                            Wait(10)
                        end

                        SendNUIMessage({
                            action = 'hide',
                        })
                        SetPedAudioFootstepQuiet(cache.ped, false)
                    end)
                end
            end
        end)
    end

    while inside do
        local isCarrying = LocalPlayer.state.hrCarry
        if not isCarrying then
            local pedCoords = GetEntityCoords(cache.ped)
            local nearInteraction

            table.sort(sprites, function(a, b)
                return #(a.coords - pedCoords) > #(b.coords - pedCoords)
            end)
            for i = #sprites, 1, -1 do
                if sprites[i].type == 'searchables' then
                    if inside.searchables[sprites[i].searchableIndex].searched then
                        table.remove(sprites, i)
                    else
                        if not nearInteraction then
                            nearInteraction = i
                        end

                        sprites[i]:draw(pedCoords, { hideText = nearInteraction and nearInteraction ~= i })
                    end
                elseif sprites[i].type == 'collectables' then
                    if inside.collectables[sprites[i].collectableIndex].collected then
                        table.remove(sprites, i)
                    else
                        if not nearInteraction then
                            nearInteraction = i
                        end

                        sprites[i]:draw(pedCoords, { hideText = nearInteraction and nearInteraction ~= i })
                    end
                elseif sprites[i].type == 'safe' then
                    if inside.safe then
                        if not nearInteraction then
                            nearInteraction = i
                        end

                        sprites[i]:draw(pedCoords, { hideText = nearInteraction and nearInteraction ~= i })
                    else
                        table.remove(sprites, i)
                    end
                end
            end

            if inside.safe then
                if not inside.safe.broken and inside.safe.progress and weldObj then
                    if IsPlayerFreeAiming(cache.playerId) and IsDisabledControlPressed(0, 24) then
                        local weldCoord = GetOffsetFromEntityInWorldCoords(weldObj, 0.079010, -0.002502, 0.145000)
                        local dist = #(weldCoord - (inside.safe.coords.safedoorInteract or inside.safe.coords.safedoor.xyz))
                        if dist <= 0.5 then
                            if inside.safe.progress < 100 then
                                inside.safe.progress += (cfg.weldingSpeed or 0.03)

                                if sprites[nearInteraction].type == 'safe' then
                                    sprites[nearInteraction].text = math_floor(inside.safe.progress) .. '%'
                                end
                            else
                                rm_tools:removeWeld()
                                inside.safe.broken = true
                                TriggerServerEvent('rm_houserobbery:server:safeBroken', inside.jobOwner)
                            end
                        end
                    end
                end
            end
        end

        if cfg.enableOnlyMeleeWeaponsInside and IsPedArmed(cache.ped, 4 | 2) then
            DisablePlayerFiring(cache.playerId, false)
            DisableControlAction(0, 24, true)  --INPUT_ATTACK
            DisableControlAction(0, 140, true) --INPUT_MELEE_ATTACK_LIGHT
            DisableControlAction(0, 141, true) --INPUT_MELEE_ATTACK_HEAVY
            DisableControlAction(0, 142, true) --INPUT_MELEE_ATTACK_ALTERNATE
        end

        Wait(1)
    end

    sprites = {}
end)

RegisterNetEvent('rm_houserobbery:client:residentAlerted', function(residentNetId, dispatchData)
    if not inside?.resident then return end

    inside.resident.ped = NetworkGetEntityFromNetworkId(residentNetId)
    ClearPedTasks(inside.resident.ped)
    SetPedCombatAttributes(inside.resident.ped, 21, true)
    SetPedCombatAttributes(inside.resident.ped, 46, true)
    SetPedCombatMovement(inside.resident.ped, 3)
    SetPedAccuracy(inside.resident.ped, 1)
    AddArmourToPed(inside.resident.ped, 100)
    SetEntityMaxHealth(inside.resident.ped, 200)
    SetEntityHealth(inside.resident.ped, 200)
    GiveWeaponToPed(inside.resident.ped, cfg.residentWeapon, 999, true, false)
    SetCurrentPedWeapon(inside.resident.ped, cfg.residentWeapon, true)
    SetPedRelationshipGroupHash(inside.resident.ped, relationshipHash)
    SetPedAsEnemy(inside.resident.ped, true)
    TaskCombatPed(inside.resident.ped, cache.ped, 0, 16)
    SetPedDropsWeaponsWhenDead(inside.resident.ped, false)
    SetPedAlertness(inside.resident.ped, 3)

    if inside.resident.alerted then return end
    inside.resident.alerted = true

    if dispatchData?.firstPlayer == cache.serverId and cfg.residentCallDispatchChance and dispatch then
        local random = math_random(100)
        if random <= cfg.residentCallDispatchChance then
            dispatch({
                type = 'resident_call',
                job_names = { 'police', 'sasp', 'bcso', 'sheriff' },
                job_types = { 'leo' },
                coords = dispatchData.coords,
                code = '10-90',
                icon = 'fas fa-house',
                message = locale('dispatch_house_robbery'),
                blip = {
                    sprite = 40,
                    color = 5,
                },
            })
        end
    end
end)

RegisterNetEvent('rm_houserobbery:client:safeBroken', function()
    if not inside?.safe then return end

    inside.safe.progress = nil
    for i = #sprites, 1, -1 do
        if sprites[i].type == 'safe' then
            sprites[i] = createSprite({
                coords = inside.safe.coords.safedoorInteract or inside.safe.coords.safedoor.xyz,
                text = cfg.interaction.text,
                range = 2.0,
                type = 'safe',
                onInteract = {
                    controlId = cfg.interaction.controlId,
                    cb = function(self)
                        local interact = lib.table.deepclone(self.onInteract)
                        self.onInteract = nil

                        if minigames and minigames['safe'] and not minigames['safe']() then
                            self.onInteract = interact
                            return
                        end

                        safeOpenScene(inside.safe.objects.safedoor)

                        inside.safe = nil
                        TriggerServerEvent('rm_houserobbery:server:safeOpened', inside.jobOwner)
                    end,
                },
            })

            break
        end
    end
end)

RegisterNetEvent('rm_houserobbery:client:safeOpened', function()
    if not inside then return end

    inside.safe = nil
end)

RegisterNetEvent('rm_houserobbery:client:locationSearched', function(seachableIndex)
    if not inside then return end

    inside.searchables[seachableIndex].searched = true
end)

RegisterNetEvent('rm_houserobbery:client:removeObject', function(collectableIndex)
    if not inside then return end

    inside.collectables[collectableIndex].collected = true

    local collectable = inside.collectables[collectableIndex]
    local object = GetClosestObjectOfType(collectable.coord.x, collectable.coord.y, collectable.coord.z, 0.5, collectable.model, false, false, false)
    if DoesEntityExist(object) then
        SetEntityAsMissionEntity(object)
        DeleteEntity(object)
    end
end)

RegisterNetEvent('rm_houserobbery:client:exitHouse', function()
    if inside then
        if inside.exitPoint then
            inside.exitPoint:remove()
        end
        if inside.resident?.anim?.dict then
            RemoveAnimDict(inside.resident.anim.dict)
        end
    end
    inside = nil
    sprites = {}

    FreezeEntityPosition(cache.ped, true)
    while not HasCollisionLoadedAroundEntity(cache.ped) do
        Wait(0)
    end
    DoScreenFadeIn(100)
    FreezeEntityPosition(cache.ped, false)
end)

RegisterNetEvent('rm_houserobbery:client:clearJob', function(isCancelled)
    clearJob(isCancelled)
end)

function onPlayerUnload()
    clearJob()
end

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then
        if IsScreenFadedOut() then
            DoScreenFadeIn(0)
        end

        carryItemRemoved()
    end
end)
