if cfg.minigame ~= 'ps-ui' then return end

minigames = {}
minigames['safe'] = function()
    local p = promise:new()

    exports['ps-ui']:Circle('normal', function(success)
        p:resolve(success)
    end)

    return Citizen.Await(p)
end

-- -- remove from comment line to activate
-- minigames['collect'] = function()
--     local p = promise:new()

--     exports['ps-ui']:Circle('normal', function(success)
--         p:resolve(success)
--     end)

--     return Citizen.Await(p)
-- end

-- minigames['search'] = function()
--     local p = promise:new()

--     exports['ps-ui']:Circle('normal', function(success)
--         p:resolve(success)
--     end)

--     return Citizen.Await(p)
-- end
