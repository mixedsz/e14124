cfg.missionNPCs = {
    {
        -- This is where the NPC will spawn - you can add your own locations
        coords = vec4(207.8116, 74.5358, 88.2913, 258.6321),  -- Default location
        model = `ig_joeminuteman`,  -- NPC model
        blip = {
            sprite = 380,
            color = 17,
            scale = 0.6,
            label = 'House Robbery'
        }
    },
    -- Example: Add more NPC locations
    --[[
    {
        coords = vec4(-1203.0, -733.0, 20.0, 0.0),  -- Custom location
        model = `ig_joeminuteman`,
        blip = {
            sprite = 380,
            color = 17,
            scale = 0.6,
            label = 'House Robbery'
        }
    },
    ]]
}

-- Debug: Print NPC locations when script loads
if not IsDuplicityVersion() then
    CreateThread(function()
        Wait(2000)
        print('^2[House Robbery]^7 NPC Locations:')
        for i = 1, #cfg.missionNPCs do
            local npc = cfg.missionNPCs[i]
            print(string.format('  ^3NPC %d:^7 %.2f, %.2f, %.2f', i, npc.coords.x, npc.coords.y, npc.coords.z))
        end
    end)
end