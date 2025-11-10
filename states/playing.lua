-- Playing state - main gameplay
local Coin = require("entities.coin")
local PowerMeter = require("entities.powermeter")
local Cards = require("systems.cards")
local CoinUpgrades = require("systems.coins")
local Responsive = require("utils.responsive")

local Playing = {}

function Playing:enter(previous_state, game_data)
    -- Handle parameter confusion from shop (first param might be game_data)
    if previous_state and previous_state.souls then
        game_data = previous_state
        previous_state = nil
    end
    
    -- If returning from shop, restore game data
    if game_data then
        self.souls = game_data.souls
        self.flips = game_data.flips
        self.consecutive_tails = 0  -- Reset tails counter when returning from shop
        self.consecutive_heads = game_data.consecutive_heads or 0
        self.streak_multiplier = game_data.streak_multiplier or 1.0
        self.coin_tier = game_data.coin_tier or "bronze"
        self.flip_history = game_data.flip_history
        self.owned_cards = game_data.owned_cards
        self.flips_since_shop = game_data.flips_since_shop or 0
    else
        -- New game
        self.souls = 0
        self.flips = 0
        self.consecutive_tails = 0
        self.consecutive_heads = 0  -- Track heads streak
        self.streak_multiplier = 1.0  -- Streak bonus multiplier
        self.coin_tier = "level_1"
        self.flip_history = {}
        self.owned_cards = {}
        self.flips_since_shop = 0
    end
    
    -- Initialize streak tracking if not present
    if not self.consecutive_heads then
        self.consecutive_heads = 0
        self.streak_multiplier = 1.0
    end
    
    -- Multiplier box bump animation timers (only multipliers bump)
    -- Trigger coin mult bump if returning from shop (card effects may have changed)
    self.coin_mult_bump = game_data and 1.0 or 0
    self.streak_mult_bump = 0
    
    -- Set base value from coin tier
    local tier = CoinUpgrades.getTier(self.coin_tier)
    self.base_value = tier.base_value
    
    -- Create coin with value displayed
    local w, h = love.graphics.getDimensions()
    self.coin = Coin.new(w / 2, h / 2 - 30, 80, self.base_value, tier.coin_image, tier.is_silver)
    
    -- Create power meter
    self.power_meter = PowerMeter.new(w / 2 - 200, h - 120, 400, 40)
    
    -- Apply card effects to power meter
    self:applyCardEffects()
    
    -- Last flip result
    self.last_result = nil
    self.last_zone = nil
    self.last_earned = 0
    self.result_timer = 0
    self.result_display_time = 2.0
    
    -- Card details toggle
    self.show_card_details = false
end

function Playing:update(dt)
    self.coin:update(dt)
    
    -- Only update power meter when not flipping
    if not self.coin.is_flipping then
        self.power_meter:update(dt)
    end
    
    -- Update result display timer
    if self.result_timer > 0 then
        self.result_timer = self.result_timer - dt
    end
    
    -- Check if flip animation finished and we need to show result
    if not self.coin.is_flipping and self.coin.result then
        self:processFlipResult(self.coin.result)
        self.coin.result = nil
    end
    
    -- Update multiplier box bump animations (only multipliers bump)
    if self.coin_mult_bump > 0 then
        self.coin_mult_bump = self.coin_mult_bump - dt * 8
        if self.coin_mult_bump < 0 then self.coin_mult_bump = 0 end
    end
    if self.streak_mult_bump > 0 then
        self.streak_mult_bump = self.streak_mult_bump - dt * 8
        if self.streak_mult_bump < 0 then self.streak_mult_bump = 0 end
    end
end

