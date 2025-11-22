if cfg.minigame ~= 'bl_ui' then return end

minigames = {}
minigames['safe'] = function()
    return exports['bl_ui']:CircleProgress(1, 50)
end

-- -- remove from comment line to activate
-- minigames['collect'] = function()
--     return exports['bl_ui']:CircleProgress(1, 50)
-- end

-- minigames['search'] = function()
--     return exports['bl_ui']:CircleProgress(1, 50)
-- end
