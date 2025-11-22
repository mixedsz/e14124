local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.dispatch ~= 'redutzu-mdt' then return end

local getStreetAndZone = function(coords)
    local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    return street .. ', ' .. zone
end

dispatch = function(data)
    TriggerServerEvent('redutzu-mdt:server:sendDispatchMessage', {
        code = data.code,
        title = data.message,
        coords = data.coords.xyz,
        street = getStreetAndZone(data.coords),
        duration = 600000, --ms
    })
end
