fx_version 'cerulean'
game 'gta5'

author 'Kakarot'

shared_script 'config.lua'

client_script {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}
