local editor = false

RegisterNetEvent('rm_houserobbery:client:startEditor', function()
    if editor then return end

    editor = true
    local data = {}
    local spawnCoords = GetEntityCoords(cache.ped)

    textUI.show(
        '[ Q/E ] Rotate  \n' ..
        '[ Mouse Scroll ] Adjust distance from surface  \n' ..
        '[ Mouse Left ] Save  \n' ..
        '[ Backspace ] Cancel'
    )

    local pedModel = `s_m_y_dealer_01`
    local keypadModel = `ch_prop_fingerprint_scanner_01e`
    lib.requestModel(keypadModel)
    local keypad, ped = CreateObject(keypadModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, true, false)

    local hit, hitEntity, endCoords, surfaceNormal
    CreateThread(function()
        while editor do
            hit, hitEntity, endCoords, surfaceNormal = lib.raycast.fromCamera(1, 4, 15)
            Wait(5)
        end
    end)

    local offset = 0.05
    local heading = GetEntityHeading(cache.ped)
    while editor do
        DisablePlayerFiring(cache.playerId, true)
        DisableControlAction(0, 16, true)
        DisableControlAction(0, 17, true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 44, true)
        DisableControlAction(0, 45, true)
        DisableControlAction(0, 46, true)

        if IsDisabledControlJustReleased(0, 194) then
            editor = false
        end

        if endCoords then
            if IsDisabledControlPressed(0, 16) then
                offset -= 0.01
                if offset < -0.3 then offset = -0.3 end
            elseif IsDisabledControlPressed(0, 17) then
                offset += 0.01
                if offset > 0.3 then offset = 0.3 end
            end

            local targetCoords = vector3(
                endCoords.x + (surfaceNormal.x * offset),
                endCoords.y + (surfaceNormal.y * offset),
                endCoords.z + (surfaceNormal.z * offset)
            )

            DrawSphere(targetCoords.x, targetCoords.y, targetCoords.z, 0.03, 241, 93, 56, 0.7)
            if hit then
                if IsDisabledControlPressed(0, 44) then
                    heading -= 0.5
                    if heading < 0 then heading = 360 end
                elseif IsDisabledControlPressed(0, 46) then
                    heading += 0.5
                    if heading > 360 then heading = 0 end
                end

                if not data.keypad then
                    SetEntityCoords(keypad, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false, false)
                    SetEntityHeading(keypad, heading)
                elseif not data.enter then
                    SetEntityCoords(ped, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false, false)
                    SetEntityHeading(ped, heading)
                end

                if IsDisabledControlJustReleased(0, 24) then
                    if not data.keypad then
                        data.keypad = vec4(targetCoords.x, targetCoords.y, targetCoords.z, heading)

                        lib.requestModel(pedModel)
                        ped = CreatePed(0, pedModel, targetCoords.x, targetCoords.y, targetCoords.z, heading, false, true)
                        FreezeEntityPosition(ped, true)
                        SetBlockingOfNonTemporaryEvents(ped, true)
                        SetEntityInvincible(ped, true)

                        offset = 0.05
                    else
                        data.enter = vec4(targetCoords.x, targetCoords.y, targetCoords.z, heading)

                        break
                    end
                end
            end
        end
        Wait(1)
    end

    textUI.hide()

    DeleteEntity(keypad)
    DeleteEntity(ped)

    SetModelAsNoLongerNeeded(keypadModel)
    SetModelAsNoLongerNeeded(pedModel)

    if editor then
        editor = false

        local options = {}
        for houseType in pairs(cfg.houseTypes) do
            options[#options + 1] = { value = houseType }
        end

        local input = lib.inputDialog('House Robbery', {
            { type = 'input', label = 'House Label' },
            { type = 'select', label = 'House Type', required = true, default = options[1], options = options },
        })

        if not input then return end

        data.label = input[1]
        data.type = input[2]
        TriggerServerEvent('rm_houserobbery:server:saveCoords', data)
    end
end)
