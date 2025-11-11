-- Health bar UI component for Battle Mode
-- TODO: Implement health bar display

local HealthBar = {}
HealthBar.__index = HealthBar

function HealthBar.new(x, y, width, height)
    local self = setmetatable({}, HealthBar)
    
    self.x = x or 0
    self.y = y or 0
    self.width = width or 200
    self.height = height or 20
    
    return self
end

function HealthBar:draw(current_health, max_health)
    -- TODO: Draw health bar with current/max health
    -- Should show visual representation of health remaining
end

return HealthBar

