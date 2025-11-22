if cfg.framework == 'auto' then
    if not GetResourceState('es_extended'):find('start') then
        return
    end
elseif cfg.framework ~= 'esx' then
    return
end

ESX = exports['es_extended']:getSharedObject()

dispatchJobs = {'police'}

function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function getPlayers()
    return ESX.GetExtendedPlayers()
end

-- You can add additional ESX-specific server functions here if needed