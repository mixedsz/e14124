if cfg.target == 'auto' then
    if not GetResourceState('ox_target'):find('start') then
        return
    end
elseif cfg.target ~= 'ox' then
    return
end

target = {}

target.addLocalEntity = function(entity, option)
    exports.ox_target:addLocalEntity(entity, option)
end
