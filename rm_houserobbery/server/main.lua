local MINUTE = 60000
local activeJobs = {}
local playerCooldowns = {}
local globalCooldown = 0

-- Framework bridge functions (these would be loaded from bridge files)
function getPlayer(source)
    if ESX then
        return ESX.GetPlayerFromId(source)
    elseif QBCore then
        return QBCore.Functions.GetPlayer(source)
    end
end

function getPlayers()
    if ESX then
        return ESX.GetExtendedPlayers()
    elseif QBCore then
        return QBCore.Functions.GetPlayers()
    end
end

function addMoney(source, moneyType, amount)
    local player = getPlayer(source)
    if not player then return false end
    
    if ESX then
        if moneyType == 'cash' or moneyType == 'money' then
            player.addMoney(amount)
        elseif moneyType == 'black_money' then
            player.addAccountMoney('black_money', amount)
        end
    elseif QBCore then
        if moneyType == 'cash' or moneyType == 'money' then
            player.Functions.AddMoney('cash', amount)
        elseif moneyType == 'black_money' then
            player.Functions.AddMoney('black_money', amount)
        end
    end
    return true
end

function removeMoney(source, moneyType, amount)
    local player = getPlayer(source)
    if not player then return false end
    
    if ESX then
        if moneyType == 'cash' or moneyType == 'money' then
            return player.removeMoney(amount)
        elseif moneyType == 'black_money' then
            return player.removeAccountMoney('black_money', amount)
        end
    elseif QBCore then
        if moneyType == 'cash' or moneyType == 'money' then
            return player.Functions.RemoveMoney('cash', amount)
        elseif moneyType == 'black_money' then
            return player.Functions.RemoveMoney('black_money', amount)
        end
    end
    return false
end

function addItem(source, item, amount, metadata)
    local player = getPlayer(source)
    if not player then return false end
    
    if oxInv then
        return oxInv:AddItem(source, item, amount, metadata)
    elseif ESX then
        player.addInventoryItem(item, amount)
        return true
    elseif QBCore then
        return player.Functions.AddItem(item, amount, nil, metadata)
    end
    return false
end

function removeItem(source, item, amount)
    local player = getPlayer(source)
    if not player then return false end
    
    if oxInv then
        return oxInv:RemoveItem(source, item, amount)
    elseif ESX then
        player.removeInventoryItem(item, amount)
        return true
    elseif QBCore then
        return player.Functions.RemoveItem(item, amount)
    end
    return false
end

function getItemCount(source, item)
    local player = getPlayer(source)
    if not player then return 0 end
    
    if oxInv then
        return oxInv:GetItemCount(source, item)
    elseif ESX then
        local item = player.getInventoryItem(item)
        return item and item.count or 0
    elseif QBCore then
        local item = player.Functions.GetItemByName(item)
        return item and item.amount or 0
    end
    return 0
end

-- Police count check
local function getPoliceCount()
    if cfg.enableOldMethodForPoliceCount then
        local count = 0
        local players = getPlayers()
        
        for i = 1, #players do
            local player = getPlayer(players[i])
            if player and player.job then
                if lib.table.contains(dispatchJobs or {'police', 'sasp', 'bcso', 'sheriff'}, player.job.name) then
                    if player.job.onduty ~= false then
                        count = count + 1
                    end
                end
            end
        end
        
        return count
    else
        -- Modern method using state bags
        local count = 0
        local players = GetPlayers()
        
        for i = 1, #players do
            local player = tonumber(players[i])
            local state = Player(player).state
            
            if state.job then
                if lib.table.contains(dispatchJobs or {'police', 'sasp', 'bcso', 'sheriff'}, state.job.name) then
                    if state.job.onduty ~= false then
                        count = count + 1
                    end
                end
            end
        end
        
        return count
    end
end

-- Helper function to request model on server
local function requestModel(model)
    local modelHash = type(model) == 'string' and GetHashKey(model) or model
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        local timeout = GetGameTimer() + 10000
        while not HasModelLoaded(modelHash) and GetGameTimer() < timeout do
            Wait(0)
        end
    end
    return HasModelLoaded(modelHash)
