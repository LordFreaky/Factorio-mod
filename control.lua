local robots = 10

local signal_tech = "heliopause-foundry-signal-from-space"
local signal_prerequisite = "rocket-silo"

local min_signal_delay = 5 * 60 * 60
local max_signal_delay = 20 * 60 * 60

local function random_signal_delay()
  storage.hf_signal_rng = storage.hf_signal_rng or game.create_random_generator()

  local range = max_signal_delay - min_signal_delay + 1
  local rolled = math.floor(storage.hf_signal_rng() * range)

  if rolled >= range then
    rolled = range - 1
  end

  return min_signal_delay + rolled
end

local function init()
  storage.equipped = storage.equipped or {}
  storage.pending = storage.pending or {}

  storage.hf_signal_unlocked_forces = storage.hf_signal_unlocked_forces or {}

  if not storage.hf_signal_unlock_tick then
    storage.hf_signal_unlock_tick = game.tick + random_signal_delay()
  end
end

local function give(player)
  if not player or not player.valid then return false end
  init()

  if storage.equipped[player.index] then return true end

  if not player.character then
    storage.pending[player.index] = true
    return false
  end

  local character = player.character
  local armor_inventory = character.get_inventory(defines.inventory.character_armor)
  if not armor_inventory or not armor_inventory.valid then return false end

  local armor = armor_inventory[1]

  if armor.valid_for_read then
    storage.equipped[player.index] = true
    storage.pending[player.index] = nil
    return true
  end

  if not armor.set_stack({name = "modular-armor", count = 1}) then return false end

  local grid = armor.grid or armor.create_grid()
  if not grid or not grid.valid then return false end

  grid.clear()

  if not grid.put({name = "personal-roboport-equipment", position = {x = 0, y = 0}}) then
    return false
  end

  for x = 2, 4 do
    if not grid.put({name = "battery-equipment", position = {x = x, y = 0}}) then
      return false
    end
  end

  for y = 2, 4 do
    for x = 0, 4 do
      if not grid.put({name = "solar-panel-equipment", position = {x = x, y = y}}) then
        return false
      end
    end
  end

  character.insert({name = "construction-robot", count = robots})

  storage.equipped[player.index] = true
  storage.pending[player.index] = nil

  return true
end

local function give_all()
  init()

  for _, player in pairs(game.players) do
    give(player)
  end
end

local function hide_signal_technology()
  init()

  for _, force in pairs(game.forces) do
    local tech = force.technologies[signal_tech]

    if tech and not tech.researched and not storage.hf_signal_unlocked_forces[force.name] then
      tech.enabled = false
      tech.visible_when_disabled = false
    end
  end
end

local function print_to_force(force, message)
  for _, player in pairs(game.players) do
    if player.valid and player.force and player.force.name == force.name then
      player.print(message)
    end
  end
end

local function unlock_signal_for_force(force)
  local tech = force.technologies[signal_tech]
  local prerequisite = force.technologies[signal_prerequisite]

  if not tech then return end
  if tech.researched then return end
  if storage.hf_signal_unlocked_forces[force.name] then return end
  if not prerequisite or not prerequisite.researched then return end

  tech.enabled = true
  tech.visible_when_disabled = true

  storage.hf_signal_unlocked_forces[force.name] = true

  print_to_force(force, {"heliopause-foundry.signal-unlocked"})
end

local function check_signal_unlock()
  init()

  if game.tick < storage.hf_signal_unlock_tick then
    return
  end

  for _, force in pairs(game.forces) do
    unlock_signal_for_force(force)
  end
end

local function setup()
  init()
  hide_signal_technology()
  give_all()
  check_signal_unlock()
end

script.on_init(setup)
script.on_configuration_changed(setup)

script.on_event({
  defines.events.on_player_created,
  defines.events.on_player_joined_game,
  defines.events.on_player_respawned
}, function(event)
  give(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_research_finished, function(event)
  if event.research.name == signal_prerequisite then
    check_signal_unlock()
    return
  end

  if event.research.name == signal_tech then
    print_to_force(event.research.force, {"heliopause-foundry.signal-researched"})
  end
end)

script.on_nth_tick(60, function()
  init()

  for player_index in pairs(storage.pending) do
    give(game.get_player(player_index))
  end

  check_signal_unlock()
end)
