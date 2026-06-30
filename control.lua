local robots = 10
local signal_tech = "heliopause-foundry-signal-from-space"
local radar_tech = "radar"
local radar_entity = "radar"

local min_signal_delay = 5 * 60 * 60
local max_signal_delay = 20 * 60 * 60
local max_unpowered_radar_ticks = 30 * 60

local function random_signal_delay()
  local rng = game.create_random_generator()
  local range = max_signal_delay - min_signal_delay + 1
  local rolled = math.floor(rng() * range)

  if rolled >= range then
    rolled = range - 1
  end

  return min_signal_delay + rolled
end

local function init()
  storage.equipped = storage.equipped or {}
  storage.pending = storage.pending or {}
  storage.hf_signal_researched_forces = storage.hf_signal_researched_forces or {}
  storage.hf_signal_unlock_ticks = storage.hf_signal_unlock_ticks or {}
  storage.hf_signal_unpowered_since_ticks = storage.hf_signal_unpowered_since_ticks or {} 
  storage.hf_signal_unlock_tick = nil
end

local function print_to_force(force, message)
  for _, player in pairs(game.players) do
    if player.valid and player.force and player.force.name == force.name then
      player.print(message)
    end
  end
end

local function force_has_researched_technology(force, technology_name)
  local tech = force.technologies[technology_name]

  return tech and tech.researched
end

local function radar_has_power(radar)
  local status = radar.status

  return status and status ~= defines.entity_status.no_power and status ~= defines.entity_status.low_power
end

local function get_force_radar_status(force)
  local has_radar = false
  
  for _, surface in pairs(game.surfaces) do
        for _, radar in pairs(surface.find_entities_filtered({name = radar_entity, force = force})) do
      has_radar = true

      if radar_has_power(radar) then
        return true, true
      end
    end
  end

  return has_radar, false
end

local function reset_signal_timer_for_force(force)
  storage.hf_signal_unlock_ticks[force.name] = nil
  storage.hf_signal_unpowered_since_ticks[force.name] = nil
end

local function give_start_items(player)
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

  if not armor.valid_for_read then
    if not armor.set_stack({name = "modular-armor", count = 1}) then return false end
  end

  local grid = armor.grid or armor.create_grid()
  if grid and grid.valid then
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
  end

  character.insert({name = "construction-robot", count = robots})

  storage.equipped[player.index] = true
  storage.pending[player.index] = nil

  return true
end

local function give_start_items_to_all()
  init()

  for _, player in pairs(game.players) do
    give_start_items(player)
  end
end

local function unlock_signal_for_force(force)
  local tech = force.technologies[signal_tech]

  if not tech then return end
  if tech.researched then return end
  if storage.hf_signal_researched_forces[force.name] then return end

  tech.enabled = true
  tech.visible_when_disabled = true
  tech.researched = true

  storage.hf_signal_researched_forces[force.name] = true
  reset_signal_timer_for_force(force)

  print_to_force(force, {"heliopause-foundry.signal-researched"})
end

local function update_signal_timer_for_force(force)
  local tech = force.technologies[signal_tech]

  if not tech then return end

  if tech.researched or storage.hf_signal_researched_forces[force.name] then
        reset_signal_timer_for_force(force)
    return
  end

  if not force_has_researched_technology(force, radar_tech) then
    reset_signal_timer_for_force(force)
    return
  end

  local has_radar, has_powered_radar = get_force_radar_status(force)

  if not has_radar then
    reset_signal_timer_for_force(force)
    return
  end

  local unlock_tick = storage.hf_signal_unlock_ticks[force.name]

  if not has_powered_radar then
    if not unlock_tick then
      storage.hf_signal_unpowered_since_ticks[force.name] = nil
      return
    end

    local unpowered_since_tick = storage.hf_signal_unpowered_since_ticks[force.name]

    if not unpowered_since_tick then
      storage.hf_signal_unpowered_since_ticks[force.name] = game.tick
      return
    end

    if game.tick - unpowered_since_tick > max_unpowered_radar_ticks then
      reset_signal_timer_for_force(force)
    end

    return
  end

  storage.hf_signal_unpowered_since_ticks[force.name] = nil

  if not unlock_tick then
    storage.hf_signal_unlock_ticks[force.name] = game.tick + random_signal_delay()
    print_to_force(force, {"heliopause-foundry.signal-unlocked"})
    return
  end

  if game.tick >= unlock_tick then
    unlock_signal_for_force(force)
  end
end

local function check_signal_unlock()
  init()

  for _, force in pairs(game.forces) do
    update_signal_timer_for_force(force)
  end
end

local function setup()
  init()
  give_start_items_to_all()
  check_signal_unlock()
end

script.on_init(setup)
script.on_configuration_changed(setup)

script.on_event({
  defines.events.on_player_created,
  defines.events.on_player_joined_game,
  defines.events.on_player_respawned
}, function(event)
  give_start_items(game.get_player(event.player_index))
end)

script.on_nth_tick(60, function()
  init()

  for player_index in pairs(storage.pending) do
    give_start_items(game.get_player(player_index))
  end

  check_signal_unlock()
end)
