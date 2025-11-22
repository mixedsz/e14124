if cfg.dispatch ~= 'lb-tablet' then return end

local isClient = not IsDuplicityVersion()
if isClient then
    local getStreetAndZone = function(coords)
        local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
        local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
        return street .. ', ' .. zone
    end

    dispatch = function(data)
        data.location = {
            label = getStreetAndZone(data.coords),
            coords = vec2(data.coords.x, data.coords.y),
        }
        TriggerServerEvent(('%s:server:lb-tabletDispatch'):format(cache.resource), data)
    end
else
    RegisterNetEvent(('%s:server:lb-tabletDispatch'):format(cache.resource), function(data)
        exports['lb-tablet']:AddDispatch({
            priority = 'medium',
            location = data.location,
            time = 600,
            job = 'police',
            code = data.code,
            title = data.message,
            description = '',
        })
    end)
end
