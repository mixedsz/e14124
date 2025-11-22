local isServer = IsDuplicityVersion()
if isServer then return end
if cfg.dispatch ~= 'origen_police' then return end

dispatch = function(data)
    data.job_names = data.job_names or { 'police', 'sasp', 'bcso', 'sheriff' }
    for i = 1, #data.job_names do
        TriggerServerEvent('SendAlert:police', {
            coords = data.coords.xyz,
            title = ('%s - %s'):format(data.code, data.message),
            type = 'GENERAL',
            message = data.message,
            job = data.job_names[i],
        })
    end
end
