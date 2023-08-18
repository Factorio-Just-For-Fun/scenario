-- Morsk's /logi command: github.com/morsk/logi-command
-- A version of this code is available on github under a MIT license.

local Commands = require 'expcore.commands' --- @dep expcore.commands
local M = {} -- object for this module
local LOGISTICS_DEFAULT_MAX = 4294967295 -- 0xFFFFFFFF
local MAX_LOGI_SLOT = 1000 -- Highest the game supports. Found by experimentation.

local function new_empty_blueprint(cursor_stack)
  -- Encoding of the simplest blueprint json: {"blueprint":{"item":"blueprint"}}
  cursor_stack.import_stack("0eNqrVkrKKU0tKMrMK1GyqlbKLEnNVbJCEqutBQDZSgyK")
end

-- What's the highest logi slot in use by player?
local function request_slot_count(player)
  if player.character then
    return player.character.request_slot_count
  else
    -- The API provides no way to find the max slot of an offline player, except
    -- to search the whole thing. MAX_LOGI_SLOT is huge, and this spams temp
    -- objects.
    -- This only happens if an admin uses it on an offline player, so whatever;
    -- do it.
    for i = MAX_LOGI_SLOT,1,-1 do
      if player.get_personal_logistic_slot(i).name then
        return i
      end
    end
    return 0
  end
end

-- Blueprint data of a new combinator. Not an actual combinator.
local function new_blank_combinator(x, y)
  return {
    name = "constant-combinator",
    position = { x = x, y = y },
    control_behavior = { filters = {} }
  }
end

-- Semantically "comb.filter[i] = (name, value)", although internals differ.
local function set_in_combinator(comb, i, name, value)
  table.insert(comb.control_behavior.filters, {
    signal = {
      type = "item",
      name = name,
    },
    count = value,
    index = i,
  })
end

-- Returns an array of blueprint entities, based on player's logi requests.
-- Changes nothing on its own.
local function export_to_blueprint(player)
  local n_logi = request_slot_count(player)
  local combinator_slots = game.entity_prototypes["constant-combinator"].item_slot_count

  -- Set values in combinators, constructing combinators as needed.
  local mins, maxes = {}, {}
  mins[1] = new_blank_combinator(0, 0) -- This always exists.
  for i = 1, n_logi do
    local slot = player.get_personal_logistic_slot(i)
    if slot.name then
      local comb_x = math.ceil(i / combinator_slots)
      local comb_slot = (i-1) % combinator_slots + 1
      mins[comb_x] = mins[comb_x] or new_blank_combinator(comb_x-1, 0.5)
      set_in_combinator(mins[comb_x], comb_slot, slot.name, slot.min)
      if slot.max < LOGISTICS_DEFAULT_MAX then
        maxes[comb_x] = maxes[comb_x] or new_blank_combinator(comb_x-1, 4.5)
        set_in_combinator(maxes[comb_x], comb_slot, slot.name, slot.max)
      end
    end
  end

  -- Add entity_number and collate into blueprint.
  local blueprint_entities = {}
  local n_combs = 0
  local function add_combs(t)
    for _,comb in pairs(t) do
      n_combs = n_combs + 1
      blueprint_entities[n_combs] = comb
      comb.entity_number = n_combs
    end
  end
  add_combs(mins)
  add_combs(maxes)
  return blueprint_entities
end

-- Clear all player's logistic slots.
local function clear_all_logistic_slots(player)
  for i = 1, request_slot_count(player) do
    player.clear_personal_logistic_slot(i)
  end
end

-- Make a printable string with min-max[icon] for each request.
local function list_requests(sep, t, i, req)
  if i then
    if req.max < LOGISTICS_DEFAULT_MAX then
      return sep..req.min.."-"..req.max.."[img=item."..req.name.."]"..
        list_requests(",  ", t, next(t, i))
    else
      return sep..req.min.."[img=item."..req.name.."]"..
        list_requests(",  ", t, next(t, i))
    end
  else
    return ""
  end
end

