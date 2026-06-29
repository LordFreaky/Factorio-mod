local robots = 10

local function init()
  storage.equipped = storage.equipped or {}
  storage.pending = storage.pending or {}
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
  if not grid.put({name = "personal-roboport-equipment", position = {x = 0, y = 0}}) then return false end

  for x = 2, 4 do
    if not grid.put({name = "battery-equipment", position = {x = x, y = 0}}) then return false end
  end

  for y = 2, 4 do
    for x = 0, 4 do
      if not grid.put({name = "solar-panel-equipment", position = {x = x, y = y}}) then return false end
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

script.on_init(give_all)
script.on_configuration_changed(give_all)

script.on_event({
  defines.events.on_player_created,
  defines.events.on_player_joined_game,
  defines.events.on_player_respawned
}, function(event)
  give(game.get_player(event.player_index))
end)

script.on_nth_tick(60, function()
  init()

  for player_index in pairs(storage.pending) do
    give(game.get_player(player_index))
  end
end)
