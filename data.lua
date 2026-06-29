data:extend({
  {
    type = "technology",
    name = "heliopause-foundry-signal-from-space",
    icon = "__heliopause-foundry__/graphics/technology/space-signal.png",
    icon_size = 1024,

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
