if cfg.framework == 'auto' then
    if not GetResourceState('qb-core'):find('start') then
        return
    end
elseif cfg.framework ~= 'qb' then
    return
end

QBCore = exports['qb-core']:GetCoreObject()

dispatchJobs = {'police'}

function getPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

function getPlayers()
    return QBCore.Functions.GetPlayers()
end

-- You can add additional QBCore-specific server functions here if needed