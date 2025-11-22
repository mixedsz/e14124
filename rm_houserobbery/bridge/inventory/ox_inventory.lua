if cfg.inventory == 'auto' then
    -- qs-inventory fxmanifest has “provide ‘ox_inventory’” for some reason?
    if not GetResourceState('ox_inventory'):find('start') or GetResourceState('qs-inventory'):find('start') then
        return
    end
elseif cfg.inventory ~= 'ox_inventory' then
    return
end

local isClient = not IsDuplicityVersion()
if isClient then
    if ESX then
        RegisterNetEvent('esx:addInventoryItem', function(itemName)
            local localState = LocalPlayer.state
            if cfg.carriableItems[itemName] and not localState.hrCarry then
                localState:set('hrCarry', itemName, false)
            end
        end)

        RegisterNetEvent('esx:removeInventoryItem', function(itemName)
            if cfg.carriableItems[itemName] then
                carryItemRemoved()
            end
        end)

        return
    end

    AddEventHandler('ox_inventory:itemCount', function(itemName, totalCount)
        if cfg.carriableItems[itemName] then
            local localState = LocalPlayer.state
            if totalCount <= 0 then
                carryItemRemoved()
            elseif not localState.hrCarry then
                localState:set('hrCarry', itemName, false)
            end
        end
    end)
else
    SetTimeout(500, function()
        local itemFilter = {}
        for item in pairs(cfg.carriableItems) do
            itemFilter[item] = true
        end

        exports.ox_inventory:registerHook('swapItems', function(payload)
            if payload.toInventory ~= payload.fromInventory and (payload.toInventory == payload.source or (payload.fromInventory == payload.source and type(payload.toSlot) ~= 'number')) then
                local playerId = payload.source
                local item = payload.fromSlot
                local plyState = Player(playerId).state

                if plyState.hrCarry then
                    notify(playerId, locale('already_carrying'), 'error')
                    return false
                end
            end
        end, {
            itemFilter = itemFilter,
        })
    end)
end
