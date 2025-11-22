if cfg.minigame ~= 'ox_lib' then return end

minigames = {}
minigames['safe'] = function()
    return lib.skillCheck('medium')
end

-- -- remove from comment line to activate
-- minigames['collect'] = function()
--     return lib.skillCheck('medium')
-- end

-- minigames['search'] = function()
--     return lib.skillCheck('medium')
-- end
