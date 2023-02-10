fx_version 'adamant'

game 'gta5'

description 'ESX Police Job'
lua54 'yes'
version '1.0.1'
legacyversion '1.9.1'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}

dependencies {
	'es_extended',
	'esx_billing',
	'esx_vehicleshop'
}
