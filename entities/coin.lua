-- Coin entity with flip animation
local Coin = {}
Coin.__index = Coin

function Coin.new(x, y, radius, value)
    local self = setmetatable({}, Coin)
    self.x = x
    self.y = y
    self.base_y = y
    self.radius = radius or 80
    self.flip_angle = 0  -- Angle for the flip rotation
    self.is_flipping = false
    self.flip_timer = 0
    self.flip_duration = 0.5  -- Fixed quick duration
    self.result = nil
    self.zone = nil
    self.flip_speed = 3  -- Rotations during the flip (was 8, now 3 = ~1.5 full rotations)
    self.value = value or 1  -- Coin value to display
    return self
end

function Coin:update(dt)
    if self.is_flipping then
        self.flip_timer = self.flip_timer + dt
        local progress = self.flip_timer / self.flip_duration
        
        -- Flip rotation (spinning through the air)
        self.flip_angle = progress * math.pi * 2 * self.flip_speed
        
        -- Arc motion (coin goes up then down)
        local arc_height = 60
        self.y = self.base_y - math.sin(progress * math.pi) * arc_height
        
        if self.flip_timer >= self.flip_duration then
            self.is_flipping = false
            self.flip_timer = 0
            self.flip_angle = 0
            self.y = self.base_y
        end
    end
end

function Coin:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    -- Calculate 3D flip effect using cosine for height scaling (vertical flip)
    local scale_y = math.abs(math.cos(self.flip_angle))
    
    -- Determine which side is showing (heads or tails)
    local normalized_angle = self.flip_angle % (math.pi * 2)
    local showing_heads = math.cos(self.flip_angle) >= 0
    
    -- Draw chunky layered shadow (before scaling)
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.circle("fill", 10, 10, self.radius)
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.circle("fill", 6, 6, self.radius)
    
    -- Apply the 3D scaling (vertically)
    love.graphics.scale(1, scale_y)
    
    -- Draw coin body with side-specific color
    if showing_heads then
        -- Heads side - golden
        love.graphics.setColor(1, 0.84, 0)
    else
        -- Tails side - silver
        love.graphics.setColor(0.75, 0.75, 0.8)
    end
    love.graphics.circle("fill", 0, 0, self.radius)
    
    -- Draw coin outline (chunky and bold, thicker when viewed edge-on)
    local outline_width = 5 + (1 - scale_y) * 8
    if showing_heads then
        love.graphics.setColor(0.6, 0.45, 0)
    else
        love.graphics.setColor(0.4, 0.4, 0.45)
    end
    love.graphics.setLineWidth(outline_width)
    love.graphics.circle("line", 0, 0, self.radius)
    
    -- Draw face details when not edge-on
    if scale_y > 0.3 then
        if showing_heads then
            -- Heads: Display value
            love.graphics.setColor(0.9, 0.7, 0)
            local font_size = math.floor(self.radius * 0.6)
            local coin_font = love.graphics.newFont("assets/fonts/MorePerfectDOSVGA.ttf", font_size)
            love.graphics.setFont(coin_font)
            love.graphics.printf("$" .. self.value, -self.radius, -font_size / 2 / scale_y, self.radius * 2, "center")
        else
            -- Tails: Circle pattern
            love.graphics.setColor(0.6, 0.6, 0.65)
            love.graphics.setLineWidth(3)
            love.graphics.circle("line", 0, 0, self.radius * 0.4)
        end
    end
    
    love.graphics.pop()
    
    love.graphics.setColor(1, 1, 1)
end

function Coin:isHovered(mx, my)
    local dx = mx - self.x
    local dy = my - self.y
    return math.sqrt(dx * dx + dy * dy) <= self.radius
end

function Coin:flip(zone)
    if not self.is_flipping then
        self.is_flipping = true
        self.flip_timer = 0
        return true
    end
    return false
end

return Coin

