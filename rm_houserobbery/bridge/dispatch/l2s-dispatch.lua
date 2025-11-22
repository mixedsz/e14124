local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.dispatch ~= 'l2s-dispatch' then return end

dispatch = function(data)
    TriggerServerEvent('l2s-dispatch:server:AddNotification', {
        departments = { 'POLICE' },
        title = ('%s - %s'):format(data.code, data.message),
        message = data.message,
        coords = vec2(data.coords.x, data.coords.y),
        priority = 2,
        sound = 2,
        street = playerData.street,
        reply = playerData.source,
        anonymous = false,
        blip = {
            sprite = data.blip.sprite,
            colour = data.blip.color,
            scale = 1.0,
            text = ('%s - %s'):format(data.code, data.message),
        },
    })
end
