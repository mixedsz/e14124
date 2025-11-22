lib.locale('en')

cfg = {}
cfg.framework = 'auto'      -- 'auto' | 'qb' | 'esx'
cfg.target = 'auto'         -- 'auto' | 'ox' | 'qb' | false
cfg.minigame = 'ox_lib'     -- 'rm_minigames' | 'ox_lib' | 'qb-minigames' | 'ps-ui' | 'bl_ui' | false
cfg.notification = 'ox_lib' -- 'ox_lib' | 'qb' | 'esx' | 'okokNotify' | 'ps-ui'
cfg.textUI = 'ox_lib'       -- 'ox_lib' | 'esx' | 'qb' | 'okokTextUI' | 'jg-textui'
cfg.inventory = 'auto'      -- 'auto' | 'ox_inventory' | 'qb-inventory' | 'qs-inventory' | 'ak47_inventory'
cfg.dispatch = 'cd_dispatch'        -- false | 'default_dispatch' | 'cd_dispatch' | 'qs-dispatch' | 'ps-dispatch' | 'rcore_dispatch' | 'sonoran_cad' | 'origen_police' | 'redutzu-mdt' | 'lb-tablet' | 'core_dispatch' | 'tk_dispatch' | 'l2s-dispatch'
cfg.iconPath = 'https://cfx-nui-rm_houserobbery/assets/images/'

cfg.keypadBrokenDispatchChance = 30 -- number -- Chance to send a dispatch alert when the keypad is broken by the welding machine
cfg.residentCallDispatchChance = 100   -- number -- Chance to send a dispatch alert when a resident is alerted

cfg.interaction = {
    controlId = 38,
    text = 'E',
    colors = {
        background = { r = 241, g = 93, b = 56, a = 255 },
        text = { r = 226, g = 232, b = 240, a = 255 },
    },
}
cfg.weldingSpeed = 0.03
cfg.safeOpeningDuration = 20 -- second
cfg.searchingDuration = 10   -- second
cfg.collectingDuration = 10  -- second

cfg.cooldowns = {
    cancel = 240, -- minute -- time to get another job after canceling a job
    player = 240, -- minute -- time to take up a job again after finishing the job
    global = 0, -- minute -- the waiting time after one player gets a job before another player can get a job
}

cfg.enableMultiplePersonRobbing = true

cfg.jobSearchDuration = 5000              --ms
cfg.requiredPoliceCount = 0
cfg.enableOldMethodForPoliceCount = false -- not recommended, all players' jobs are checked one by one
cfg.fallbackExitCoord = vec4(156.42, -1065.71, 30.05, 159.85)
cfg.robberyDuration = 30                  -- minute -- when the time expires, the robbery is over, the house is deleted
cfg.houseDeletionTime = 5                 -- minute -- time to delete the house after everyone has left
cfg.autoExitOnDeath = true                -- automatic teleportation out the door in case of death inside the house

cfg.residentWeapon = `WEAPON_BAT`
-- when teleporting home you may want to use only melee weapons as weapon firing alerts will go from the interior,
-- otherwise you may need to add the interiors to no dispatch zones in your dispatch script
cfg.enableOnlyMeleeWeaponsInside = true

cfg.targetHouseBlip = {
    sprite = 350,
    color = 17,
    scale = 0.9,
}

-- A warning will appear when leaving the house if there are still searchable or collectible items left. The job will not be considered complete until these tasks are finished. This warning will only be visible to the person receiving the job.
cfg.showJobIsNotCompletelyFinishedWarning = true

-- ... (keep all your existing cfg settings above)

local isClient = not IsDuplicityVersion()

if isClient then
    cfg.hourCheck = function()
        local hour = GetClockHours()
        if hour < 5 or hour >= 22 then
            return true
        else
            return false, 'You can only get work at night, try again later', 'fa-solid fa-moon'
        end
    end
else
    -- SERVER ONLY CONFIG
    cfg.editorCommand = 'hreditor'  -- Your command name
    cfg.editorAlloweds = {
        ['license:ec2060c4f6c02bfed6db59743c5dfb4f98155e0d'] = true,  -- marks
        -- Add more admin identifiers here
    }
end

if not lib.checkDependency('ox_lib', '3.23.1') then 
    print('^3[WARN] ox_lib version 3.23.1 or higher is required for the script to run stably, please update') 
end

if not lib.checkDependency('rm_tools', '1.1.5') then 
    print('^3[WARN] rm_tools version 1.1.5 or higher is required for the script to run stably, please update') 
end

lib.load('data.house_types')
lib.load('data.load_houses')  -- Changed from 'data.houses' to load both default and created
lib.load('data.npcs')
lib.load('data.prices')
lib.load('data.rewards')
