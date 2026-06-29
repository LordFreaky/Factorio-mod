data:extend({
  {
    type = "technology",
    name = "heliopause-foundry-signal-from-space",
    icon = "__base__/graphics/technology/rocket-silo.png",
    icon_size = 256,

    enabled = false,
    visible_when_disabled = true,

    prerequisites = {"rocket-silo"},

    research_trigger = {
      type = "scripted"
    },

    effects = {},

    order = "z-h-f-a"
  }
})
