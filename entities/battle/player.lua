-- Player entity for Battle Mode
-- TODO: Implement player entity with health, stamina, position, etc.

local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    
    self.x = x or 0
    self.y = y or 0
    self.health = 100
    self.max_health = 100
    self.stamina = 100
    self.max_stamina = 100
    
    -- TODO: Add weapon, stats, etc.
    
    return self
end

function Player:update(dt)
    -- TODO: Update player state
end

function Player:draw()
    -- TODO: Draw player sprite/representation
end

return Player

