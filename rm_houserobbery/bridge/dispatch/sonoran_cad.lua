local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.dispatch ~= 'sonoran_cad' then return end

local getStreetAndZone = function(coords)
    local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    return street .. ', ' .. zone
end

dispatch = function(data)
    local streetZone = getStreetAndZone(data.coords)

    TriggerServerEvent('SonoranCAD::callcommands:SendCallApi', true, 'Bystander', streetZone, data.message, cache.serverId, nil, nil, '911')
end
