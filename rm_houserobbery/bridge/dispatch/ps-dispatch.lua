local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.dispatch ~= 'ps-dispatch' then return end

dispatch = function(data)
    exports['ps-dispatch']:CustomAlert({
        coords = data.coords.xyz,
        message = data.message,
        code = data.code,
        icon = data.icon,
        sprite = data.blip.sprite,
        color = data.blip.color,
        scale = 1.0,
        length = 3,
        jobs = data.job_types or data.job_names or { 'police', 'sasp', 'bcso', 'sheriff' },
    })
end
