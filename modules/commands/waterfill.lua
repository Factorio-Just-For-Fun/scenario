--[[-- Commands Module - Waterfill
    - Adds a command that allows an admin to waterfill a large area
    @commands Waterfill
]]


local Spectate = require 'modules.control.spectate' --- @dep modules.control.spectate

local Commands = require 'expcore.commands' --- @dep expcore.commands
local config = require 'config.waterfill' --- @dep config.waterfill
require 'config.expcore.command_general_parse'

--- Waterfills an area
-- @command waterfill
-- @tparam number range the range to waterfill, there is a max limit to this
Commands.new_command('waterfill', 'Waterfills an area around you')
:add_param('range', false, 'integer-range', 1, config.max_range)
:register(function(player, range)
    if config.require_spectate and (not Spectate.is_spectating(player)) then
        return Commands.success{'fjff-waterfill.must-spectate'}
    end

    local tiles = player.surface.find_tiles_filtered{position=player.position, radius=range, name="landfill"}
    local replace = {}
    local remove_count = 0
    for i, tile in pairs(tiles) do
        replace[i] = {position=tile.position, name="water"}
        remove_count = remove_count + 1
    end
    game.player.surface.set_tiles(replace)

    return Commands.success{'fjff-waterfill.result', remove_count}
end)
