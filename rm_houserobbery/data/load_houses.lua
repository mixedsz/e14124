-- This file loads both the default houses and any created houses

-- Load default houses from houses.lua (if it exists)
local defaultHouses = lib.load('data.houses') or {}

-- Try to load created houses
local createdHouses = {}
local resourceName = GetCurrentResourceName()

-- Use pcall to safely try loading the file
local success, result = pcall(function()
    return load(LoadResourceFile(resourceName, 'created_houses.lua'))
end)

if success and result then
    local ok, houses = pcall(result)
    if ok and type(houses) == 'table' then
        createdHouses = houses
        print('^2[House Robbery]^7 Loaded ' .. #createdHouses .. ' created houses')
    end
end

-- Merge default houses with created houses
cfg.houses = {}

-- Add default houses first
for i = 1, #defaultHouses do
    cfg.houses[#cfg.houses + 1] = defaultHouses[i]
end

-- Add created houses
for i = 1, #createdHouses do
    cfg.houses[#cfg.houses + 1] = createdHouses[i]
end

print('^2[House Robbery]^7 Total houses loaded: ' .. #cfg.houses)