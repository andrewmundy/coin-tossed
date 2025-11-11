-- Power Meter entity with timing zones
local Config = require("config")
local PowerMeter = {}
PowerMeter.__index = PowerMeter

function PowerMeter.new(x, y, width, height)
    local self = setmetatable({}, PowerMeter)
    self.x = x
    self.y = y
    self.width = width or 400
    self.height = height or 40

    -- Meter state
    self.raw_position = 0 -- 0 to 1, linear position for timing
    self.position = 0     -- 0 to 1, eased position for display
    self.base_speed = Config.POWER_METER.base_speed
    self.speed = self.base_speed
    self.direction = 1 -- 1 = forward, -1 = returning
    self.return_speed_multiplier = Config.POWER_METER.return_speed_multiplier
    self.active = true
    self.last_speed_was_fast = false -- Track speed alternation

    -- DOS Color constants
    local HEADS_COLOR = DOS.BRIGHT_BLUE
    -- More saturated colors for higher level heads zones
    local HEADS_COLOR_LEVEL_2 = { 0.2, 0.4, 1.0 } -- More saturated blue for level 2
    local HEADS_COLOR_LEVEL_3 = { 0.0, 0.5, 1.0 } -- Even more saturated cyan-blue for level 3
    local TAILS_COLOR = DOS.RED
    local EDGE_COLOR = DOS.YELLOW
    local BAR_COLOR = DOS.RED

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
    -- level: optional level for heads zones (affects color saturation)
    local function zone(result, position, size, multiplier, level)
        local color = HEADS_COLOR
        if result == "tails" then
            color = TAILS_COLOR
        elseif result == "edge" then
            color = EDGE_COLOR
        elseif result == "heads" and level then
            -- Use more saturated colors for higher levels
            if level == 2 then
                color = HEADS_COLOR_LEVEL_2
            elseif level == 3 then
                color = HEADS_COLOR_LEVEL_3
            end
        end
        local start = position
        local stop = position + (size / 100) -- Convert percentage to decimal
        return { result = result, start = start, stop = stop, color = color, multiplier = multiplier or 1.0 }
    end

    -- Store bar color for drawing
    self.bar_color = BAR_COLOR

    -- Store zone helper function for rebuilding
    self.zone_helper = zone
    self.zone_sizes = { XXS = XXS, XS = XS, SM = SM, MD = MD, LG = LG, XL = XL, XXL = XXL, XXXL = XXXL }

    -- Build initial zones (will be rebuilt with card effects later)
    self:rebuildZones()

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
    self.edge_lift_offset = 0

    return self
end

function PowerMeter:update(dt)
    if self.active then
        if self.direction == 1 then
            -- Moving forward
            self.raw_position = self.raw_position + self.speed * dt

            if self.raw_position >= 1 then
                self.raw_position = 1
                self.direction = -1 -- Start returning
            end
        else
            -- Moving backward (much faster)
            self.raw_position = self.raw_position - (self.speed * self.return_speed_multiplier * dt)

            if self.raw_position <= 0 then
                self.raw_position = 0
                self.direction = 1 -- Start moving forward again
            end
        end

        -- Apply easing curve (cubic ease-in) only when moving forward
        if self.direction == 1 then
            local t = self.raw_position
            self.position = t * t * t -- Cubic curve
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

        -- Edge lift: more pronounced, different timing (bouncy!)
        if progress < 0.15 then
            -- Initial delay
            self.edge_lift_offset = 0
        elseif progress < 0.35 then
            -- Quick lift up (faster than heads)
            local lift_progress = (progress - 0.15) / 0.2
            self.edge_lift_offset = -lift_progress * 8
        elseif progress < 0.55 then
            -- Bounce down a bit
            local bounce_progress = (progress - 0.35) / 0.2
            self.edge_lift_offset = -8 + bounce_progress * 4
        else
            -- Settle back to position
            local settle_progress = (progress - 0.55) / 0.45
            self.edge_lift_offset = -4 * (1 - settle_progress)
        end
    else
        self.bump_offset = 0
        self.heads_lift_offset = 0
        self.edge_lift_offset = 0
    end
end