end

-- Create a random house job
lib.callback.register('rm_houserobbery:server:createJob', function(source)
    local currentTime = GetGameTimer()
    
    -- Check global cooldown
    if globalCooldown > currentTime then
        notify(source, locale('cooldown_error', math.floor((globalCooldown - currentTime) / MINUTE), math.floor(((globalCooldown - currentTime) % MINUTE) / 1000)), 'error')
        return nil
    end
    
    -- Check police count
    local policeCount = getPoliceCount()
    if policeCount < cfg.requiredPoliceCount then
        notify(source, locale('not_enough_police'), 'error')
        return nil
    end
    
    -- Get available houses
    local availableHouses = {}
    for i = 1, #cfg.houses do
        local house = cfg.houses[i]
        local isOccupied = false
        
        for jobOwner, jobData in pairs(activeJobs) do
            if jobData.houseIndex == i then
                isOccupied = true
                break
            end
        end
        
        if not isOccupied then
            availableHouses[#availableHouses + 1] = {
                index = i,
                data = house
            }
        end
    end
    
    if #availableHouses == 0 then
        notify(source, locale('all_jobs_received'), 'error')
        return nil
    end
    
    -- Select random house
    local selectedHouse = availableHouses[math.random(#availableHouses)]
    local houseType = cfg.houseTypes[selectedHouse.data.type]
    
    if not houseType then
        print('^1[Error]^7 House type not found: ' .. selectedHouse.data.type)
        return nil
    end
    
    -- Create job data
    local jobData = {
        houseIndex = selectedHouse.index,
        coords = selectedHouse.data,
        type = selectedHouse.data.type,
        interior = lib.table.deepclone(houseType.interior),
        exit = houseType.exit,
        safe = houseType.safe and {
            chance = houseType.safe.chance,
            coords = lib.table.deepclone(houseType.safe.coords),
            broken = false,
            opened = false
        } or nil,
        searchables = {},
        collectables = {},
        resident = nil,
        startTime = currentTime,
        jobOwner = source
    }
    
    -- Setup searchable locations
    for i = 1, #houseType.searchables do
        jobData.searchables[i] = {
            coord = houseType.searchables[i].coord,
            searched = false
        }
    end
    
    -- Setup collectable items
    for i = 1, #houseType.collectables do
        jobData.collectables[i] = {
            coord = houseType.collectables[i].coord,
            model = houseType.collectables[i].model,
            item = houseType.collectables[i].item,
            collected = false
        }
    end
    
    -- Setup resident (random chance)
    if houseType.resident and math.random(100) <= houseType.resident.chance then
        jobData.resident = {
            model = houseType.resident.model,
            coord = houseType.resident.coord,
            anim = houseType.resident.anim,
            alerted = false
        }
    end
    
    -- Store job
    activeJobs[source] = jobData
    
    -- Set global cooldown
    if cfg.cooldowns.global > 0 then
        globalCooldown = currentTime + (cfg.cooldowns.global * MINUTE)
    end
    
    -- Create broken keypad entity
    requestModel(`ch_prop_fingerprint_scanner_01x`)
    local keypad = CreateObject(`ch_prop_fingerprint_scanner_01x`, selectedHouse.data.keypad.x, selectedHouse.data.keypad.y, selectedHouse.data.keypad.z, true, true, false)
    SetEntityHeading(keypad, selectedHouse.data.keypad.w)
    FreezeEntityPosition(keypad, true)
    
    Entity(keypad).state:set('hrEnter', {
        enter = selectedHouse.data.enter,
        jobOwner = source
    }, true)
    
    jobData.keypadEntity = keypad
    
    -- Auto-cleanup after robbery duration
    SetTimeout((cfg.robberyDuration or 30) * MINUTE, function()
        if activeJobs[source] then
            TriggerClientEvent('rm_houserobbery:client:clearJob', source, false)
            TriggerClientEvent('rm_houserobbery:client:exitHouse', source)
            
            if DoesEntityExist(jobData.keypadEntity) then
                DeleteEntity(jobData.keypadEntity)
            end
            
            activeJobs[source] = nil
        end
    end)
    
    return jobData
end)

-- Keypad disrupted
lib.callback.register('rm_houserobbery:server:keypadDisrupted', function(source)
    local jobData = activeJobs[source]
    if not jobData then return nil end
    
    if DoesEntityExist(jobData.keypadEntity) then
        DeleteEntity(jobData.keypadEntity)
    end
    
    requestModel(`ch_prop_fingerprint_scanner_01x`)
    local brokenKeypad = CreateObject(`ch_prop_fingerprint_scanner_01x`, jobData.coords.keypad.x, jobData.coords.keypad.y, jobData.coords.keypad.z, true, true, false)
    
    jobData.keypadEntity = brokenKeypad
    
    Entity(brokenKeypad).state:set('hrEnter', {
        enter = jobData.coords.enter,
        jobOwner = source
    }, true)
    
    return NetworkGetNetworkIdFromEntity(brokenKeypad)
end)

-- Enter house
RegisterNetEvent('rm_houserobbery:server:enterHouse', function(jobOwner)
    local source = source
    local jobData = activeJobs[jobOwner]
    if not jobData then return end
    
    -- Create interior if needed
    if not jobData.interior.id then
        local interiorId = GetInteriorAtCoords(jobData.exit.x, jobData.exit.y, jobData.exit.z)
        jobData.interior.id = interiorId
    end
    
    -- Spawn resident NPC if exists
    if jobData.resident and not jobData.resident.netId then
        requestModel(jobData.resident.model)
        local ped = CreatePed(4, jobData.resident.model, jobData.resident.coord.x, jobData.resident.coord.y, jobData.resident.coord.z, jobData.resident.coord.w, true, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityInvincible(ped, false)
        
        jobData.resident.netId = NetworkGetNetworkIdFromEntity(ped)
    end
    
    -- Teleport player to interior
    SetEntityCoords(GetPlayerPed(source), jobData.exit.x, jobData.exit.y, jobData.exit.z, false, false, false, false)
    SetEntityHeading(GetPlayerPed(source), jobData.exit.w)
    
    TriggerClientEvent('rm_houserobbery:client:enterHouse', source, jobData)
end)

-- Exit house
RegisterNetEvent('rm_houserobbery:server:exitHouse', function(jobOwner)
    local source = source
    local jobData = activeJobs[jobOwner]
    if not jobData then
        local fallback = cfg.fallbackExitCoord or vec4(0, 0, 70, 0)
        SetEntityCoords(GetPlayerPed(source), fallback.x, fallback.y, fallback.z, false, false, false, false)
        SetEntityHeading(GetPlayerPed(source), fallback.w)
        TriggerClientEvent('rm_houserobbery:client:exitHouse', source)
        return
    end
    
    -- Teleport player outside
    SetEntityCoords(GetPlayerPed(source), jobData.coords.enter.x, jobData.coords.enter.y, jobData.coords.enter.z, false, false, false, false)
    SetEntityHeading(GetPlayerPed(source), jobData.coords.enter.w)
    
    TriggerClientEvent('rm_houserobbery:client:exitHouse', source)
    
    -- Check if job is complete
    local allSearched = true
    local allCollected = true
    
    for _, searchable in pairs(jobData.searchables) do
        if not searchable.searched then
            allSearched = false
            break
        end
    end
    
    for _, collectable in pairs(jobData.collectables) do
        if not collectable.collected then
            allCollected = false
            break
        end
    end
    
    if allSearched and allCollected and (not jobData.safe or jobData.safe.opened) then
        if jobOwner == source then
            notify(source, locale('job_finished'), 'success')
            
            -- Set player cooldown
            if cfg.cooldowns.player > 0 then
                playerCooldowns[source] = GetGameTimer() + (cfg.cooldowns.player * MINUTE)
            end
        end
    elseif jobOwner == source and cfg.showJobIsNotCompletelyFinishedWarning then
        notify(source, locale('not_completely_finished'), 'error')
    end
end)

-- Safe broken
RegisterNetEvent('rm_houserobbery:server:safeBroken', function(jobOwner)
    local jobData = activeJobs[jobOwner]
    if not jobData or not jobData.safe then return end
    
    jobData.safe.broken = true
    
    -- Notify all players in the house
    local players = GetPlayers()
    for i = 1, #players do
        local player = tonumber(players[i])
        if player ~= source then
            TriggerClientEvent('rm_houserobbery:client:safeBroken', player)
        end
    end
end)

-- Safe opened
RegisterNetEvent('rm_houserobbery:server:safeOpened', function(jobOwner)
    local source = source
    local jobData = activeJobs[jobOwner]
    if not jobData or not jobData.safe then return end
    
    jobData.safe.opened = true
    
    -- Give rewards
    local safeRewards = cfg.safeRewards
    if not safeRewards then return end
    
    local emptyRoll = math.random(100)
    if emptyRoll <= safeRewards.emptyChance then
        notify(source, locale('empty'), 'info')
    else
        local itemCount = type(safeRewards.itemCount) == 'table' and math.random(safeRewards.itemCount[1], safeRewards.itemCount[2]) or safeRewards.itemCount
        
        local availableItems = {}
        for item, data in pairs(safeRewards.items) do
            if math.random(100) <= data.chance then
                availableItems[#availableItems + 1] = {item = item, data = data}
            end
        end
        
        for i = 1, math.min(itemCount, #availableItems) do
            local selected = availableItems[math.random(#availableItems)]
            
            if selected.item == 'money' and selected.data.type then
                local amount = type(selected.data.amount) == 'table' and math.random(selected.data.amount[1], selected.data.amount[2]) or selected.data.amount
                addMoney(source, selected.data.type, amount)
            else
                local amount = type(selected.data.amount) == 'table' and math.random(selected.data.amount[1], selected.data.amount[2]) or selected.data.amount
                addItem(source, selected.item, amount)
            end
        end
    end
    
    -- Notify all players in the house
    local players = GetPlayers()
    for i = 1, #players do
        local player = tonumber(players[i])
        if player ~= source then
            TriggerClientEvent('rm_houserobbery:client:safeOpened', player)
        end
    end
end)

-- Location searched
RegisterNetEvent('rm_houserobbery:server:locationSearched', function(jobOwner, searchableIndex)
    local source = source
    local jobData = activeJobs[jobOwner]
    if not jobData or not jobData.searchables[searchableIndex] then return end
    
    jobData.searchables[searchableIndex].searched = true
    
    -- Give rewards
    local rewards = cfg.searchRewards[jobData.type]
    if not rewards then return end
    
    local emptyRoll = math.random(100)
    if emptyRoll <= rewards.emptyChance then
        notify(source, locale('empty'), 'info')
    else
        local itemCount = type(rewards.itemCount) == 'table' and math.random(rewards.itemCount[1], rewards.itemCount[2]) or rewards.itemCount
        
        local availableItems = {}
        for item, data in pairs(rewards.items) do
            if math.random(100) <= data.chance then
                availableItems[#availableItems + 1] = {item = item, data = data}
            end
        end
        
        for i = 1, math.min(itemCount, #availableItems) do
            local selected = availableItems[math.random(#availableItems)]
            local amount = type(selected.data.amount) == 'table' and math.random(selected.data.amount[1], selected.data.amount[2]) or selected.data.amount
            addItem(source, selected.item, amount)
        end
    end
    
    -- Notify other players
    local players = GetPlayers()
    for i = 1, #players do
        local player = tonumber(players[i])
        if player ~= source then
            TriggerClientEvent('rm_houserobbery:client:locationSearched', player, searchableIndex)
        end
    end
end)

-- Object collected
RegisterNetEvent('rm_houserobbery:server:objectCollected', function(jobOwner, collectableIndex)
    local source = source
    local jobData = activeJobs[jobOwner]
    if not jobData or not jobData.collectables[collectableIndex] then return end
    
    local collectable = jobData.collectables[collectableIndex]
    collectable.collected = true
    
    -- Give item
    addItem(source, collectable.item, 1)
    
    -- Notify other players to remove object
    local players = GetPlayers()
    for i = 1, #players do
        local player = tonumber(players[i])
        if player ~= source then
            TriggerClientEvent('rm_houserobbery:client:removeObject', player, collectableIndex)
        end
    end
end)

-- Resident alerted
RegisterNetEvent('rm_houserobbery:server:residentAlerted', function(jobOwner)
    local source = source
    local jobData = activeJobs[jobOwner]
    if not jobData or not jobData.resident then return end
    
    if jobData.resident.alerted then return end
    jobData.resident.alerted = true
    
    -- Notify all players in the house
    local players = GetPlayers()
    for i = 1, #players do
        local player = tonumber(players[i])
        TriggerClientEvent('rm_houserobbery:client:residentAlerted', player, jobData.resident.netId, {
            firstPlayer = source,
            coords = jobData.coords.keypad
        })
    end
end)

-- Cancel job
RegisterNetEvent('rm_houserobbery:server:cancelJob', function(data, sendClient)
    local source = source
    local jobData = activeJobs[source]
    if not jobData then return end
    
    if DoesEntityExist(jobData.keypadEntity) then
        DeleteEntity(jobData.keypadEntity)
    end
    
    if jobData.resident and jobData.resident.netId then
        local ped = NetworkGetEntityFromNetworkId(jobData.resident.netId)
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    
    activeJobs[source] = nil
    
    if sendClient then
        TriggerClientEvent('rm_houserobbery:client:clearJob', source, true)
    end
end)

-- Buy items
RegisterNetEvent('rm_houserobbery:server:buy', function(item, quantity)
    local source = source
    if not cfg.buy or not cfg.buy[item] then return end
    
    local price = cfg.buy[item].price * quantity
    
    if removeMoney(source, 'money', price) then
        addItem(source, item, quantity)
    else
        notify(source, locale('insufficient_money'), 'error')
    end
end)

-- Sell items
RegisterNetEvent('rm_houserobbery:server:sell', function(item, quantity)
    local source = source
    if not cfg.sell or not cfg.sell[item] or not cfg.sell[item].price then return end
    
    local itemCount = getItemCount(source, item)
    if itemCount < quantity then
        notify(source, locale('insufficient_item'), 'error')
        return
    end
    
    local price = cfg.sell[item].price * quantity
    
    if removeItem(source, item, quantity) then
        addMoney(source, 'money', price)
    end
end)

-- Trade items
RegisterNetEvent('rm_houserobbery:server:trade', function(item, quantity)
    local source = source
    if not cfg.sell or not cfg.sell[item] or not cfg.sell[item].tradeItems then return end
    
    local itemCount = getItemCount(source, item)
    if itemCount < quantity then
        notify(source, locale('insufficient_item'), 'error')
        return
    end
    
    if removeItem(source, item, quantity) then
        for _, tradeItem in pairs(cfg.sell[item].tradeItems) do
            addItem(source, tradeItem.item, tradeItem.quantity * quantity)
        end
    end
end)

-- Bulk sale
RegisterNetEvent('rm_houserobbery:server:bulkSale', function()
    local source = source
    if not cfg.sell then return end
    
    local totalMoney = 0
    
    for item, data in pairs(cfg.sell) do
        if data.price and data.price > 0 then
            local itemCount = getItemCount(source, item)
            if itemCount > 0 then
                if removeItem(source, item, itemCount) then
                    totalMoney = totalMoney + (data.price * itemCount)
                end
            end
        end
    end
    
    if totalMoney > 0 then
        addMoney(source, 'money', totalMoney)
    end
end)

-- Cleanup on player drop
AddEventHandler('playerDropped', function()
    local source = source
    if activeJobs[source] then
        if DoesEntityExist(activeJobs[source].keypadEntity) then
            DeleteEntity(activeJobs[source].keypadEntity)
        end
        
        if activeJobs[source].resident and activeJobs[source].resident.netId then
            local ped = NetworkGetEntityFromNetworkId(activeJobs[source].resident.netId)
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
        
        activeJobs[source] = nil
    end
end)