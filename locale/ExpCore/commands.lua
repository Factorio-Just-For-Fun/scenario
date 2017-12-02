--[[
Explosive Gaming

This file can be used with permission but this and the credit below must remain in the file.
Contact a member of management on our discord to seek permission to use our code.
Any changes that you may make to the code are yours but that does not make the script yours.
Discord: https://discord.gg/r6dC2uK
]]
--Please Only Edit Below This Line-----------------------------------------------------------
local command_calls = {}
local command_data = {}

--- Uses a commands data to return the inputs as a string
-- @usage command = command_data[command_name]
-- command_inputs(command) -- returns "<input1> <input2> "
-- @tparam table the data for the command being run
-- @treturn string the inputs in string format
local function command_inputs(command)
    if not is_type(command,'table') then return end
    local inputs = ''
    for _,input in pairs(command.inputs) do
        if input == true then break end
        inputs = inputs..'<'..input..'> '
    end
    return inputs
end

--- Uses the command data and the event to return a table of the args
-- @usage command = command_data[command_name]
-- command_args(event,command) -- return {input1='one',input2='two'}
-- @tparam defines.events.on_console_command event the event rasied by the command
-- @tparam table command the data for the command being run
-- @treturn table a table version of the event.parameter based on expected inputs
local function command_args(event,command)
    if not event or not is_type(command,'table') then return end
    local args = {}
    -- haddles no parameters given
    if not event.parameter then
        if #command.inputs > 0 then return args, false
        else return args, true
        end
    end
    -- finds all the words and cheaks if the right number were given
    local words = string.split(event.parameter,' ')
    if table.last(command.inputs) == true then 
        if #words < #command.inputs-1 then return args, false end
    else 
        if #words < #command.inputs then return args, false end
    end
    -- if it is the right number then process and return the args
    for index,input in pairs(command.inputs) do
        if command.inputs[index+1] == true then 
            args[input] = table.concat(words,' ',index) 
            break
        else 
            args[input] = words[index]
        end
    end
    return args, true
end

--- Used to return all the commands a player can use
-- @usage get_commands(1) -- return {{command data},{command data}}
-- @param player the player refreced by string|number|LuaPlayer|event
-- @treturn table a table containg all the commands the player can use
function get_commands(player)
    local commands = {}
    local player = Game.get_player(player)
    if not player then return commands end
    local rank = Ranking.get_rank(player)
    for name,data in pairs(command_data) do
        if Ranking.rank_allowed(rank,name) then table.insert(commands,data) end
    end
    return commands
end

--- Used to call the custom commands
-- @usage You dont its an internal command
-- @tparam defines.events.on_console_command event the event rasied by the command
commands._add_command = commands.add_command
local function run_custom_command(command)
    local command_data = command_data[command.name]
    local player_name = Game.get_player(commnd) and Game.get_player(commnd).name or 'server'
    -- is the player allowed to use this command
    if not Ranking.rank_allowed(Ranking.get_rank(command.player_index),command.name) then
        player_return{'commands.unauthorized'}
        game.write_file('commands.log','\n'..game.tick
            ..' Player: '..player_name
            ..' Failed to use command (Unauthorized): '..command.name
            ..' With args of: '..table.to_string(command_args(command,command_data))
        , true, 0)
        return
    end
    -- gets the args for the command
    local args, valid = command_args(command,command_data)
    if not valid then
        player_return{'commands.invalid-inputs',command.name,command_args(command)}
        game.write_file('commands.log','\n'..game.tick
            ..' Player: '..player.name
            ..' Failed to use command (Invalid Args): '..command.name
            ..' With args of: '..table.to_string(args)
        , true, 0)
        return
    end
    -- runs the command
    local status, err = pcall(command_calls[command.name],event,args)
    if err then error(err) end
    player_return{'commands.command-ran'}
    game.write_file('commands.log','\n'..game.tick
        ..' Player: '..player.name
        ..' Used command: '..command.name
        ..' With args of: '..table.to_string(args)
    , true, 0)
end

--- Used to define commands
-- @usage inputs = {'player','reason',true}
-- commands.add_command('ban','bans a player',inputs,function() return end)
-- @tparam string name the name of the command
-- @tparam[opt='No Description'] string description the description of the command
-- @tparam[opt={'parameter',true}] table inputs a table of the inputs to be used, last index being true makes the last parameter open ended (longer than one word)
-- @tparam function event the function to call on the event
commands.add_command = function(name, description, inputs, event)
    if command_calls[name] then return end
    if not is_type(name,'string') then return end
    if not is_type(event,'function') then return end
    local description = is_type(description,'string') and description or 'No Description'
    local inputs = is_type(inputs,'table') and inputs or {'parameter',true}
    command_data[name] = {
        name=name,
        description=description,
        inputs=inputs
    }
    command_calls[name] = event
    _add_command(name,description,run_custom_command)
end