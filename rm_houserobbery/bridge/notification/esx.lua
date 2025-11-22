if cfg.notification ~= 'esx' then return end

local isClient = not IsDuplicityVersion()
if isClient then
    notify = function(text, type)
        if GetResourceState('esx_notify') ~= 'missing' then
            exports['esx_notify']:Notify(type, 5000, text)
        else
            ESX.ShowNotification(text, type, 5000)
        end
    end

    RegisterNetEvent(('%s:client:notify'):format(cache.resource), notify)
else
    notify = function(playerId, text, type)
        TriggerClientEvent(('%s:client:notify'):format(cache.resource), playerId, text, type)
    end
end
