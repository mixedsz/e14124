local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.dispatch ~= 'qs-dispatch' then return end

dispatch = function(data)
    TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
        job = data.job_names or { 'police', 'sasp', 'bcso', 'sheriff' },
        callLocation = data.coords.xyz,
        callCode = { code = data.code, snippet = data.message },
        message = data.message,
        flashes = true,
        blip = {
            sprite = data.blip.sprite,
            scale = 1.0,
            colour = data.blip.color,
            flashes = true,
            text = data.message,
            time = 60000, -- 1 minute
        },
    })
end