function PowerMeter:randomizeSpeed()
    -- Alternate between fast (>1.0x) and slow (<1.0x) speeds
    -- Tighter variance: 0.8x to 1.2x total range

    if self.last_speed_was_fast then
        -- Generate a slow speed (0.8x to 0.95x)
        local random_factor = 0.8 + (love.math.random() * 0.15)
        self.speed = self.base_speed * random_factor
        self.last_speed_was_fast = false
    else
        -- Generate a fast speed (1.05x to 1.2x)
        local random_factor = 1.05 + (love.math.random() * 0.15)
        self.speed = self.base_speed * random_factor
        self.last_speed_was_fast = true
    end
end

function PowerMeter:rebuildZones(effects)
    effects = effects or {
        heads_zone_size_multiplier = 1.0,
        edge_zone_size_multiplier = 1.0,
        extra_heads_zones = 0
    }

    local zone = self.zone_helper
    local XXS, XS, SM, MD, LG, XL, XXL, XXXL = self.zone_sizes.XXS, self.zone_sizes.XS, self.zone_sizes.SM,
        self.zone_sizes.MD, self.zone_sizes.LG, self.zone_sizes.XL, self.zone_sizes.XXL, self.zone_sizes.XXXL

    -- Base zones - iterate over config arrays to create multiple zones
    local special_zones = {}

    -- Add all heads zones from config
    -- Level multipliers: Level 1 = 1.0x, Level 2 = 1.25x, Level 3 = 1.5x
    local level_multipliers = {
        [1] = 1.0,
        [2] = 1.25,
        [3] = 1.5
    }

    for _, heads_zone in ipairs(Config.POWER_METER.heads) do
        local level = heads_zone.level or 1 -- Default to level 1 if not specified
        local multiplier = level_multipliers[level] or 1.0
        table.insert(special_zones, zone("heads", heads_zone.position,
            heads_zone.size * effects.heads_zone_size_multiplier, multiplier, level))
    end

    -- Add all edge zones from config
    for _, edge_zone in ipairs(Config.POWER_METER.edge) do
        table.insert(special_zones, zone("edge", edge_zone.position,
            edge_zone.size * effects.edge_zone_size_multiplier, 1.5))
    end

    -- Add extra heads zones based on card effects
    local extra_positions = { 0.15, 0.50, 0.78 } -- Positions for extra zones
    for i = 1, math.min(effects.extra_heads_zones, 3) do
        table.insert(special_zones, zone("heads", extra_positions[i], XS * effects.heads_zone_size_multiplier, 1.0))
    end

    -- Auto-generate full zone list with tails filling gaps
    self.zones = {}
    table.sort(special_zones, function(a, b) return a.start < b.start end)

    local current_pos = 0.0
    for _, special_zone in ipairs(special_zones) do
        -- Fill gap with tails if there is one
        if current_pos < special_zone.start then
            local gap_size = (special_zone.start - current_pos) * 100 -- Convert to percentage points
            table.insert(self.zones, zone("tails", current_pos, gap_size, 1.0))
        end
        -- Add the special zone
        table.insert(self.zones, special_zone)
        current_pos = special_zone.stop
    end

    -- Fill remaining space with tails
    if current_pos < 1.0 then
        local remaining_size = (1.0 - current_pos) * 100 -- Convert to percentage points
        table.insert(self.zones, zone("tails", current_pos, remaining_size, 1.0))
    end
end

