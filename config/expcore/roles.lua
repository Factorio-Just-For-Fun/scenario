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
:set_flag("deconlog-bypass")
:set_allow_all()

Roles.new_role('Administrator','Admin')
:set_permission_group('Admin')
:set_custom_color{r=233,g=63,b=233}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag("deconlog-bypass")
:set_parent('Moderator')
:allow{
    'command/assign-role',

    'command/protect-area'
}

Roles.new_role('Moderator','Mod')
:set_permission_group('Moderator')
:set_custom_color{r=50,g=205,b=50}
:set_flag('is_admin')
:set_flag('is_spectator')
:set_flag('report-immune')
:set_flag("deconlog-bypass")
:set_parent('Veteran')
:allow{
    'command/assign-role',
    'command/unassign-role',

    'command/speed',
    'command/disable-pollution',
    'command/waterfill',

    'command/repair',
    'command/kill/always',

    'command/admin-chat',

    'command/get-reports',
    'command/clear-reports',

    'command/clear-tag/always',
    'command/jail',
    'command/unjail',
    'command/kick',
    'command/ban',
    'command/rainbow-ban',

    'command/follow',
  	'command/spectate',
    'command/search',
    'command/admin-marker',

    'command/stats/always'
}

--- Trusted Roles
Roles.new_role('Supporter','Sup')
:set_permission_group('Veteran')
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

local hours64, hours750 = 64*216000, 750*60
Roles.new_role('VeteranPlus','VetPlus')
:set_permission_group('Veteran')
:set_custom_color{r=255,g=215,b=0}
:set_parent('Veteran')
:set_auto_assign_condition(function(player)
    if player.online_time >= hours64 then
        return true
    else
        local stats = Statistics:get(player, {})
        local playTime, afkTime, mapCount = stats.Playtime or 0, stats.AfkTime or 0, stats.MapsPlayed or 0
        return playTime - afkTime >= hours750 and mapCount >= 20
    end
end)

local hours10, hours15 = 10*216000, 15*60
Roles.new_role('Veteran','Vet')
:set_permission_group('Veteran')
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
:set_permission_group('Regular')
:set_custom_color{r=79,g=155,b=163}
:set_parent('Guest')
:allow{
    'command/kill',
    'command/rainbow',
    'command/me',
    'standard-decon',
    'bypass-nukeprotect'
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
    'command/save-data',
    'command/preference',
    'command/set-preference',
    'command/stats',
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
:set_flag("defer_role_changes")
:disallow(default.allowed)

--- System defaults which are required to be set
Roles.set_root('System')
Roles.set_default('Guest')

Roles.define_role_order{
    'System', -- Best to keep root at top
    'Administrator',
    'Moderator',
    'Supporter',
    'VeteranPlus',
    'Veteran',
    'Regular',
    'Jail',
    'Guest' -- Default must be last if you want to apply restrictions to other roles
}

Roles.override_player_roles{
    ['joloman2']={ "Administrator", "Supporter" },
	['uno_chaos']={ "Administrator", "Supporter" },

	['Ashy314']={ "Administrator" },
	['Nightmare-Squirrel']={ "Administrator" },

	['elefetor']={ "Moderator" },
	['jrz126']={ "Moderator" },
	['mskitty']={ "Moderator" },
	['Kerza_']={ "Moderator" },

	['cfras5']={ "Moderator", "Supporter" },
	['dfarmer']={ "Moderator" },

    -- Inactive
	['telexicon']={ "Moderator" },
	['bananna_manuk']={ "Moderator" },
	['Cykloid']={ "Moderator" },
	['DrSuperGood']={ "Moderator" },
	['Evy_D']={ "Moderator" },
	['pilypas']={ "Moderator" },
	['ultrajer']={ "Moderator" },
	['zampaman']={ "Moderator" },

    -- Disabled
	-- ['MadKatz']={ "Moderator" },

    -- Supporters
	['BAD4EVR']={ "Supporter" },
	['ciderdave']={ "Supporter" },
	['cydes']={ "Supporter" },
	['gigiati']={ "Supporter" },
	['jballou']={ "Supporter" },
	['TomKron']={ "Supporter" },
}
