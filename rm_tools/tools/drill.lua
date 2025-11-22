local isServer = IsDuplicityVersion()

if isServer then
    if cfg.enableDurability and reduceDurability then
        AddStateBagChangeHandler('rm_tools:drillEffect', nil, function(bagName, key, value, reserved, replicated)
            Wait(50)
            local playerId = GetPlayerFromStateBagName(bagName)
            
            if not value or not value.slot then
                players[playerId] = nil
                return
            end
            
            reduceDurability(playerId, value.slot, value.itemName)
            players[playerId] = {
                lastTime = GetGameTimer(),
                slot = value.slot,
                item = value.itemName
            }
        end)
    end
else
    -- Client side
    local particleSettings = cfg.drillSettings and cfg.drillSettings.particle or {
        assetName = "des_bigjobdrill",
        fxName = "ent_ray_big_drill_sparks",
        offset = vec3(0.619507, 0.003998, -0.132999),
        scale = 1.0
    }
    
    local particleFx = {}
    local soundIds = {}
    
    -- Cache native functions for performance
    local DisablePlayerFiring = DisablePlayerFiring
    local DisableControlAction = DisableControlAction
    local DisplayAmmoThisFrame = DisplayAmmoThisFrame
    local IsPlayerFreeAiming = IsPlayerFreeAiming
    local GetCurrentPedWeapon = GetCurrentPedWeapon
    local IsDisabledControlPressed = IsDisabledControlPressed
    local IsDisabledControlJustReleased = IsDisabledControlJustReleased
    local IsDisabledControlJustPressed = IsDisabledControlJustPressed
    local DoesEntityExist = DoesEntityExist
    local GetCurrentPedWeaponEntityIndex = GetCurrentPedWeaponEntityIndex
    local HasSoundFinished = HasSoundFinished
    local PlaySoundFromEntity = PlaySoundFromEntity
    local ShakeGameplayCam = ShakeGameplayCam
    local StopGameplayCamShaking = StopGameplayCamShaking
    
    local function stopDrillEffects(playerId)
        -- Stop particle effects
        if not cfg.disableParticles and particleFx[playerId] then
            StopParticleFxLooped(particleFx[playerId], false)
            RemoveNamedPtfxAsset(particleSettings.assetName)
            particleFx[playerId] = nil
        end
        
        -- Stop sound effects
        if soundIds[playerId] then
            StopSound(soundIds[playerId])
            ReleaseSoundId(soundIds[playerId])
            ReleaseNamedScriptAudioBank("DLC_HEIST_FLEECA_SOUNDSET")
            soundIds[playerId] = nil
        end
    end
    
    AddStateBagChangeHandler('rm_tools:drillEffect', nil, function(bagName, key, value, reserved, replicated)
        Wait(50)
        local playerId = GetPlayerFromStateBagName(bagName)
        local ped = GetPlayerPed(playerId)
        
        if not value then
            stopDrillEffects(playerId)
            return
        end
        
        -- Wait for drill weapon object to exist
        local drillObj = lib.waitFor(function()
            local _, weaponHash = GetCurrentPedWeapon(ped)
            if weaponHash == weaponHashes.drill then
                return GetCurrentPedWeaponEntityIndex(ped)
            end
            Wait(50)
        end, "Failed to get WEAPON_DRILL object", 5000)
        
        -- Monitor object existence
        CreateThread(function()
            while DoesEntityExist(drillObj) and DoesEntityExist(ped) do
                Wait(1000)
            end
            stopDrillEffects(playerId)
        end)
        
        -- Start particle effects
        if not cfg.disableParticles and not particleFx[playerId] then
            lib.requestNamedPtfxAsset(particleSettings.assetName)
            UseParticleFxAsset(particleSettings.assetName)
            particleFx[playerId] = StartParticleFxLoopedOnEntity(
                particleSettings.fxName,
                drillObj,
                particleSettings.offset.x,
                particleSettings.offset.y,
                particleSettings.offset.z,
                0.0, 0.0, 0.0,
                particleSettings.scale,
                false, false, false
            )
        end
        
        -- Start sound effects
        if not soundIds[playerId] then
            soundIds[playerId] = GetSoundId()
            
            while not RequestScriptAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", false) do
                Wait(25)
            end
            while not RequestScriptAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", false) do
                Wait(25)
            end
            
            PlaySoundFromEntity(soundIds[playerId], "Drill", drillObj, "DLC_HEIST_FLEECA_SOUNDSET", false, 0)
            
            while soundIds[playerId] do
                if HasSoundFinished(soundIds[playerId]) then
                    PlaySoundFromEntity(soundIds[playerId], "Drill", drillObj, "DLC_HEIST_FLEECA_SOUNDSET", false, 0)
                end
                Wait(10)
            end
        end
    end)
    
    function removeDrill()
        if not using then return end
        
        RemoveWeaponFromPed(cache.ped, weaponHashes.drill)
        StopGameplayCamShaking(true)
        
        using = nil
        obj = nil
        
        setStatebag('drillEffect', nil)
    end
    
    function initDrill(data)
        if using == 'drill' then return end
        
        local slot = nil
        local durability = nil
        local itemName = nil
        
        if cfg.enableDurability and data then
            if data.durability and data.durability <= 0 then
                Wait(750)
                removeDrill()
                return
            end
            slot = data.slot
            durability = data.durability
            itemName = data.name
        end
        
        -- Wait for drill object
        obj = lib.waitFor(function()
            local _, weaponHash = GetCurrentPedWeapon(cache.ped)
            if weaponHash == weaponHashes.drill and cache.weapon == weaponHash then
                return GetCurrentPedWeaponEntityIndex(cache.ped)
            end
            Wait(50)
        end, "Failed to get WEAPON_DRILL object", 5000)
        
        using = 'drill'
        TriggerEvent('rm_tools:usageStarted', 'drill')
        
        local isActive = nil
        
        while using do
            if cache.vehicle or not DoesEntityExist(obj) or cache.weapon ~= weaponHashes.drill then
                removeDrill()
                break
            end
            
            DisablePlayerFiring(cache.playerId, false)
            DisableControlAction(0, 24, true)   -- INPUT_ATTACK
            DisableControlAction(0, 140, true)  -- INPUT_MELEE_ATTACK_LIGHT
            DisableControlAction(0, 141, true)  -- INPUT_MELEE_ATTACK_HEAVY
            DisableControlAction(0, 142, true)  -- INPUT_MELEE_ATTACK_ALTERNATE
            DisplayAmmoThisFrame(false)
            
            if IsPlayerFreeAiming(cache.playerId) then
                if not isActive and IsDisabledControlJustPressed(0, 24) then
                    isActive = true
                    setStatebag('drillEffect', {
                        slot = slot,
                        itemName = itemName
                    })
                elseif isActive and not IsDisabledControlPressed(0, 24) then
                    isActive = false
                    setStatebag('drillEffect', nil)
                end
            elseif isActive then
                isActive = false
                setStatebag('drillEffect', nil)
            end
            
            Wait(1)
        end
        
        TriggerEvent('rm_tools:usageFinished', 'drill')
    end
    
    exports('isDrillUsing', function()
        return using == 'drill'
    end)
    
    exports('getDrillObject', function()
        return using == 'drill' and obj or nil
    end)
    
    exports('removeDrill', removeDrill)
end