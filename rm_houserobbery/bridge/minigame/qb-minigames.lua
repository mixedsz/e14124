if cfg.minigame ~= 'qb-minigames' then return end

minigames = {}
minigames['safe'] = function()
    local results = exports['qb-minigames']:KeyMinigame(10)

    return not result.quit and result.faults < 3 or false
end

-- -- remove from comment line to activate
-- minigames['collect'] = function()
--     local results = exports['qb-minigames']:KeyMinigame(10)

--     return not result.quit and result.faults < 3 or false
-- end

-- minigames['seach'] = function()
--     local results = exports['qb-minigames']:KeyMinigame(10)

--     return not result.quit and result.faults < 3 or false
-- end
