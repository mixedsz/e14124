if cfg.dispatch ~= 'default_dispatch' then return end

local isClient = not IsDuplicityVersion()
if isClient then
    dispatch = function(data)
        TriggerServerEvent(('%s:server:defaultDispatch'):format(cache.resource), data)
    end

    RegisterNetEvent(('%s:client:defaultDispatch'):format(cache.resource), function(data)
        notify(('%s - %s! Check your GPS.'):format(data.code, data.message), 'info')

        local alpha = 250
        local blip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, 50.0)

        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, alpha)
        SetBlipAsShortRange(blip, true)

        while alpha ~= 0 do
            Wait(500)
            alpha = alpha - 1
            SetBlipAlpha(blip, alpha)

            if alpha == 0 then
                RemoveBlip(blip)
                return
            end
        end
    end)
else
    RegisterNetEvent(('%s:server:defaultDispatch'):format(cache.resource), function(data)
        local players = GetPlayers()
        for i = 1, #players do
            local player = getPlayer(tonumber(players[i]))
            if player and player.job then
                if lib.table.contains(dispatchJobs or { 'police', 'sasp', 'bcso', 'sheriff' }, player.job.name) and player.job.onduty ~= false then
                    TriggerClientEvent(('%s:client:defaultDispatch'):format(cache.resource), players[i], data)
                end
            end
        end
    end)
end
