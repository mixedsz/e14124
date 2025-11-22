-- Discord logging configuration
local webhookURL = '' -- Add your Discord webhook URL here

local function sendToDiscord(title, message, color)
    if webhookURL == '' then return end
    
    local embed = {
        {
            ['title'] = title,
            ['description'] = message,
            ['color'] = color or 16711680,
            ['footer'] = {
                ['text'] = os.date('%Y-%m-%d %H:%M:%S'),
            },
        }
    }
    
    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = 'House Robbery Logs',
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end

-- Log job start
RegisterNetEvent('rm_houserobbery:server:logJobStart', function(playerName, houseType, location)
    local message = string.format('**Player:** %s\n**House Type:** %s\n**Location:** %s', 
        playerName, houseType, location)
    sendToDiscord('House Robbery Started', message, 3447003)
end)

-- Log job completion
RegisterNetEvent('rm_houserobbery:server:logJobComplete', function(playerName, houseType, rewards)
    local message = string.format('**Player:** %s\n**House Type:** %s\n**Rewards:** %s', 
        playerName, houseType, rewards)
    sendToDiscord('House Robbery Completed', message, 3066993)
end)

-- Log safe opened
RegisterNetEvent('rm_houserobbery:server:logSafeOpened', function(playerName, houseType)
    local message = string.format('**Player:** %s\n**House Type:** %s', 
        playerName, houseType)
    sendToDiscord('Safe Opened', message, 15844367)
end)

-- Log resident alerted
RegisterNetEvent('rm_houserobbery:server:logResidentAlert', function(playerName, houseType)
    local message = string.format('**Player:** %s\n**House Type:** %s', 
        playerName, houseType)
    sendToDiscord('Resident Alerted', message, 15158332)
end)

exports('sendToDiscord', sendToDiscord)