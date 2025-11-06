-- Power Meter entity with timing zones
local PowerMeter = {}
PowerMeter.__index = PowerMeter

function PowerMeter.new(x, y, width, height)
    local self = setmetatable({}, PowerMeter)
    self.x = x
    self.y = y
    self.width = width or 400
    self.height = height or 40
    
    -- Meter state
    self.raw_position = 0  -- 0 to 1, linear position for timing
    self.position = 0      -- 0 to 1, eased position for display
    self.base_speed = 2.3  -- Base cycles per second (slightly slower)
    self.speed = self.base_speed
    self.direction = 1     -- 1 = forward, -1 = returning
    self.return_speed_multiplier = 5.0  -- Return speed is 5x faster
    self.active = true
    
    -- Color constants (matching Balatro style)
    local HEADS_COLOR = {0.4, 0.6, 1.0}    -- Bright blue
    local TAILS_COLOR = {0.95, 0.4, 0.35}  -- Red-orange (not used for zones, bar is all red)
    local EDGE_COLOR = {1, 0.84, 0}        -- Gold for edge zones
    local BAR_COLOR = {0.95, 0.4, 0.35}    -- Red base bar color

    -- Size constants (in percentage points, 0-100)
    local XXS = 1.5
    local XS = 5
    local SM = 8
    local MD = 10
    local LG = 18
    local XL = 25
    local XXL = 35
    local XXXL = 40
    
    -- Helper function to create zones from position and size
    -- position: 0.0 to 1.0 (where the zone starts)
    -- size: percentage points (will be converted to 0.0-1.0 range)
    local function zone(result, position, size, multiplier)
        local color = HEADS_COLOR
        if result == "tails" then
            color = TAILS_COLOR
        elseif result == "edge" then
            color = EDGE_COLOR
        end
        local start = position
        local stop = position + (size / 100)  -- Convert percentage to decimal
        return {result = result, start = start, stop = stop, color = color, multiplier = multiplier or 1.0}
    end
    
    -- Store bar color for drawing
    self.bar_color = BAR_COLOR
    
    -- Define only heads and edge zones - tails will fill the gaps automatically
    local special_zones = {
        -- zone("heads", 0.2,  MD,  1.0),
        zone("heads", 0.3,   XXL,  1.0),
        zone("edge",  0.65, XXS, 1.5),
        -- zone("heads", 0.65,  MD,  1.2),
        -- zone("heads", 0.8,  MD,  1.0)
    }
    
    -- Auto-generate full zone list with tails filling gaps
    self.zones = {}
    table.sort(special_zones, function(a, b) return a.start < b.start end)
    
    local current_pos = 0.0
    for _, special_zone in ipairs(special_zones) do
        -- Fill gap with tails if there is one
        if current_pos < special_zone.start then
            local gap_size = (special_zone.start - current_pos) * 100  -- Convert to percentage points
            table.insert(self.zones, zone("tails", current_pos, gap_size, 1.0))
        end
        -- Add the special zone
        table.insert(self.zones, special_zone)
        current_pos = special_zone.stop
    end
    
    -- Fill remaining space with tails
    if current_pos < 1.0 then
        local remaining_size = (1.0 - current_pos) * 100  -- Convert to percentage points
        table.insert(self.zones, zone("tails", current_pos, remaining_size, 1.0))
    end
    
    -- Randomize initial speed
    self:randomizeSpeed()
    
    -- Hit state
    self.last_hit_zone = nil
    self.hit_timer = 0
    self.hit_display_time = 0.5
    
    -- Bump animation state
    self.bump_timer = 0
    self.bump_duration = 0.3
    self.bump_offset = 0
    self.heads_lift_offset = 0
    
    return self
end

function PowerMeter:update(dt)
    if self.active then
        if self.direction == 1 then
            -- Moving forward
            self.raw_position = self.raw_position + self.speed * dt
            
            if self.raw_position >= 1 then
                self.raw_position = 1
                self.direction = -1  -- Start returning
            end
        else
            -- Moving backward (much faster)
            self.raw_position = self.raw_position - (self.speed * self.return_speed_multiplier * dt)
            
            if self.raw_position <= 0 then
                self.raw_position = 0
                self.direction = 1  -- Start moving forward again
            end
        end
        
        -- Apply easing curve (cubic ease-in) only when moving forward
        if self.direction == 1 then
            local t = self.raw_position
            self.position = t * t * t  -- Cubic curve
        else
            -- Linear return (but fast)
            self.position = self.raw_position
        end
    end
    
    -- Update hit display timer
    if self.hit_timer > 0 then
        self.hit_timer = self.hit_timer - dt
    end
    
    -- Update bump animation
    if self.bump_timer > 0 then
        self.bump_timer = self.bump_timer - dt
        local progress = 1 - (self.bump_timer / self.bump_duration)
        
        -- Bar bump: quick down, bounce back up
        if progress < 0.3 then
            -- Drop down quickly
            self.bump_offset = (progress / 0.3) * 8
        else
            -- Bounce back up with slight overshoot
            local bounce_progress = (progress - 0.3) / 0.7
            self.bump_offset = 8 * (1 - bounce_progress) * (1 - bounce_progress * 0.8)
        end
        
        -- Heads lift: opposite direction, slightly delayed
        if progress < 0.2 then
            -- Delay slightly
            self.heads_lift_offset = 0
        elseif progress < 0.4 then
            -- Lift up
            local lift_progress = (progress - 0.2) / 0.2
            self.heads_lift_offset = -lift_progress * 4
        else
            -- Settle back down
            local settle_progress = (progress - 0.4) / 0.6
            self.heads_lift_offset = -4 * (1 - settle_progress)
        end
    else
        self.bump_offset = 0
        self.heads_lift_offset = 0
    end
