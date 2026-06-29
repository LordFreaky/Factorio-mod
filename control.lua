local STARTING_EQUIPMENT = {
  robots = 10,
  batteries = 3,
  solar_panels = 15
}

local function give_starting_equipment(player)
  if not player or not player.valid or not player.character then
    return false
  end

  local character = player.character

  -- Give construction robots to the player's inventory.
  character.insert{name = "construction-robot", count = STARTING_EQUIPMENT.robots}

  -- Access the armor slot through the character.
  local armor_inventory = character.get_inventory(defines.inventory.character_armor)
  if not armor_inventory or not armor_inventory.valid then
    player.print("Heliopause Foundry: Could not access armor inventory.")
    return false
  end

  local armor_stack = armor_inventory[1]

  -- Equip modular armor.
  if not armor_stack.set_stack{name = "modular-armor", count = 1} then
    player.print("Heliopause Foundry: Could not equip modular armor.")
    return false
  end

  -- Ensure the armor has an equipment grid.
  local grid = armor_stack.grid or armor_stack.create_grid()
  if not grid or not grid.valid then
    player.print("Heliopause Foundry: Could not create armor equipment grid.")
    return false
  end

  -- Clear any existing equipment, just in case.
  grid.clear()

  -- Add personal roboport.
  if not grid.put{name = "personal-roboport-equipment"} then
    player.print("Heliopause Foundry: Could not insert personal roboport.")
    return false
  end

  -- Add batteries.
  for i = 1, STARTING_EQUIPMENT.batteries do
    if not grid.put{name = "battery-equipment"} then
      player.print("Heliopause Foundry: Could not insert battery " .. i .. ".")
      return false
    end
  end

  -- Add portable solar panels.
  for i = 1, STARTING_EQUIPMENT.solar_panels do
    if not grid.put{name = "solar-panel-equipment"} then
      player.print("Heliopause Foundry: Could not insert solar panel " .. i .. ".")
      return false
    end
  end

  player.print("Heliopause Foundry: Starting construction equipment installed.")
  return true
end

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  give_starting_equipment(player)
end)
