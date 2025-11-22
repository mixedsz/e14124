fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'rainmad <store.rainmad.com>'
version '1.5.8'

shared_scripts {
    '@ox_lib/init.lua',
    'cfg.lua',
    'bridge/dispatch/*.lua',
    'bridge/inventory/*.lua',
    'bridge/notification/*.lua',
}

server_scripts {
    'bridge/**/server.lua',
    'server/discord_log.lua',
    'server/editor.lua',
    'server/main.lua',
}

client_scripts {
    'client/editor.lua',
    'client/sprites.lua',
    'client/carry.lua',
    'client/main.lua',
    'bridge/target/*.lua',
    'bridge/textui/*.lua',
    'bridge/minigame/*.lua',
    'bridge/**/client.lua',
}

ui_page 'html/index.html'
files {
    'locales/*.json',
    'assets/images/*.png',
    'assets/sprites/*.png',
    'html/index.html',
    'data/*.lua',
    'created_houses.lua',  -- Add this line to include created houses
}

escrow_ignore {
    '[items]',
    'cfg.lua',
    'created_houses.lua',
    'data/*.lua',
    'bridge/**.*',
    'assets/**.*',
    'client/*.lua',
    'server/*.lua',
}

dependencies {
    '/gameBuild:2060',
}

dependency '/assetpacks'