if cfg.minigame ~= 'rm_minigames' then return end

minigames = {}
minigames['safe'] = function()
    return exports['rm_minigames']:quickTimeEvent('normal')
end

-- -- remove from comment line to activate
-- minigames['collect'] = function()
--     return exports['rm_minigames']:quickTimeEvent('normal')
-- end

-- minigames['search'] = function()
--     return exports['rm_minigames']:quickTimeEvent('normal')
-- end