-- Clear & setup player's logi requests to match blueprint. Returns a printable
-- string of the import.
local function import_from_blueprint(player, bp_entities)
  assert(#bp_entities > 0)
  -- Pass 1: Find minimums, so we can adjust coordinates around them.
  local min_x = math.huge
  local min_y = math.huge
  for i = 1, #bp_entities do
    local e = bp_entities[i]
    if e.name ~= "constant-combinator" then
      error("Weird entities. Should only be constant combinators.", 0)
    end
    min_x = math.min(min_x, e.position.x)
    min_y = math.min(min_y, e.position.y)
  end

  -- Pass 2: Adjust coordinates, sort combinators into tables.
  local mins, maxes = {}, {}
  for i = 1, #bp_entities do
    local e = bp_entities[i]
    local relative_x = e.position.x - min_x
    local relative_y = e.position.y - min_y
    if relative_y == 0 then
      mins[relative_x+1] = e
    elseif relative_y == 4 then
      maxes[relative_x+1] = e
    else
      error("Weird combinator rows. Only 0 and 4 should be used.", 0)
    end
  end

  -- Pass 3: Build a table of logi requests from the combinators, in order.
  local requests = {}
  -- Generic loop over combinators, then on filters in each combinator.
  local function loop_combinator_filters(group, f)
    local combinator_slots = game.entity_prototypes["constant-combinator"].item_slot_count
    for comb_x, e in pairs(group) do
      if e.control_behavior and e.control_behavior.filters then
        local offset = (comb_x - 1) * combinator_slots
        for _,filter in pairs(e.control_behavior.filters) do
          if filter.signal.type ~= "item" then
            error("Combinator has weird signals: "..filter.signal.type..", "..filter.signal.name, 0)
          end
          f(filter, offset)
        end
      end
    end
  end
  -- Loop on mins, detect duplicates.
  local items_seen_in_blueprint = {}
  loop_combinator_filters(mins, function(filter, offset)
    local logi_name = filter.signal.name
    if items_seen_in_blueprint[logi_name] then
      error("Item in blueprint more than once: " .. logi_name, 0)
    end
    items_seen_in_blueprint[logi_name] = true
    requests[filter.index + offset] = {
      name = logi_name,
      min = filter.count,
      max = LOGISTICS_DEFAULT_MAX,
    }
  end)
  -- Loop on maxes, detect mismatch.
  loop_combinator_filters(maxes, function(filter, offset)
    local i = filter.index + offset
    if not requests[i] or requests[i].name ~= filter.signal.name then
      error("Min/max mismatch. Items need to be in matching slots.", 0)
    end
    requests[i].max = filter.count
  end)

  -- Pass 4: Make actual changes.
  clear_all_logistic_slots(player)
  for i, request in pairs(requests) do
    player.set_personal_logistic_slot(i, request)
  end

  -- Return pretty string of imports.
  local ok, result = pcall(list_requests, "", requests, next(requests))
  if ok then
    return result
  else
    error("Import succeeded, but display failed:"..result, 0)
  end
end

-- The bulk of the command, separated here for pcall.
local function logi_command_internal(player)
  local stack = player.cursor_stack

  if not player.force.character_logistic_requests then
    error("You need logistic robots researched before you can use this.", 0)
  end
  if stack.valid_for_read and not stack.is_blueprint then
    error("Only works with blueprints, or with a blank cursor.", 0)
  end

  -- It's normal to be holding nothing, and create a new blueprint here.
  -- If the player holds an empty blueprint they want to export to, that's fine too.
  if not player.is_cursor_blueprint() then
    -- Clear the cursor, just to be sure. The API is weird and it's hard to tell
    -- if the cursor is truly empty.
    player.clear_cursor()
    new_empty_blueprint(stack)
  end

  local bp_entities = player.get_blueprint_entities()
  if bp_entities then
    -- We have entities, so try to import.
    local import_result = "Imported: "..import_from_blueprint(player, bp_entities)
    player.print(import_result)
    player.clear_cursor()
  else
    -- A blueprint without entities. We try to export.
    if stack.valid_for_read then
      local result = export_to_blueprint(player)
      stack.set_blueprint_entities(result)
      player.print("Exported.")
    else
      -- The player object says we have a blueprint, but the player's cursor
      -- stack says we have nothing. This means it's using the library.
      error("Can't export to the blueprint library. "..
            "Use an empty blueprint from your inventory, or a clear cursor.", 0)
    end
  end
end

Commands.new_command('logi', 'Converts logistic requests to/from a blueprint.')
:add_alias('logistic', 'logistics')
:register(function(player, raw)
  local ok, result = pcall(logi_command_internal, player)
  if not ok then
    game.player.print(result)
  end
end)

Commands.new_command('clogi', 'Copies Player Logistic Requests To Selected Spidertron.')
:register(function(player, raw)
  local target = player.selected
  for i=1, target.request_slot_count do
      target.clear_vehicle_request_slot(i)
  end
  n_logi = player.character.request_slot_count
  for i = 1, n_logi do
      slot = player.get_personal_logistic_slot(i)
      target.set_vehicle_logistic_slot(i,slot)
  end
  player.print('Player Logistics Copied to Spidertron')
end)