if cfg.notification ~= 'okokNotify' then return end

local isClient = not IsDuplicityVersion()
if isClient then
    notify = function(text, type)
        if type == 'inform' then type = 'info' end
        exports['okokNotify']:Alert('', text, 5000, type, false)
    end

    RegisterNetEvent(('%s:client:notify'):format(cache.resource), notify)
else
    notify = function(playerId, text, type)
        TriggerClientEvent(('%s:client:notify'):format(cache.resource), playerId, text, type)
    end
end