function Playing:draw()
    -- Get actual rendering dimensions (canvas if active, otherwise window)
    local w, h
    local canvas = love.graphics.getCanvas()
    if canvas then
        w, h = canvas:getDimensions()
    else
        -- Use pixel dimensions for high DPI displays (but not on web)
        if not IsWebBuild then
            local dpiscale = love.graphics.getDPIScale()
            if dpiscale and dpiscale > 1 then
                w, h = love.graphics.getPixelDimensions()
            else
                w, h = love.graphics.getDimensions()
            end
        else
            w, h = love.graphics.getDimensions()
        end
    end
    
    local layout = Responsive.getPlayingLayout()
    local isMobile = Responsive.isMobile()
    
    -- Draw animated background using shader (directly, no canvas)
    if Shaders and Shaders.background then
        -- Ensure shader has correct resolution based on current render target
        pcall(function()
            Shaders.background:send("resolution", {w, h})
        end)
        
        love.graphics.setShader(Shaders.background)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setShader()
    else
        -- Fallback to solid black background
        love.graphics.setColor(DOS.BLACK)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
    
    -- Helper function to draw a DOS-style box
    local function drawBox(x, y, width, height, bg_color, border_color)
        -- Background
        love.graphics.setColor(bg_color)
        love.graphics.rectangle("fill", x, y, width, height)
        
        -- Border (simple 1px DOS style, no rounded corners)
        love.graphics.setColor(border_color or DOS.LIGHT_GRAY)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", x, y, width, height)
    end
    
    -- Souls display box - GREEN background with BLACK text (static)
    drawBox(layout.souls.x, layout.souls.y, layout.souls.width, layout.souls.height, DOS.GREEN, DOS.GREEN)
    love.graphics.setFont(Fonts.xlarge)
    love.graphics.setColor(DOS.BLACK)
    if isMobile then
        -- Mobile: larger number, right-aligned text
        love.graphics.printf(math.floor(self.souls), layout.souls.x + 10, layout.souls.y + 8, layout.souls.width - 100, "left")
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("SOULS", layout.souls.x + layout.souls.width - 90, layout.souls.y + 13, 80, "left")
    else
        -- Desktop: original layout
        love.graphics.printf(math.floor(self.souls), layout.souls.x + 10, layout.souls.y + 10, 160, "left")
        love.graphics.setColor(DOS.BLACK)
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("SOULS", layout.souls.x + 100, layout.souls.y + 15, 90, "left")
    end
    
    -- Tails counter box with warning - RED background with BLACK text
    local effects = Cards.applyEffects(self.owned_cards, self)
    local tails_limit = effects.tails_limit
    
    local tails_bg = DOS.RED
    
    if self.consecutive_tails >= tails_limit - 1 then
        tails_bg = DOS.BRIGHT_RED
    elseif self.consecutive_tails >= 1 then
        tails_bg = DOS.BROWN
    end
    
    drawBox(layout.tails.x, layout.tails.y, layout.tails.width, layout.tails.height, tails_bg, tails_bg)
    love.graphics.setFont(Fonts.xlarge)
    love.graphics.setColor(DOS.BLACK)
    if isMobile then
        love.graphics.printf(self.consecutive_tails .. "/" .. tails_limit, layout.tails.x + 10, layout.tails.y + 8, layout.tails.width - 100, "left")
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("TAILS", layout.tails.x + layout.tails.width - 90, layout.tails.y + 13, 80, "left")
    else
        love.graphics.printf(self.consecutive_tails .. "/" .. tails_limit, layout.tails.x + 10, layout.tails.y + 10, 80, "left")
        love.graphics.setColor(DOS.BLACK)
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("TAILS", layout.tails.x + 100, layout.tails.y + 15, 90, "left")
    end
    
    -- Flips counter box - CYAN background with BLACK text (static)
    drawBox(layout.flips.x, layout.flips.y, layout.flips.width, layout.flips.height, DOS.CYAN, DOS.CYAN)
    love.graphics.setFont(Fonts.xlarge)
    love.graphics.setColor(DOS.BLACK)
    if isMobile then
        love.graphics.printf(self.flips, layout.flips.x + 10, layout.flips.y + 8, layout.flips.width - 100, "left")
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("FLIPS", layout.flips.x + layout.flips.width - 90, layout.flips.y + 13, 80, "left")
    else
        love.graphics.printf(self.flips, layout.flips.x + 10, layout.flips.y + 10, 80, "left")
        love.graphics.setColor(DOS.BLACK)
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("FLIPS", layout.flips.x + 100, layout.flips.y + 15, 90, "left")
    end
    
    -- Multiplier boxes side by side with "x" between them
    local coin_mult_offset = self.coin_mult_bump * 3  -- Small bump down
    local streak_mult_offset = self.streak_mult_bump * 3  -- Small bump down
    local card_mult = effects.heads_value_multiplier * effects.universal_multiplier
    
    -- Card Multiplier box (left side) - BLUE background with BLACK text
    drawBox(layout.coinMult.x, layout.coinMult.y + coin_mult_offset, layout.coinMult.width, layout.coinMult.height, DOS.BRIGHT_BLUE, DOS.BRIGHT_BLUE)
    love.graphics.setFont(Fonts.xxlarge)
    love.graphics.setColor(DOS.BLACK)
    love.graphics.printf(string.format("%.2fx", card_mult), layout.coinMult.x, layout.coinMult.y + 10 + coin_mult_offset, layout.coinMult.width, "center")
    love.graphics.setColor(DOS.BLACK)
    love.graphics.setFont(Fonts.small)
    love.graphics.printf("COIN", layout.coinMult.x, layout.coinMult.y + 40 + coin_mult_offset, layout.coinMult.width, "center")
    
    -- "×" symbol in the middle
    love.graphics.setFont(Fonts.xxlarge)
    love.graphics.setColor(DOS.LIGHT_GRAY)
    love.graphics.printf("×", layout.multSeparator.x, layout.multSeparator.y, 16, "center")
    
    -- Streak Multiplier box (right side) - colored background with BLACK text
    local streak_bg = DOS.LIGHT_GRAY
    if self.consecutive_heads >= 10 then
        -- Red hot streak!
        streak_bg = DOS.BRIGHT_RED
    elseif self.consecutive_heads >= 5 then
        -- Magenta warm streak
        streak_bg = DOS.BRIGHT_MAGENTA
    elseif self.consecutive_heads >= 1 then
        -- Yellow building streak
        streak_bg = DOS.YELLOW
    end
    
    drawBox(layout.streakMult.x, layout.streakMult.y + streak_mult_offset, layout.streakMult.width, layout.streakMult.height, streak_bg, streak_bg)
    love.graphics.setFont(Fonts.xxlarge)
    love.graphics.setColor(DOS.BLACK)
    love.graphics.printf(string.format("%.2fx", self.streak_multiplier), layout.streakMult.x, layout.streakMult.y + 10 + streak_mult_offset, layout.streakMult.width, "center")
    love.graphics.setColor(DOS.BLACK)
    love.graphics.setFont(Fonts.small)
    love.graphics.printf("STREAK", layout.streakMult.x, layout.streakMult.y + 40 + streak_mult_offset, layout.streakMult.width, "center")
    
    -- Owned cards display (right side, hidden on mobile)
    if layout.showCards and #self.owned_cards > 0 then
        love.graphics.setColor(0.8, 0.8, 0.9)
        love.graphics.setFont(Fonts.medium)
        love.graphics.printf("CARDS (C)", w - 160, layout.cardsY, 150, "left")
        
        if self.show_card_details then
            -- Detailed card view with descriptions
            for i, owned in ipairs(self.owned_cards) do
                local card_def = Cards.getCard(owned.id)
                if card_def then
                    local card_y = 45 + (i - 1) * 85
                    local card_bg = DOS.DARK_GRAY
                    
                    drawBox(w - 180, card_y, 170, 80, card_bg, card_bg)
                    
                    -- Level 2 and 3 get special border decorations
                    if owned.level >= 2 then
                        love.graphics.setColor(DOS.YELLOW)
                        love.graphics.setLineWidth(2)
                        love.graphics.rectangle("line", w - 178, card_y + 2, 166, 76)
                    end
                    if owned.level >= 3 then
                        love.graphics.setColor(DOS.BRIGHT_CYAN)
                        love.graphics.setLineWidth(1)
                        love.graphics.rectangle("line", w - 175, card_y + 5, 160, 70)
                    end
                    
                    -- Card name with level stars
                    local level_stars = string.rep("*", owned.level)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.setFont(Fonts.smallMed)
                    love.graphics.printf(level_stars .. " " .. card_def.name, w - 175, card_y + 8, 160, "left")
                    
                    love.graphics.setColor(card_def.rarity.color)
                    love.graphics.setFont(Fonts.tiny)
                    love.graphics.printf("Lv." .. owned.level .. " - " .. card_def.rarity.name, w - 175, card_y + 24, 160, "left")
                    
                    love.graphics.setColor(0.9, 0.9, 0.9)
                    love.graphics.setFont(Fonts.small)
                    love.graphics.printf(card_def.description, w - 175, card_y + 40, 160, "left")
                    
                    -- Show effect
                    local effect = card_def.effect(owned.level, self)
                    local Shop = require("states.shop")
                    local effect_text = Shop:formatEffect(effect, owned.level)
                    love.graphics.setColor(0.5, 1, 0.5)
                    love.graphics.setFont(Fonts.tiny)
                    love.graphics.printf(effect_text, w - 175, card_y + 62, 160, "left")
                end
            end
        else
            -- Compact card view
            for i, owned in ipairs(self.owned_cards) do
                local card_def = Cards.getCard(owned.id)
                if card_def then
                    local card_y = 45 + (i - 1) * 45
                    local card_bg = DOS.DARK_GRAY
                    
                    drawBox(w - 160, card_y, 150, 40, card_bg, card_bg)
                    
                    -- Level 2 and 3 get special border decorations
                    if owned.level >= 2 then
                        love.graphics.setColor(DOS.YELLOW)
                        love.graphics.setLineWidth(2)
                        love.graphics.rectangle("line", w - 158, card_y + 2, 146, 36)
                    end
                    if owned.level >= 3 then
                        love.graphics.setColor(DOS.BRIGHT_CYAN)
                        love.graphics.setLineWidth(1)
                        love.graphics.rectangle("line", w - 155, card_y + 5, 140, 30)
                    end
                    
                    -- Card name with level stars
                    local level_stars = string.rep("*", owned.level)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.setFont(Fonts.smallMed)
                    love.graphics.printf(level_stars .. " " .. card_def.name, w - 155, card_y + 8, 140, "left")
                    
                    love.graphics.setColor(card_def.rarity.color)
                    love.graphics.setFont(Fonts.tiny)
                    love.graphics.printf("Lv." .. owned.level, w - 155, card_y + 24, 140, "left")
                end
            end
        end
    end
    
    -- Debug hints (smaller on mobile)
    love.graphics.setColor(DOS.DARK_GRAY)
    love.graphics.setFont(isMobile and Fonts.tiny or Fonts.small)
    love.graphics.printf("S: Shop", layout.hints.x, layout.hints.y, 70, "left")
    if not isMobile then
        love.graphics.printf("C: Cards", layout.hints.x, layout.hints.y + 15, 70, "left")
    end
    
    if self.consecutive_tails >= tails_limit - 1 then
        love.graphics.setColor(DOS.BRIGHT_RED)
        love.graphics.setFont(isMobile and Fonts.medium or Fonts.large)
        love.graphics.printf("WARNING: One more tails and you lose!", 
            0, layout.warning.y, w, "center")
    end
    
    -- Update coin position for responsive layout
    self.coin.x = layout.coin.x
    self.coin.y = layout.coin.y
    self.coin.radius = layout.coin.radius
    
    -- Draw coin with owned cards for gem display
    self.coin:draw(self.owned_cards)
    
    -- Update power meter position for responsive layout
    self.power_meter.x = layout.powerMeter.x
    self.power_meter.y = layout.powerMeter.y
    self.power_meter.width = layout.powerMeter.width
    self.power_meter.height = layout.powerMeter.height
    
    -- Draw power meter
    self.power_meter:draw()
    
    -- Display current speed multiplier (disabled)
    -- local speed_mult = self.power_meter.speed / self.power_meter.base_speed
    -- local speed_color = DOS.LIGHT_GRAY
    -- if speed_mult > 1.0 then
    --     speed_color = DOS.BRIGHT_RED  -- Red for fast
    -- else
    --     speed_color = DOS.BRIGHT_GREEN  -- Green for slow
    -- end
    -- love.graphics.setColor(speed_color)
    -- love.graphics.setFont(Fonts.medium)
    -- love.graphics.printf(string.format("Speed: %.2fx", speed_mult), 
    --     self.power_meter.x, self.power_meter.y - 25, self.power_meter.width, "center")
    
    -- Display last result in a DOS-style box
    if self.result_timer > 0 and self.last_result then
        local alpha = math.min(1, self.result_timer / 0.5)
        local result_text = ""
        local result_border = DOS.LIGHT_GRAY
        local result_color = DOS.WHITE
        
        if self.last_result == "heads" then
            result_text = "HEADS! +" .. math.floor(self.last_earned) .. " SOULS"
            result_border = DOS.BRIGHT_GREEN
            result_color = DOS.BRIGHT_GREEN
        elseif self.last_result == "tails" then
            if self.last_earned > 0 then
                result_text = "TAILS! +" .. math.floor(self.last_earned) .. " SOULS"
            else
                result_text = "TAILS!"
            end
            result_border = DOS.BRIGHT_RED
            result_color = DOS.BRIGHT_RED
        elseif self.last_result == "edge" then
            result_text = "EDGE LANDING!!! +" .. math.floor(self.last_earned) .. " SOULS"
            result_border = DOS.YELLOW
            result_color = DOS.YELLOW
        end
        
        -- Draw DOS-style result box
        local box_y = layout.result.y + 100
        love.graphics.setColor(DOS.BLACK[1], DOS.BLACK[2], DOS.BLACK[3], alpha)
        love.graphics.rectangle("fill", layout.result.x, box_y, layout.result.width, layout.result.height - 30)
        
        love.graphics.setColor(result_border[1], result_border[2], result_border[3], alpha)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", layout.result.x, box_y, layout.result.width, layout.result.height - 30)
        
        love.graphics.setColor(result_color[1], result_color[2], result_color[3], alpha)
        love.graphics.setFont(isMobile and Fonts.large or Fonts.huge)
        love.graphics.printf(result_text, layout.result.x, box_y + 12, layout.result.width, "center")
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Playing:mousepressed(x, y, button)
    if button == 1 and self.coin:isHovered(x, y) then
        -- Get the zone first, then pass it to flip
        local zone = self.power_meter:hit()
        if self.coin:flip(zone) then
            self:doFlip(zone)
        end
    end
