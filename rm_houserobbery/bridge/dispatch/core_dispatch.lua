local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.dispatch ~= 'core_dispatch' then return end

dispatch = function(data)
    data.job_names = data.job_names or { 'police', 'sasp', 'bcso', 'sheriff' }
    for i = 1, #data.job_names do
        exports['core_dispatch']:addCall(
            data.code,                                       --- @code string code of the call (like 10-19)
            data.message,                                    --- @message string message in the notification
            {},                                              --- @info table of type {icon= string, info= string }
            { data.coords.x, data.coords.y, data.coords.z }, --- @coords number,number,number coords where the notification is trigger
            data.job_names[i],                               --- @job string job who will receive the notification (one at a time)
            3000,                                            --- @time number time duration of the notification in ms
            data.blip.sprite,                                --- @blipSprite number Sprite that will be use on the minimap to
            data.blip.color,                                 --- @blipColor number color use for the blip
            true                                             --- @priority boolean define if the call is priority or not
        )
    end
end
