if cfg.editorCommand then
    RegisterCommand(cfg.editorCommand, function(source, args, rawCommand)
        if source == 0 then
            print('^1[Error]^7 This command can only be used in-game')
            return
        end
        
        -- Get player identifier (try multiple methods)
        local identifier = GetPlayerIdentifierByType(source, 'license') 
                        or GetPlayerIdentifierByType(source, 'steam')
                        or GetPlayerIdentifier(source, 0)
        
        if not identifier then
            print('^1[Error]^7 Could not get player identifier')
            return
        end
        
        -- Check if player is allowed
        if not cfg.editorAlloweds then
            print('^1[Error]^7 No editor permissions configured in cfg.lua')
            return
        end
        
        if not cfg.editorAlloweds[identifier] then
            print('^3[House Robbery]^7 Player ' .. GetPlayerName(source) .. ' (' .. identifier .. ') tried to use editor without permission')
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'House Robbery Editor',
                description = 'You do not have permission to use the editor',
                type = 'error'
            })
            return
        end
        
        print('^2[House Robbery]^7 Starting editor for ' .. GetPlayerName(source))
        TriggerClientEvent('rm_houserobbery:client:startEditor', source)
    end, false)
    
    print('^2[House Robbery]^7 Editor command registered: /' .. cfg.editorCommand)
end

RegisterNetEvent('rm_houserobbery:server:saveCoords', function(data)
    local source = source
    
    if source == 0 then return end
    
    -- Get player identifier
    local identifier = GetPlayerIdentifierByType(source, 'license') 
                    or GetPlayerIdentifierByType(source, 'steam')
                    or GetPlayerIdentifier(source, 0)
    
    if not identifier then
        print('^1[Error]^7 Could not get player identifier')
        return
    end
    
    -- Check permissions
    if not cfg.editorAlloweds or not cfg.editorAlloweds[identifier] then
        print('^1[Error]^7 Unauthorized save attempt by ' .. GetPlayerName(source))
        return
    end
    
    -- Validate data
    if not data or not data.enter or not data.keypad or not data.type then
        print('^1[Error]^7 Invalid data received')
        return
    end
    
    local file = LoadResourceFile(GetCurrentResourceName(), 'created_houses.lua')
    
    -- Create new entry with proper string formatting
    local label = data.label or 'Unnamed House'
    local houseType = data.type
    
    local entry = string.format([[
    {
        label = '%s',
        enter = vec4(%.6f, %.6f, %.6f, %.6f),
        keypad = vec4(%.6f, %.6f, %.6f, %.6f),
        type = '%s',
    },
]], 
        label,
        data.enter.x, data.enter.y, data.enter.z, data.enter.w,
        data.keypad.x, data.keypad.y, data.keypad.z, data.keypad.w,
        houseType
    )
    
    -- If file doesn't exist or is empty, create new structure
    if not file or file == '' then
        file = 'return {\n' .. entry .. '\n}'
    else
        -- Find the last closing brace and insert before it
        local lastBracePos = file:find('}[^}]*$')
        if lastBracePos then
            file = file:sub(1, lastBracePos - 1) .. entry .. file:sub(lastBracePos)
        else
            -- Fallback: append to file
            file = file .. '\n' .. entry
        end
    end
    
    -- Save file
    local success = SaveResourceFile(GetCurrentResourceName(), 'created_houses.lua', file, -1)
    
    if success then
        print('^2[House Robbery]^7 House saved successfully!')
        print('^3Label:^7 ' .. label)
        print('^3Type:^7 ' .. houseType)
        print('^3Saved by:^7 ' .. GetPlayerName(source) .. ' (' .. identifier .. ')')
        
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'House Robbery Editor',
            description = 'House saved successfully!',
            type = 'success'
        })
    else
        print('^1[Error]^7 Failed to save house data')
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'House Robbery Editor',
            description = 'Failed to save house data',
            type = 'error'
        })
    end
end)