end

function Playing:keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" and not self.coin.is_flipping then
        -- Get the zone first, then pass it to flip
        local zone = self.power_meter:hit()
        if self.coin:flip(zone) then
            self:doFlip(zone)
        end
    elseif key == "s" then
        -- Debug: Open shop
        self:openShop()
    elseif key == "c" then
        -- Toggle card details view
        self.show_card_details = not self.show_card_details
    end
end

function Playing:doFlip(zone)
    -- Use the zone passed in (already hit from mousepressed/keypressed)
    self.last_zone = zone
    
    -- Zone now directly determines the result - pure skill!
    local result = zone.result
    
    self.coin.result = result
    self.coin.zone = zone
    self.flips = self.flips + 1
    self.flips_since_shop = self.flips_since_shop + 1
    table.insert(self.flip_history, result)
    
    -- Check if shop should trigger (every 10 flips)
    if self.flips_since_shop >= 10 then
        self.should_open_shop = true
    end
end

function Playing:processFlipResult(result)
    self.last_result = result
    self.result_timer = self.result_display_time
    
    -- Get card effects
    local effects = Cards.applyEffects(self.owned_cards, self)
    
    -- Get the zone multiplier from the coin (stored during flip)
    local zone_multiplier = self.coin.zone and self.coin.zone.multiplier or 1.0
    
    -- Add edge multiplier bonus from cards
    if result == "edge" then
        zone_multiplier = zone_multiplier + effects.edge_multiplier_bonus
    end
    
    if result == "heads" then
        -- Increment heads streak and increase multiplier by +0.1x
        self.consecutive_heads = self.consecutive_heads + 1
        self.streak_multiplier = self.streak_multiplier + 0.1
        
        -- Trigger streak multiplier bump animation (only streak changes on heads)
        self.streak_mult_bump = 1.0
        
        local earned = self.base_value * zone_multiplier * effects.heads_value_multiplier * effects.universal_multiplier * self.streak_multiplier * 100
        -- Multiply by 100 to convert to souls
        
        -- Debug output
        print("Heads! Base: " .. self.base_value .. " x Zone: " .. zone_multiplier .. " x HeadsMulti: " .. effects.heads_value_multiplier .. " x UniversalMulti: " .. effects.universal_multiplier .. " x StreakMulti: " .. self.streak_multiplier .. " x100 = " .. earned .. " souls")
        print("Owned cards: " .. #self.owned_cards)
        for _, card in ipairs(self.owned_cards) do
            print("  - " .. card.id .. " (Level " .. card.level .. ")")
        end
        
        self.souls = self.souls + earned
        self.last_earned = earned
        self.consecutive_tails = 0
        
        -- Play heads sound
        Sounds.heads:stop()
        Sounds.heads:play()
    elseif result == "tails" then
        -- Check if tails should be ignored
        local total_tails = 0
        for _, flip in ipairs(self.flip_history) do
            if flip == "tails" then
                total_tails = total_tails + 1
            end
        end
        
        local effective_tails = math.max(0, total_tails - effects.ignored_tails)
        
        -- Tails halves the heads streak (rounded down)
        self.consecutive_heads = math.floor(self.consecutive_heads / 2)
        -- Recalculate multiplier based on halved streak
        self.streak_multiplier = 1.0 + (self.consecutive_heads * 0.1)
        
        -- Trigger multiplier bump animations
        self.streak_mult_bump = 1.0
        
        -- Tails can earn souls with Silver Lining card
        local earned = effects.tails_value * effects.universal_multiplier * 100
        -- Multiply by 100 to convert to souls
        self.souls = self.souls + earned
        self.last_earned = earned
        
        -- Count this tail towards consecutive if not ignored
        if total_tails > effects.ignored_tails then
            self.consecutive_tails = self.consecutive_tails + 1
        end
        
        -- Debug output
        print("Tails! Consecutive: " .. self.consecutive_tails .. " / " .. effects.tails_limit)
        print("Owned cards: " .. #self.owned_cards)
        for _, card in ipairs(self.owned_cards) do
            print("  - " .. card.id .. " (Level " .. card.level .. ")")
        end
        
        -- Play tails sound
        Sounds.tails:stop()
        Sounds.tails:play()
        
        -- Check for loss condition (using card-modified limit)
        if self.consecutive_tails >= effects.tails_limit then
            self:gameOver()
        end
    elseif result == "edge" then
        -- Edge counts as a heads for streak purposes!
        self.consecutive_heads = self.consecutive_heads + 1
        self.streak_multiplier = self.streak_multiplier + 0.1
        
        -- Trigger streak multiplier bump animation (only streak changes on edge)
        self.streak_mult_bump = 1.0
        
        local earned = self.base_value * 10 * zone_multiplier * effects.universal_multiplier * self.streak_multiplier * 100
        -- Multiply by 100 to convert to souls
        self.souls = self.souls + earned
        self.last_earned = earned
        self.consecutive_tails = 0
        
        -- Play upgrade coin sound for edge landing (special celebration!)
        Sounds.upgradeCoin:stop()
        Sounds.upgradeCoin:play()
    end
    
    -- Open shop if needed (after result is processed)
    if self.should_open_shop then
        self.should_open_shop = false
        self:openShop()
    end
end

function Playing:gameOver()
    -- Cancel shop opening if it was scheduled
    self.should_open_shop = false
    
    -- Play game lose sound
    Sounds.gameLose:stop()
    Sounds.gameLose:play()
    
    local Gamestate = require("utils.gamestate")
    local GameOver = require("states.gameover")
    
    GameOver.final_souls = self.souls
    GameOver.final_flips = self.flips
    GameOver.flip_history = self.flip_history
    
    Gamestate.switch(GameOver)
end

function Playing:openShop()
    local Gamestate = require("utils.gamestate")
    local Shop = require("states.shop")
    
    -- Package game data to pass to shop
    local game_data = {
        souls = self.souls,
        flips = self.flips,
        consecutive_tails = self.consecutive_tails,
        consecutive_heads = self.consecutive_heads,
        streak_multiplier = self.streak_multiplier,
        coin_tier = self.coin_tier,
        flip_history = self.flip_history,
        owned_cards = self.owned_cards,
        flips_since_shop = 0  -- Reset counter
    }
    
    Gamestate.switch(Shop, self, game_data)
end

function Playing:applyCardEffects()
    -- Get card effects
    local effects = Cards.applyEffects(self.owned_cards, self)
    
    -- Apply meter speed modifier
    if effects.meter_speed_multiplier ~= 1.0 then
        self.power_meter.base_speed = 2.3 * effects.meter_speed_multiplier
        self.power_meter.speed = self.power_meter.base_speed
    end
    
    -- Rebuild power meter zones with card effects
    self.power_meter:rebuildZones(effects)
end

return Playing

