local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.dispatch ~= 'tk_dispatch' then return end

dispatch = function(data)
    exports.tk_dispatch:addCall({
        title = data.message,
        code = data.code,
        coords = data.coords,
        showLocation = true,
        playSound = true,
        blip = {
            color = data.blip.color,
            sprite = data.blip.sprite,
            scale = 1.0,
        },
        jobs = data.job_names or { 'police', 'sasp', 'bcso', 'sheriff' },
    })
end
