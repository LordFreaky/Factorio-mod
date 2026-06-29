local signal_prerequisite = "rocket-silo"

data:extend({
  {
    type = "technology",
    name = "heliopause-foundry-signal-from-space",
    icon = "__base__/graphics/technology/rocket-silo.png",
    icon_size = 256,
    enabled = false,
    visible_when_disabled = false,
    prerequisites = {signal_prerequisite},
    effects = {},
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 30
    },
    order = "z-h-f-a"
  }
})
