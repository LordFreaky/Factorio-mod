local signal_tech = "heliopause-foundry-signal-from-space"
local foundry_base = "heliopause-foundry-base"
local foundry_discovery = "heliopause-foundry-discover-foundry-base"
local solar_system_edge_tech = "stellar-discovery-solar-system-edge"

local signal_icon = "__heliopause-foundry__/graphics/technology/space-signal.png"
local foundry_base_icon = "__heliopause-foundry__/graphics/space-locations/foundry-base.png"
local foundry_base_icon_size = 1254

local foundry_base_radius = 768
local foundry_base_diameter = foundry_base_radius * 2

local foundry_resource_replacements = {
  ["coal"] = "heliopause-foundry-carbonized-regolith",
  ["tungsten-ore"] = "heliopause-foundry-slag-deposit",
  ["calcite"] = "heliopause-foundry-catalyst-crystal",
  ["sulfuric-acid-geyser"] = "heliopause-foundry-corrosive-vent"
}

local foundry_resource_graphics = {
  ["heliopause-foundry-carbonized-regolith"] = "__heliopause-foundry__/graphics/resources/carbonized-regolith.png",
  ["heliopause-foundry-slag-deposit"] = "__heliopause-foundry__/graphics/resources/slag-deposit.png",
  ["heliopause-foundry-catalyst-crystal"] = "__heliopause-foundry__/graphics/resources/catalyst-crystal.png",
  ["heliopause-foundry-corrosive-vent"] = "__heliopause-foundry__/graphics/resources/corrosive-vent.png"
}

local foundry_resource_map_colors = {
  ["heliopause-foundry-carbonized-regolith"] = {r = 0.08, g = 0.07, b = 0.06},
  ["heliopause-foundry-slag-deposit"] = {r = 0.35, g = 0.30, b = 0.26},
  ["heliopause-foundry-catalyst-crystal"] = {r = 0.95, g = 0.72, b = 0.32},
  ["heliopause-foundry-corrosive-vent"] = {r = 0.90, g = 0.75, b = 0.12}
}

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

local function create_foundry_resource(source_name, target_name)
  local source = data.raw.resource[source_name]

  if not source then
    error("Missing resource prototype: " .. source_name)
  end

  local resource = table.deepcopy(source)

  resource.name = target_name
  resource.localised_name = {"entity-name." .. target_name}
  resource.localised_description = {"entity-description." .. target_name}
  resource.map_color = foundry_resource_map_colors[target_name] or resource.map_color

  local graphic = foundry_resource_graphics[target_name]

  if graphic then
    resource.stages = {
      sheet = {
        filename = graphic,
        priority = "extra-high",
        width = 512,
        height = 512,
        frame_count = 1,
        variation_count = 1,
        scale = 0.125
      }
    }

    resource.stage_counts = {1}
    resource.stages_effect = nil
  end

  return resource
end

local function replace_map_gen_resource(map_gen_settings, source_name, target_name)
  map_gen_settings.autoplace_settings = map_gen_settings.autoplace_settings or {}
  map_gen_settings.autoplace_settings.entity = map_gen_settings.autoplace_settings.entity or {}

  local entity_autoplace = map_gen_settings.autoplace_settings.entity
  entity_autoplace.settings = entity_autoplace.settings or {}

  local source_settings = entity_autoplace.settings[source_name]

  entity_autoplace.settings[target_name] = table.deepcopy(source_settings or {
    frequency = 1,
    size = 1,
    richness = 1
  })

  entity_autoplace.settings[source_name] = {
    frequency = 0,
    size = 0,
    richness = 0
  }
end

local foundry_resource_prototypes = {}

for source_name, target_name in pairs(foundry_resource_replacements) do
  foundry_resource_prototypes[#foundry_resource_prototypes + 1] = create_foundry_resource(source_name, target_name)
end

data:extend(foundry_resource_prototypes)

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
local foundry_planet = table.deepcopy(data.raw.planet["vulcanus"])

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

foundry_planet.map_gen_settings = table.deepcopy(foundry_planet.map_gen_settings or {})
foundry_planet.map_gen_settings.width = foundry_base_diameter
foundry_planet.map_gen_settings.height = foundry_base_diameter
foundry_planet.map_gen_settings.starting_points = {
  {x = 0, y = 0}
}

for source_name, target_name in pairs(foundry_resource_replacements) do
  replace_map_gen_resource(foundry_planet.map_gen_settings, source_name, target_name)
end

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
    icon = foundry_base_icon,
    icon_size = foundry_base_icon_size,

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
