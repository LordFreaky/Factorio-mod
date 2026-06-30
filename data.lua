data:extend({
  {
    type = "technology",
    name = "heliopause-foundry-signal-from-space",
    icon = "__heliopause-foundry__/graphics/technology/space-signal.png",
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

local foundry_base = "heliopause-foundry-base"
local foundry_discovery = "heliopause-foundry-discover-foundry-base"

local solar_system_edge = data.raw["space-location"]["solar-system-edge"]
local foundry_planet = table.deepcopy(data.raw.planet["nauvis"])

foundry_planet.name = foundry_base
foundry_planet.localised_name = {"space-location-name.heliopause-foundry-base"}
foundry_planet.localised_description = {"space-location-description.heliopause-foundry-base"}
foundry_planet.icon = "__heliopause-foundry__/graphics/space-locations/foundry-base.png"
foundry_planet.icon_size = 1024

foundry_planet.distance = solar_system_edge.distance + 2
foundry_planet.orientation = solar_system_edge.orientation + 0.015
foundry_planet.magnitude = 1.1
foundry_planet.map_seed_offset = 424242
foundry_planet.label_orientation = 0.15
foundry_planet.parked_platforms_orientation = 0.25

data:extend({
  foundry_planet,

  {
    type = "space-connection",
    name = "solar-system-edge-to-heliopause-foundry-base",
    from = "solar-system-edge",
    to = foundry_base,
    length = 2500,
    icon = "__base__/graphics/icons/radar.png",
    icon_size = 64
  },

  {
    type = "technology",
    name = foundry_discovery,
    icon = "__heliopause-foundry__/graphics/space-locations/foundry-base.png",
    icon_size = 1024,

    prerequisites = {
      "stellar-discovery-solar-system-edge"
    },

    effects = {
  {
    type = "unlock-space-location",
    space_location = foundry_base,
    icon = "__heliopause-foundry__/graphics/space-locations/foundry-base.png",
    icon_size = 1024
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

    order = "z-h-f-b"
  }
})
