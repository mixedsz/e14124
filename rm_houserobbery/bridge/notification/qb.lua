if cfg.notification ~= 'qb' then return end

local isClient = not IsDuplicityVersion()
if isClient then
    notify = function(text, type)
        if QBCore and QBCore.Functions.Notify then
            if type == 'info' then type = 'primary' end
            QBCore.Functions.Notify(text, type, 5000)
        end
    end

    RegisterNetEvent(('%s:client:notify'):format(cache.resource), notify)
else
    notify = function(playerId, text, type)
        TriggerClientEvent(('%s:client:notify'):format(cache.resource), playerId, text, type)
    end
end
