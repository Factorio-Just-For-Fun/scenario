--[[-- Commands Module - Disable Pollution
    - Adds a command that allows an admin to disable pollution across the map
    @commands Disable Pollution
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local config = require 'config.disable_pollution' --- @dep config.disable_pollution

--- Disables pollution on the map
-- @command disable-pollution
Commands.new_command('disable-pollution', 'Disables pollution')
:register(function(player)
    if config.no_biters and (not not player.surface.find_entities_filtered({force="enemy"})[1]) then
        return Commands.success{'fjff-disable-pollution.fail'}
    else
        player.surface.clear_pollution()
        game.map_settings.pollution.enabled = false
        
        return Commands.success{'fjff-disable-pollution.result', player.name}
    end
end)
