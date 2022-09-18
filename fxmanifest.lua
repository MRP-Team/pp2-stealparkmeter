fx_version 'cerulean'
game 'gta5'

author 'PassPar2'

description 'pp2-stealparkmeter'
version '1.0.0'

shared_scripts {
  '@qb-core/shared/locale.lua',
  'locales/en.lua',
  'config.lua'
}

server_script {
  'server.lua'
}

client_scripts {
  'client.lua'
}

lua54 'yes'
