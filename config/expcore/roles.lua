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
:set_permission_group('Admin')
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_allow_all()

Roles.new_role('Senior Administrator','SAdmin')
:set_permission_group('Admin')
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Administrator')
:allow{
    'command/interface',
    'command/debug',
    'command/toggle-cheat-mode',
		'command/follow',
  	'command/spectate',
    'command/alogi',
}

Roles.new_role('Administrator','Admin')
:set_permission_group('Admin')
:set_custom_color{r=233,g=63,b=233}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Moderator')
:allow{
    'gui/warp-list/bypass-cooldown',
    'gui/warp-list/bypass-proximity',
    'command/connect-all',
		'command/follow',
		'command/spectate',
    'command/bonus',
}

Roles.new_role('Moderator','Mod')
:set_permission_group('Mod')
:set_custom_color{r=0,g=170,b=0}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag('instance-respawn')
:set_parent('Veteran')
:allow{
    'command/assign-role',
    'command/unassign-role',
    'command/repair',
    'command/kill/always',
    'command/clear-tag/always',
    'command/go-to-spawn/always',
    'command/clear-reports',
    'command/clear-warnings',
    'command/clear-temp-ban',
    'command/clear-inventory',
    'command/home',
    'command/home-set',
    'command/home-get',
    'command/return',
    'command/connect-player',
    'gui/rocket-info/toggle-active',
    'gui/rocket-info/remote_launch',
    'fast-tree-decon',
    'command/follow',
    'command/spectate',

    'command/admin-chat',
    'command/teleport',
    'command/bring',
    'command/goto',
    'command/admin-marker',
    'command/give-warning',
    'command/get-warnings',
    'command/get-reports',
    'command/jail',
    'command/unjail',
    'command/kick',
    'command/ban',
  	'command/follow',
  	'command/spectate',
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

local hours10, hours250 = 10*216000, 250*60
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
        return playTime - afkTime >= hours250 and mapCount >= 25
    end
end)

--- Standard User Roles
local hours3, hours15 = 3*216000, 15*60
Roles.new_role('Regular','Reg')
:set_permission_group('Standard')
:set_custom_color{r=79,g=155,b=163}
:set_parent('Guest')
:allow{
    'command/kill',
    'command/rainbow',
    'command/go-to-spawn',
    'command/me',
    'standard-decon'
}
:set_auto_assign_condition(function(player)
    if player.online_time >= hours3 then
        return true
    else
        local stats = Statistics:get(player, {})
        local playTime, afkTime, mapCount = stats.Playtime or 0, stats.AfkTime or 0, stats.MapsPlayed or 0
        return playTime - afkTime >= hours15 and mapCount >= 5
    end
end)

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
    'gui/warp-list',
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
    'Senior Administrator',
    'Administrator',
    'Moderator',
    'Supporter',
    'Veteran',
    'Regular',
    'Jail',
    'Guest' -- Default must be last if you want to apply restrictions to other roles
}

Roles.override_player_roles{
	['uno_chaos']={"Senior Administrator"},
	['Nightmare-Squirrel']={"Senior Administrator"},
	['joloman2']={"Senior Administrator"},

	['Cykloid']={"Administrator"},
	['telexicon']={"Administrator"},
	['Kerza_']={"Administrator"},
	['bananna_manuk']={"Administrator"},
	['elefetor']={"Administrator"},

	['zampaman']={"Moderator"},
	['ultrajer']={"Moderator"},
	['pilypas']={"Moderator"},
	['mskitty']={"Moderator"},
	['DrSuperGood']={"Moderator"},
	['Evy_D']={"Moderator"},
	['i_cant_think_of_a_username']={"Moderator"},

	['TomKron']={"Supporter"},
	['cfras5']={"Supporter"},
	['cydes']={"Supporter"},
	['BAD4EVR']={"Supporter"},
	['ciderdave']={"Supporter"},
	['jballou']={"Supporter"},

	['wingpro_']={"Veteran"},
	['voski']={"Veteran"},
	['Train_Tracker']={"Veteran"},
	['i-make-robots']={"Veteran"},
	['Cantante57']={"Veteran"},
	['ballbuster']={"Veteran"},
	['chrisisthebe']={"Veteran"},
	['cokaina']={"Veteran"},
	['JustMatthew']={"Veteran"},
	['fact10']={"Veteran"},
	['Spzi']={"Veteran"},
	['RailOcelot']={"Veteran"},
	['emarcoscl']={"Veteran"},
	['jrz126']={"Veteran"},
	['Garfield089']={"Veteran"},
	['Delqvs']={"Veteran"},
	['jaboo']={"Veteran"},
	['DaniloZanchi']={"Veteran"},
	['RunWren']={"Veteran"},
	['Fnoo']={"Veteran"},
	['ComradeJay']={"Veteran"},
	['flyingtoaster_']={"Veteran"},
	['Viejo']={"Veteran"},
	['Crowcage']={"Veteran"},
	['TheRealSlimChewy']={"Veteran"},
	['snouborrder']={"Veteran"},
	['SquidConsumption']={"Veteran"},
  ['ratmonkies']={"Veteran"},
  ['bhodinut']={"Veteran"},
  ['oli-vier']={"Veteran"}
}
