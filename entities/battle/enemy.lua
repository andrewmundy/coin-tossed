-- Enemy entity for Battle Mode
-- TODO: Implement enemy entity with health, AI, attacks, etc.

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, enemy_type)
    local self = setmetatable({}, Enemy)
    
    self.x = x or 0
    self.y = y or 0
    self.type = enemy_type or "basic"
    self.health = 50
    self.max_health = 50
    
    -- TODO: Add enemy-specific stats, AI, attacks, etc.
    
    return self
end

function Enemy:update(dt)
    -- TODO: Update enemy AI, movement, attacks
end

function Enemy:draw()
    -- TODO: Draw enemy sprite/representation
end

return Enemy

