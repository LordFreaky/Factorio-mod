local rocket_silo_tech = "rocket-silo"
local signal_tech = "heliopause-foundry-signal-from-space"

local function has_prerequisite(technology, prerequisite_name)
  if not technology.prerequisites then return false end

  for _, prerequisite in pairs(technology.prerequisites) do
    if prerequisite == prerequisite_name then
      return true
    end
  end

  return false
end

local function add_prerequisite(technology, prerequisite_name)
  technology.prerequisites = technology.prerequisites or {}

  if not has_prerequisite(technology, prerequisite_name) then
    table.insert(technology.prerequisites, prerequisite_name)
  end
end

for technology_name, technology in pairs(data.raw.technology) do
  if technology_name ~= signal_tech and has_prerequisite(technology, rocket_silo_tech) then
    add_prerequisite(technology, signal_tech)
  end
end
