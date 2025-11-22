local carryObj
local defaultAnimFlag = 1 | 8 | 16 | 32

AddStateBagChangeHandler('hrCarry', ('player:%s'):format(cache.serverId), function(bagName, key, item, reserved, replicated)
    if carryObj or not item then return end

    local carryData = cfg.carriableItems[item]
    if not carryData then return end

    local pedCoords = GetEntityCoords(cache.ped)
    lib.requestModel(carryData.model)
    carryObj = CreateObject(carryData.model, pedCoords.x, pedCoords.y, pedCoords.z - 2, true, true, false)

    local placement = carryData.placement
    AttachEntityToEntity(carryObj, cache.ped, GetPedBoneIndex(cache.ped, placement.bone), placement.pos.x, placement.pos.y, placement.pos.z, placement.rot.x, placement.rot.y, placement.rot.z, true, true, false, true, 1, true)

    if carryData.anim?.dict and carryData.anim.clip then
        lib.requestAnimDict(carryData.anim.dict, 1000)
    end

    local disabledControls = {}
    if carryData.block then
        if carryData.block.running then
            disabledControls[#disabledControls + 1] = 21 -- INPUT_SPRINT
        end
        if carryData.block.jumping then
            disabledControls[#disabledControls + 1] = 22 -- INPUT_JUMP
        end
        lib.disableControls:Add(disabledControls)
    end

    LocalPlayer.state:set('hrCarry', { item = item, netId = NetworkGetNetworkIdFromEntity(carryObj) }, true)

    while carryObj and DoesEntityExist(carryObj) do
        if #disabledControls > 0 then
            lib.disableControls()
        end

        DisablePlayerFiring(cache.playerId, false)

        if DoesEntityExist(GetVehiclePedIsTryingToEnter(cache.ped)) then
            ClearPedTasks(cache.ped)
        end

        if IsPedInAnyVehicle(cache.ped, false) then
            ClearPedTasksImmediately(cache.ped)
        end

        if carryData.anim?.dict and not IsEntityPlayingAnim(cache.ped, carryData.anim.dict, carryData.anim.clip, 3) and not deadState then
            TaskPlayAnim(cache.ped, carryData.anim.dict, carryData.anim.clip, 2.0, 2.0, -1, carryData.anim.flag or defaultAnimFlag, 0, false, false, false)
        end

        if not IsEntityAttachedToEntity(cache.ped, carryObj) then
            AttachEntityToEntity(carryObj, cache.ped, GetPedBoneIndex(cache.ped, placement.bone), placement.pos.x, placement.pos.y, placement.pos.z, placement.rot.x, placement.rot.y, placement.rot.z, true, true, false, true, 1, true)
        end

        Wait(1)
    end

    if carryData.anim?.dict and IsEntityPlayingAnim(cache.ped, carryData.anim.dict, carryData.anim.clip, 3) then
        StopAnimTask(cache.ped, carryData.anim.dict, carryData.anim.clip)
        RemoveAnimDict(carryData.anim.dict)
    end

    lib.disableControls:Remove(disabledControls)
    SetModelAsNoLongerNeeded(carryData.model)
    carryObj = nil
end)

function carryItemRemoved()
    if carryObj and DoesEntityExist(carryObj) then
        ClearPedTasks(cache.ped)
        SetEntityAsMissionEntity(carryObj)
        DeleteEntity(carryObj)
    end
    carryObj = nil
    LocalPlayer.state:set('hrCarry', nil, true)
end
