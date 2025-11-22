local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.dispatch ~= 'rcore_dispatch' then return end

dispatch = function(data)
    TriggerServerEvent('rcore_dispatch:server:sendAlert', {
        code = data.code,                                                -- string -> The alert code, can be for example '10-64' or a little bit longer sentence like '10-64 - Shop robbery'
        default_priority = 'medium',                                     -- 'low' | 'medium' | 'high' -> The alert priority
        coords = data.coords.xyz,                                        -- vector3 -> The coords of the alert
        job = data.job_names or { 'police', 'sasp', 'bcso', 'sheriff' }, -- string | table -> The job, for example 'police' or a table {'police', 'ambulance'}
        text = data.message,                                             -- string -> The alert text
        type = data.message:lower():gsub('%s', '_'),                     -- alerts | shop_robbery | car_robbery | bank_robbery -> The alert type to track stats
        blip_time = 5,                                                   -- number (optional) -> The time until the blip fades
        blip = {                                                         -- Blip table (optional)
            sprite = data.blip.sprite,                                   -- number -> The blip sprite: Find them here (https://docs.fivem.net/docs/game-references/blips/#blips)
            colour = data.blip.color,                                    -- number -> The blip colour: Find them here (https://docs.fivem.net/docs/game-references/blips/#blip-colors)
            scale = 1.0,                                                 -- number -> The blip scale
            text = data.message,                                         -- number (optional) -> The blip text
            flashes = false,                                             -- boolean (optional) -> Make the blip flash
            -- radius = 0,                       -- number (optional) -> Create a radius blip instead of a normal one
        },
    })
end
