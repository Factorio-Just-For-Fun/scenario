--[[-- Commands Module - Stats
    - Adds a command that allows players to view their stats
    @commands Stats
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local Roles = require 'expcore.roles' --- @dep expcore.roles
require 'config.expcore.command_general_parse'
require 'config.expcore.command_role_parse'

local PlayerData = require 'expcore.player_data' --- @dep expcore.player_data
local Statistics = PlayerData.Statistics

local format_time = _C.format_time --- @dep expcore.common


--- Kills yourself or another player.
-- @command stats
-- @tparam[opt=self] string The name of the player to pull the stats of
Commands.new_command('stats', 'Shows your stats or another player\'s.')
:add_param('player', true, 'player')
:set_defaults{player=function(player)
    -- default is the player
    return player
end}
:register(function(player, action_player)
    if player == action_player or Roles.player_allowed(player, 'command/stats/always') then
        local stats = Statistics:get(action_player, {})
        local playTime, afkTime, mapCount = stats.Playtime or 0, stats.AfkTime or 0, stats.MapsPlayed or 0

        return Commands.success{'fjff-stats.result',
            format_time(action_player.online_time, {days = true, hours = true, minutes = true}),
            format_time((playTime - afkTime) * 3600, {days = true, hours = true, minutes = true}),
            mapCount
        }
    else
        return Commands.error{'expcore-commands.unauthorized'}
    end
end)