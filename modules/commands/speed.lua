--[[-- Commands Module - Repair
    - Adds a command that allows an admin to repair and revive a large area
    @commands Repair
]]

local Commands = require 'expcore.commands' --- @dep expcore.commands
local config = require 'config.speed' --- @dep config.speed
require 'config.expcore.command_general_parse'

--- Repairs entities on your force around you
-- @command repair
-- @tparam number range the range to repair stuff in, there is a max limit to this
Commands.new_command('speed', 'Sets the game speed to the given value')
:add_param('speed', false, 'number-range', config.min_speed, config.max_speed)
:register(function(player, speed)
    game.speed = speed
    game.print{'fjff-speed.result', player.name, speed}
    return Commands.success()
end)
