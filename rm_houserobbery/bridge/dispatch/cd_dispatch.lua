local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.dispatch ~= 'cd_dispatch' then return end

dispatch = function(data)
    local _data = exports['cd_dispatch']:GetPlayerInfo()
    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = data.job_names or { 'police', 'sasp', 'bcso', 'sheriff' },
        coords = data.coords.xyz,
        title = ('%s - %s'):format(data.code, data.message),
        message = data.message,
        flash = 0,
        unique_id = _data.unique_id,
        sound = 1,
        blip = {
            sprite = data.blip.sprite,
            scale = 1.0,
            colour = data.blip.color,
            flashes = false,
            text = data.message,
            time = 5,
            radius = 0,
        },
    })
end
