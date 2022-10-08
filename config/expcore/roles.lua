--- This is the main config file for the role system; file includes defines for roles and role flags and default values
-- @config Roles

local Roles = require 'expcore.roles' --- @dep expcore.roles
local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
local Statistics = PlayerData.Statistics

--- Role flags that will run when a player changes roles
Roles.define_flag_trigger('is_admin',function(player,state)
    player.admin = state
end)
Roles.define_flag_trigger('is_spectator',function(player,state)
    player.spectator = state
end)
Roles.define_flag_trigger('is_jail',function(player,state)
    if player.character then
        player.character.active = not state
    end
end)

--- Admin Roles
Roles.new_role('System','SYS')
:set_permission_group('System')
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_flag("deconlog-bypass")
:set_allow_all()

Roles.new_role('Administrator','Admin')
:set_permission_group('Admin')
:set_custom_color{r=233,g=63,b=233}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_flag("deconlog-bypass")
:set_parent('Veteran')
:allow{
    'command/assign-role',
    'command/unassign-role',

    'command/repair',
    'command/bonus',
    'command/kill/always',

    'gui/rocket-info/toggle-active',
    'gui/rocket-info/remote_launch',

    'command/admin-chat',
    'command/admin-marker',

    'command/teleport',
    'command/bring',
    'command/goto',
    'command/home',
    'command/home-set',
    'command/home-get',
    'command/return',
    'command/go-to-spawn/always',

    'command/give-warning',
    'command/get-warnings',
    'command/get-reports',
    'command/clear-reports',
    'command/clear-warnings',
    'command/clear-inventory',
    'command/clear-tag/always',
    'command/jail',
    'command/unjail',
    'command/kick',
    'command/ban',
    'command/rainbow-ban',
    'command/protect-area',

    'command/follow',
  	'command/spectate',
    'command/search'
}

--- Trusted Roles
Roles.new_role('Supporter','Sup')
:set_permission_group('Trusted')
:set_custom_color{r=230,g=99,b=34}
:set_flag('is_spectator')
:set_parent('Veteran')
:allow{
    'command/jail',
    'command/unjail',
		'command/home',
    'command/home-set',
    'command/home-get',
    'command/return',
    'command/join-message'
}

local hours10, hours15 = 10*216000, 15*60
Roles.new_role('Veteran','Vet')
:set_permission_group('Trusted')
:set_custom_color{r=140,g=120,b=200}
:set_parent('Regular')
:allow{
    'command/chat-bot',
    'command/logi',
    'command/clogi',
    'command/save-quickbar'
}
:set_auto_assign_condition(function(player)
    if player.online_time >= hours10 then
        return true
    else
        local stats = Statistics:get(player, {})
        local playTime, afkTime, mapCount = stats.Playtime or 0, stats.AfkTime or 0, stats.MapsPlayed or 0
        return playTime - afkTime >= hours15 and mapCount >= 3
    end
end)

--- Standard User Roles
local hours3, hours8 = 3*216000, 8*60
Roles.new_role('Regular','Reg')
:set_permission_group('Standard')
:set_custom_color{r=79,g=155,b=163}
:set_parent('Guest')
:allow{
    'command/kill',
    'command/rainbow',
    'command/me',
    'standard-decon'
}
:set_auto_assign_condition(function(player)
    if player.online_time >= hours3 then
        return true
    else
        local stats = Statistics:get(player, {})
        local playTime, afkTime, mapCount = stats.Playtime or 0, stats.AfkTime or 0, stats.MapsPlayed or 0
        return playTime - afkTime >= hours8 and mapCount >= 3
    end
end)


Roles.new_role('InternalUseOnly')
:set_permission_group('Guest')
:set_custom_color{r=127,g=50,b=127}
:set_block_auto_assign(true)
:set_parent('Guest')

--- Guest/Default role
local default = Roles.new_role('Guest','')
:set_permission_group('Guest')
:set_custom_color{r=185,g=187,b=160}
:allow{
    'command/tag',
    'command/tag-clear',
    'command/search-help',
    'command/list-roles',
    'command/find-on-map',
    'command/report',
    'command/ratio',
    'command/server-ups',
    'command/save-data',
    'command/preference',
    'command/set-preference',
    'command/connect',
    'gui/player-list',
    'gui/rocket-info',
    'gui/science-info',
    'gui/task-list',
    'gui/readme'
}

--- Jail role
Roles.new_role('Jail')
:set_permission_group('Restricted')
:set_custom_color{r=50,g=50,b=50}
:set_block_auto_assign(true)
:disallow(default.allowed)

--- System defaults which are required to be set
Roles.set_root('System')
Roles.set_default('Guest')

Roles.define_role_order{
    'System', -- Best to keep root at top
    'Administrator',
    'Supporter',
    'Veteran',
    'Regular',
    'InternalUseOnly',
    'Jail',
    'Guest' -- Default must be last if you want to apply restrictions to other roles
}

Roles.override_player_roles{
	['Ashy314']={ "System" },

	['uno_chaos']={ "Administrator", "Veteran", "Regular" },
	['Nightmare-Squirrel']={ "Administrator", "Veteran", "Regular" },
	['joloman2']={ "Administrator", "Veteran", "Regular" },

	['Cykloid']={ "Administrator", "Veteran", "Regular" },
	['telexicon']={ "Administrator", "Veteran", "Regular" },
	['Kerza_']={ "Administrator", "Veteran", "Regular" },
	['bananna_manuk']={ "Administrator", "Veteran", "Regular" },
	['elefetor']={ "Administrator", "Veteran", "Regular" },

	['zampaman']={ "Administrator", "Veteran", "Regular" },
	['ultrajer']={ "Administrator", "Veteran", "Regular" },
	['pilypas']={ "Administrator", "Veteran", "Regular" },
	['mskitty']={ "Administrator", "Veteran", "Regular" },
	['DrSuperGood']={ "Administrator", "Veteran", "Regular" },
	['Evy_D']={ "Administrator", "Veteran", "Regular" },
	['MadKatz']={ "Administrator", "Veteran", "Regular" },
	['jrz126']={ "Administrator", "Veteran", "Regular" },
	
	['TomKron']={ "Supporter", "Veteran", "Regular" },
	['cfras5']={ "Supporter", "Veteran", "Regular" },
	['cydes']={ "Supporter", "Veteran", "Regular" },
	['BAD4EVR']={ "Supporter", "Veteran", "Regular" },
	['ciderdave']={ "Supporter", "Veteran", "Regular" },
	['jballou']={ "Supporter", "Veteran", "Regular" },
	['gigiati']={ "Supporter", "Veteran", "Regular" },
}
