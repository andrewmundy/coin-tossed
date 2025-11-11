-- Coin entity with flip animation
local Coin = {}
Coin.__index = Coin

function Coin.new(x, y, radius, value, coin_image, is_silver)
    local self = setmetatable({}, Coin)
    self.x = x
    self.y = y
    self.base_y = y
    self.radius = radius or 80
    self.flip_angle = 0  -- Angle for the flip rotation
    self.is_flipping = false
    self.flip_timer = 0
    self.flip_duration = 0.6  -- Shorter flip duration for snappier feel
    self.result = nil
    self.zone = nil
    self.flip_speed = 3  -- Number of rotations during the flip
    self.value = value or 1  -- Coin value to display
    self.glow_timer = 0  -- Timer for animated glow
    self.coin_image = coin_image or "coin1"  -- Which coin image to use
    self.is_silver = is_silver or false  -- Whether to apply silver shader
    return self
end

function Coin:update(dt)
    -- Update glow animation
    self.glow_timer = self.glow_timer + dt
    
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

function Coin:draw(owned_cards)
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    -- Calculate 3D flip effect using cosine for height scaling (vertical flip end-over-end)
    -- This creates the effect of the coin flipping vertically (tumbling through the air)
    local scale_y = 1.0
    if self.is_flipping then
        scale_y = math.cos(self.flip_angle)
    end
    
    -- Determine which side is showing (heads or tails)
    -- Extended threshold so coin face is hidden for longer during rotation
    local showing_heads = scale_y > 0.6  -- Only show heads when mostly facing forward
    local showing_tails = scale_y < -0.2  -- Only show tails when mostly facing backward
    local showing_edge = not showing_heads and not showing_tails  -- Show edge in between
    
    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.circle("fill", 8, 8, self.radius * 0.9)
    
    -- Apply the 3D scaling (vertically for end-over-end flip)
    love.graphics.scale(1, math.abs(scale_y))
    
    -- Draw coin edge (visible during flip when coin is thin or transitioning)
    if self.is_flipping and showing_edge then
        local edge_color = self.is_silver and {0.5, 0.5, 0.6} or {0.6, 0.4, 0.1}  -- Silver or gold edge
        love.graphics.setColor(edge_color[1], edge_color[2], edge_color[3], 1)
        love.graphics.circle("fill", 0, 0, self.radius)
    end
    
    -- Darken the coin when showing back side (for visual feedback during flip)
    local brightness = 1.0
    if self.is_flipping and showing_tails then
        brightness = 0.4  -- Darker back side
    end
    -- Only draw coin image if not showing edge (hide coin face during edge display)
    if not (self.is_flipping and showing_edge) then
        love.graphics.setColor(brightness, brightness, brightness, 1)
        
        -- Draw coin image
        if Images then
            local img = Images[self.coin_image] or Images.coin1
            local img_w = img:getWidth()
            local img_h = img:getHeight()
            
            -- Calculate scale to fit the radius
            local scale = (self.radius * 2) / math.max(img_w, img_h)
            
            -- Apply silver shader if this coin is silver
            if self.is_silver and Shaders and Shaders.silverCoin then
                love.graphics.setShader(Shaders.silverCoin)
            end
            
            -- Draw the image centered
            love.graphics.draw(img, 0, 0, 0, scale, scale / math.max(0.01, math.abs(scale_y)), img_w / 2, img_h / 2)
            
            -- Reset shader
            if self.is_silver and Shaders and Shaders.silverCoin then
                love.graphics.setShader()
            end
            
            -- Draw gems slotted around the coin based on owned cards (hide during flip animation)
            if owned_cards and Images.gems and not self.is_flipping then
                local Cards = require("systems.shared.cards")
                local owned_gems = {}
                -- Collect unique gems from owned cards
                for _, owned in ipairs(owned_cards) do
                    local card_def = Cards.getCard(owned.id)
                    if card_def and card_def.gem then
                        local gem_id = card_def.gem
                        owned_gems[gem_id] = (owned_gems[gem_id] or 0) + 1
                    end
                end
                
                -- Position gems around the coin in a circle
                local gem_positions = {}
                for gem_id, count in pairs(owned_gems) do
                    table.insert(gem_positions, {gem_id = gem_id, count = count})
                end
                
                -- Sort for consistent positioning
                table.sort(gem_positions, function(a, b) return a.gem_id < b.gem_id end)
                
                for i, gem_data in ipairs(gem_positions) do
                    local gem = Images.gems[gem_data.gem_id]
                    if gem then
                        local angle = (i - 1) * (math.pi * 2 / #gem_positions) - math.pi / 2
                        local gem_scale = 6  -- Increased from 3 to better fill the coin slots
                        local orbit_radius = self.radius * 0.50  -- Adjusted from 0.75 to position gems better in slots
                        local gem_x = math.cos(angle) * orbit_radius - (gem:getWidth() * gem_scale / 2)
                        local gem_y = math.sin(angle) * orbit_radius - (gem:getHeight() * gem_scale / 2)
                        
                        -- Fine-tune individual gem positions
                        if i == 1 then
                            -- Gem 1: move down and left
                            gem_x = gem_x - 3
                            gem_y = gem_y + 8
                        elseif i == 2 then
                            -- Gem 2: move up and left
                            gem_x = gem_x - 3
                            gem_y = gem_y - 14
                        end
                        
                        -- Calculate pulsing effect using sine wave
                        local pulse = math.sin(self.glow_timer * 2) * 0.2 + 0.8  -- Oscillates between 0.6 and 1.0
                        
                        -- Get gem color from predefined table
                        local gem_r, gem_g, gem_b = 1, 1, 1
                        if Images.gemColors and Images.gemColors[gem_data.gem_id] then
                            local color = Images.gemColors[gem_data.gem_id]
                            gem_r = color[1]
                            gem_g = color[2]
                            gem_b = color[3]
                        end
                        
                        -- Calculate center position for glow
                        local glow_center_x = math.cos(angle) * orbit_radius
                        local glow_center_y = math.sin(angle) * orbit_radius
                        
                        -- Apply fine-tuning
                        if i == 1 then
                            glow_center_x = glow_center_x - 3
                            glow_center_y = glow_center_y + 8
                        elseif i == 2 then
                            glow_center_x = glow_center_x - 3
                            glow_center_y = glow_center_y - 14
                        end
                        
                        -- Draw radial gradient glow with gem's actual color
                        local glow_radius = gem:getWidth() * gem_scale * 0.6
                        for layer = 5, 1, -1 do
                            local radius_mult = layer * 0.4
                            local alpha = (0.3 / layer) * pulse
                            
                            -- Mix white (inner) with gem color (outer)
                            local color_mix = (layer - 1) / 4  -- 0 to 1 from inner to outer
                            local glow_r = gem_r + (1 - gem_r) * (1 - color_mix)
                            local glow_g = gem_g + (1 - gem_g) * (1 - color_mix)
                            local glow_b = gem_b + (1 - gem_b) * (1 - color_mix)
                            
                            love.graphics.setColor(glow_r, glow_g, glow_b, alpha)
                            love.graphics.circle("fill", glow_center_x, glow_center_y, glow_radius * radius_mult)
                        end
                        
                        -- Draw the main gem
                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.draw(gem, gem_x, gem_y, 0, gem_scale, gem_scale)
                    end
                end
            end
        else
            -- Fallback to circle if image not loaded
            love.graphics.setColor(1, 0.84, 0)
            love.graphics.circle("fill", 0, 0, self.radius)
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

