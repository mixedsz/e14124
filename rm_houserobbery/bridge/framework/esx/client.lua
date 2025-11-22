if cfg.framework == 'auto' then
    if not GetResourceState('es_extended'):find('start') then
        return
    end
elseif cfg.framework ~= 'esx' then
    return
end

ESX = exports['es_extended']:getSharedObject()
deadState = nil

AddStateBagChangeHandler('isDead', ('player:%s'):format(cache.serverId), function(bagName, key, value, reserved, replicated)
    deadState = value

    if cfg.autoExitOnDeath and deadState then
        onPlayerDeath()
    end
end)
