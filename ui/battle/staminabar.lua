-- Stamina bar UI component for Battle Mode
-- TODO: Implement stamina bar display

local StaminaBar = {}
StaminaBar.__index = StaminaBar

function StaminaBar.new(x, y, width, height)
    local self = setmetatable({}, StaminaBar)
    
    self.x = x or 0
    self.y = y or 0
    self.width = width or 200
    self.height = height or 20
    
    return self
end

function StaminaBar:draw(current_stamina, max_stamina)
    -- TODO: Draw stamina bar with current/max stamina
    -- Should show visual representation of stamina remaining
end

return StaminaBar

