local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.inventory == 'auto' then
    if not GetResourceState('qb-inventory'):find('start') then
        return
    end
elseif cfg.inventory ~= 'qb-inventory' then
    return
end

RegisterNetEvent('qb-inventory:client:itemAdded', function(itemName, amount, newAmount)
    local localState = LocalPlayer.state
    if cfg.carriableItems[itemName] and not localState.hrCarry then
        localState:set('hrCarry', itemName, false)
    end
end)

RegisterNetEvent('qb-inventory:client:itemRemoved', function(itemName, amount, newAmount)
    if cfg.carriableItems[itemName] and newAmount <= 0 then
        carryItemRemoved()
    end
end)
