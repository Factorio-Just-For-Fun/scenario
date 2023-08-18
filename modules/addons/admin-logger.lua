--- Logs certain admin actions to roles
-- @addon Admin-Logger

local Event = require 'utils.event' --- @dep utils.event
local Roles = require 'expcore.roles' --- @dep expcore.roles

local config = require 'config.admin_logger' --- @dep config.admin-logger

local format_chat_player_name = _C.format_chat_player_name --- @dep expcore.common

--- Other commands
Event.add(defines.events.on_console_command, function(event)
    if event.player_index then
        local player_name = format_chat_player_name(event.player_index)
        if config[event.command] then
            for _, return_player in pairs(game.connected_players) do
                if Roles.player_allowed(return_player, 'admin-log') then
                    return_player.print{'admin-logger.message', player_name, event.command, event.parameters}
                end
            end
        end
    end
end)