local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.inventory == 'auto' then
    if not GetResourceState('ak47_qb_inventory'):find('start') and not GetResourceState('ak47_inventory'):find('start') then
        return
    end
elseif cfg.inventory ~= 'ak47_inventory' then
    return
end

RegisterNetEvent('ak47_inventory:onAddItem', function(item, amount, slot, has)
    local localState = LocalPlayer.state
    if cfg.carriableItems[item] and not localState.hrCarry then
        localState:set('hrCarry', item, false)
    end
end)

RegisterNetEvent('ak47_inventory:onRemoveItem', function(item, amount, slot, has)
    if cfg.carriableItems[item] then
        carryItemRemoved()
    end
end)