function PowerMeter:draw()
    -- Apply bump offset to bar position
    local bar_y = self.y + self.bump_offset

    -- Draw red base bar (entire bar is red, moves down on bump) - NO ROUNDED CORNERS
    love.graphics.setColor(self.bar_color)
    love.graphics.rectangle("fill", self.x, bar_y, self.width, self.height)

    -- Draw red meter outline (matches bar color)
    love.graphics.setColor(self.bar_color)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.x, bar_y, self.width, self.height)

    -- Draw moving indicator as a growing bar (BEHIND the blocks)
    if self.active then
        local bar_width = self.position * self.width

        -- Draw the filling bar - visible bar that grows/shrinks with dithered shading
        if bar_width > 0 then
            -- Dither pattern size (smaller = finer pattern)
            local dither_size = 4

            -- Draw dithered pattern (checkerboard style)
            for x = 0, math.floor(bar_width / dither_size) do
                for y = 0, math.floor(self.height / dither_size) do
                    local px = self.x + x * dither_size
                    local py = bar_y + y * dither_size

                    -- Checkerboard pattern: alternate based on position
                    local is_dark = ((x + y) % 2 == 0)

                    if is_dark then
                        -- Darker squares
                        love.graphics.setColor(0, 0, 0, 1)
                    else
                        -- Lighter squares
                        love.graphics.setColor(0, 0, 0, 0)
                    end

                    -- Draw dither square (clamp to bar bounds)
                    local square_width = math.min(dither_size, bar_width - x * dither_size)
                    local square_height = math.min(dither_size, self.height - y * dither_size)

                    if square_width > 0 and square_height > 0 then
                        love.graphics.rectangle("fill", px, py, square_width, square_height)
                    end
                end
            end

            -- Draw bar border/edge
            if bar_width > 2 then
                -- Draw bright edge line at the end of the bar for visibility
                local indicator_x = self.x + bar_width
                love.graphics.setColor(0, 0, 0, 0.9)
                love.graphics.setLineWidth(3)
                love.graphics.line(indicator_x, bar_y, indicator_x, bar_y + self.height)
            end
        end
    end

    -- Draw heads and edge zones as blocks sitting on top with enhanced depth
    for _, zone in ipairs(self.zones) do
        if zone.result == "heads" or zone.result == "edge" then
            local zone_x = self.x + zone.start * self.width
            local zone_width = (zone.stop - zone.start) * self.width
            local block_height = self.height - 3

            -- Use different lift offsets for heads vs edge zones
            local block_y = self.y + (zone.result == "edge" and self.edge_lift_offset or self.heads_lift_offset)

            -- Draw glow effect for edge zones (special!)
            if zone.result == "edge" then
                -- Multiple layers of glow (moves with block)
                love.graphics.setColor(zone.color[1], zone.color[2], zone.color[3], 0.15)
                love.graphics.rectangle("fill", zone_x - 8, block_y - 8, zone_width + 16, block_height + 16)
                love.graphics.setColor(zone.color[1], zone.color[2], zone.color[3], 0.25)
                love.graphics.rectangle("fill", zone_x - 4, block_y - 4, zone_width + 8, block_height + 8)
                love.graphics.setColor(zone.color[1], zone.color[2], zone.color[3], 0.35)
                love.graphics.rectangle("fill", zone_x - 2, block_y - 2, zone_width + 4, block_height + 4)
            end

            -- Draw the main block (no shadows for DOS style)
            love.graphics.setColor(zone.color)
            love.graphics.rectangle("fill", zone_x, block_y, zone_width, block_height)

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

            -- Draw multiplier text on heads zones
            if zone.result == "heads" and zone.multiplier then
                -- Format multiplier text (e.g., "1.25x", "1.5x", or "1.0x")
                local multiplier_text = string.format("%.2fx", zone.multiplier)
                -- Clean up formatting: "1.00x" -> "1.0x", "1.25x" -> "1.25x", "1.50x" -> "1.5x"
                multiplier_text = multiplier_text:gsub("0+x$", "x")  -- Remove trailing zeros before x
                multiplier_text = multiplier_text:gsub("%.x", ".0x") -- Add .0 if decimal was removed

                -- Use small font that fits on the bar
                if Fonts and Fonts.small then
                    love.graphics.setFont(Fonts.small)
                end

                -- Calculate text position (centered on the bar)
                local text_x = zone_x + zone_width / 2
                local text_y = block_y + block_height / 2

                -- Draw text shadow for better visibility
                love.graphics.setColor(0, 0, 0, 0.8)
                love.graphics.printf(multiplier_text, text_x - zone_width / 2 + 1, text_y + 1, zone_width, "center")

                -- Draw main text (white for visibility)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.printf(multiplier_text, text_x - zone_width / 2, text_y, zone_width, "center")
            end
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
    return self.zones[3] -- Normal zone
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