end

function PowerMeter:randomizeSpeed()
    -- Randomize speed by ±25% to prevent muscle memory
    local variance = 0.25
    local random_factor = 1 + (love.math.random() * 2 - 1) * variance
    self.speed = self.base_speed * random_factor
end

function PowerMeter:draw()
    -- Apply bump offset to bar position
    local bar_y = self.y + self.bump_offset
    
    -- Draw chunky layered shadow (moves with bar)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", self.x + 8, bar_y + 8, self.width, self.height, 6, 6)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", self.x + 4, bar_y + 4, self.width, self.height, 6, 6)
    
    -- Draw red base bar (entire bar is red, moves down on bump)
    love.graphics.setColor(self.bar_color)
    love.graphics.rectangle("fill", self.x, bar_y, self.width, self.height, 6, 6)
    
    -- Draw red meter outline (chunky and bold)
    love.graphics.setColor(self.bar_color[1] * 0.7, self.bar_color[2] * 0.7, self.bar_color[3] * 0.7)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", self.x, bar_y, self.width, self.height, 6, 6)
    
    -- Draw moving indicator as a growing bar (BEHIND the blocks)
    if self.active then
        local bar_width = self.position * self.width
        
        -- Draw the filling bar (more transparent, runs behind blocks, moves with bar)
        love.graphics.setColor(1, 1, 1, 0.15)
        love.graphics.rectangle("fill", self.x, bar_y, bar_width, self.height, 6, 6)
        
        -- Draw the edge of the bar - brighter and taller for visibility
        if bar_width > 2 then
            local indicator_x = self.x + bar_width
            local indicator_top = bar_y - 10  -- Extend above the bar
            local indicator_bottom = bar_y + self.height + 10  -- Extend below the bar
            
            -- Draw glow effect behind the indicator
            love.graphics.setColor(1, 1, 1, 0.3)
            love.graphics.setLineWidth(8)
            love.graphics.line(indicator_x, indicator_top, indicator_x, indicator_bottom)
            
            -- Draw the main bright indicator line
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.setLineWidth(4)
            love.graphics.line(indicator_x, indicator_top, indicator_x, indicator_bottom)
        end
    end
    
    -- Draw heads and edge zones as blocks sitting on top with enhanced depth
    for _, zone in ipairs(self.zones) do
        if zone.result == "heads" or zone.result == "edge" then
            local zone_x = self.x + zone.start * self.width
            local zone_width = (zone.stop - zone.start) * self.width
            local block_height = self.height - 3
            
            -- Heads blocks lift up slightly, bar bumps down
            local block_y = self.y + self.heads_lift_offset
            
            -- Draw glow effect for edge zones (special!)
            if zone.result == "edge" then
                -- Multiple layers of glow (moves with block)
                love.graphics.setColor(zone.color[1], zone.color[2], zone.color[3], 0.15)
                love.graphics.rectangle("fill", zone_x - 8, block_y - 8, zone_width + 16, block_height + 16, 6, 6)
                love.graphics.setColor(zone.color[1], zone.color[2], zone.color[3], 0.25)
                love.graphics.rectangle("fill", zone_x - 4, block_y - 4, zone_width + 8, block_height + 8, 5, 5)
                love.graphics.setColor(zone.color[1], zone.color[2], zone.color[3], 0.35)
                love.graphics.rectangle("fill", zone_x - 2, block_y - 2, zone_width + 4, block_height + 4, 4, 4)
            end
            
            -- Draw drop shadow (underneath the block)
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("fill", zone_x + 3, block_y + 3, zone_width, block_height, 3, 3)
            
            -- Draw the main block
            love.graphics.setColor(zone.color)
            love.graphics.rectangle("fill", zone_x, block_y, zone_width, block_height, 3, 3)
            
            -- Draw inner shadow (top and left edges for depth)
            love.graphics.setColor(0, 0, 0, 0.25)
            love.graphics.rectangle("fill", zone_x + 1, block_y + block_height - 4, zone_width - 2, 3)
            love.graphics.rectangle("fill", zone_x + 1, block_y + 1, 2, block_height - 2)
            
            -- Draw highlight on top edge (3D effect)
            love.graphics.setColor(1, 1, 1, 0.6)
            love.graphics.rectangle("fill", zone_x + 2, block_y + 1, zone_width - 4, 3)
            
            -- Draw bright highlight on right edge
            love.graphics.setColor(zone.color[1] * 1.3, zone.color[2] * 1.3, zone.color[3] * 1.3, 0.7)
            love.graphics.rectangle("fill", zone_x + zone_width - 3, block_y + 2, 2, block_height - 4)
            
            -- Draw block border (darker outline)
            love.graphics.setColor(zone.color[1] * 0.5, zone.color[2] * 0.5, zone.color[3] * 0.5)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", zone_x, block_y, zone_width, block_height, 3, 3)
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

function PowerMeter:hit()
    -- Determine which zone was hit
    for _, zone in ipairs(self.zones) do
        if self.position >= zone.start and self.position < zone.stop then
            self.last_hit_zone = zone
            self.hit_timer = self.hit_display_time
            
            -- Trigger bump animation
            self:triggerBump()
            
            -- Randomize speed for next cycle after the flip
            self:randomizeSpeed()
            
            return zone
        end
    end
    
    -- Fallback (shouldn't happen)
    return self.zones[3]  -- Normal zone
end

function PowerMeter:triggerBump()
    -- Start the bump animation
    self.bump_timer = self.bump_duration
end

function PowerMeter:reset()
    self.raw_position = 0
    self.position = 0
    self.direction = 1
    self.active = true
    self:randomizeSpeed()
end

function PowerMeter:pause()
    self.active = false
end

function PowerMeter:resume()
    self.active = true
end

return PowerMeter

