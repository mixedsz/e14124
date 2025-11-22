if cfg.framework == 'auto' then
    if not GetResourceState('qb-core'):find('start') then
        return
    end
elseif cfg.framework ~= 'qb' then
    return
end

QBCore = exports['qb-core']:GetCoreObject()
deadState = nil

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    local playerData = QBCore.Functions.GetPlayerData()
    deadState = playerData.metadata.isdead or playerData.metadata.inlaststand
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    if (data.metadata.isdead or data.metadata.inlaststand) ~= deadState then
        deadState = data.metadata.isdead or data.metadata.inlaststand

        if cfg.autoExitOnDeath and deadState then
            onPlayerDeath()
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deadState = nil
    onPlayerUnload()
end)
