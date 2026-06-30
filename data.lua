local signal_tech = "heliopause-foundry-signal-from-space"
local foundry_base = "heliopause-foundry-base"
local foundry_discovery = "heliopause-foundry-discover-foundry-base"
local solar_system_edge_tech = "stellar-discovery-solar-system-edge"

local signal_icon = "__heliopause-foundry__/graphics/technology/space-signal.png"
local foundry_base_icon = "__heliopause-foundry__/graphics/space-locations/foundry-base.png"
local foundry_base_icon_size = 1254

local function add_prerequisite(technology_name, prerequisite_name)
  local technology = data.raw.technology[technology_name]
  if not technology then return end

  technology.prerequisites = technology.prerequisites or {}

  for _, prerequisite in pairs(technology.prerequisites) do
    if prerequisite == prerequisite_name then
      return
    end
  end

  table.insert(technology.prerequisites, prerequisite_name)
end

data:extend({
  {
    type = "technology",
    name = signal_tech,
    icon = signal_icon,
    icon_size = 1024,

    enabled = false,
    visible_when_disabled = true,

    prerequisites = {"radar"},

    research_trigger = {
      type = "scripted"
    },

    effects = {},

    order = "z-h-f-a"
  }
})

local solar_system_edge = data.raw["space-location"]["solar-system-edge"]
local foundry_planet = table.deepcopy(data.raw.planet["nauvis"])

foundry_planet.name = foundry_base
foundry_planet.localised_name = {"space-location-name.heliopause-foundry-base"}
foundry_planet.localised_description = {"space-location-description.heliopause-foundry-base"}

foundry_planet.icons = nil
foundry_planet.icon = foundry_base_icon
foundry_planet.icon_size = foundry_base_icon_size

foundry_planet.starmap_icons = nil
foundry_planet.starmap_icon = foundry_base_icon
foundry_planet.starmap_icon_size = foundry_base_icon_size
foundry_planet.starmap_icon_orientation = 0

foundry_planet.distance = solar_system_edge.distance - 2
foundry_planet.orientation = solar_system_edge.orientation - 0.01
foundry_planet.magnitude = 1.1
foundry_planet.map_seed_offset = 424242
foundry_planet.label_orientation = 0.15
foundry_planet.parked_platforms_orientation = 0.25

data:extend({
  foundry_planet,

  {
    type = "space-connection",
    name = "aquilo-to-heliopause-foundry-base",
    from = "aquilo",
    to = foundry_base,
    length = 97500,
    icon = foundry_base_icon,
    icon_size = foundry_base_icon_size
  },

  {
    type = "space-connection",
    name = "heliopause-foundry-base-to-solar-system-edge",
    from = foundry_base,
    to = "solar-system-edge",
    length = 2500,
    icon = foundry_base_icon,
    icon_size = foundry_base_icon_size
  },

  {
    type = "technology",
    name = foundry_discovery,

    icons = {
      {
        icon = foundry_base_icon,
        icon_size = foundry_base_icon_size
      },
      {
        icon = "__space-age__/graphics/icons/planet-route.png",
        icon_size = 64,
        scale = 0.65,
        shift = {-72, 72},
        draw_background = true
      }
    },

    prerequisites = {
      "planet-discovery-aquilo"
    },

    effects = {
      {
        type = "unlock-space-location",
        space_location = foundry_base,
        icon = foundry_base_icon,
        icon_size = foundry_base_icon_size,
        use_icon_overlay_constant = true
      }
    },

    unit = {
      count = 2000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"metallurgic-science-pack", 1},
        {"electromagnetic-science-pack", 1},
        {"agricultural-science-pack", 1},
        {"cryogenic-science-pack", 1}
      },
      time = 60
    },

    order = "z-h-f-b"
  }
})

add_prerequisite(solar_system_edge_tech, foundry_discovery)
