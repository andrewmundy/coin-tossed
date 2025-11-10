-- Shop state for selecting upgrade cards
local Shop = {}

local Cards = require("systems.cards")
local CoinUpgrades = require("systems.coins")

function Shop:enter(previous_state, game_data)
    self.game_data = game_data
    self.previous_state = previous_state
    
    -- Generate 3 random cards (coin will be the 4th slot)
    local exclude_ids = {}
    for _, owned in ipairs(game_data.owned_cards) do
        local card_def = Cards.getCard(owned.id)
        if card_def and owned.level >= card_def.max_level then
            table.insert(exclude_ids, owned.id)
        end
    end
    
    self.shop_cards = Cards.generateShopCards(3, exclude_ids)
    
    -- Cards always show as level 1, but we track what level they'd become
    for _, shop_card in ipairs(self.shop_cards) do
        shop_card.level = 1 -- Always display as level 1
        shop_card.target_level = 1 -- Level you'd get if purchased
        for _, owned in ipairs(game_data.owned_cards) do
            if shop_card.card.id == owned.id then
                shop_card.target_level = owned.level + 1 -- Will level up existing card
                break
            end
        end
    end
    
    self.selected_index = nil
    self.hovered_index = nil
end

function Shop:update(dt)
    -- Nothing to update for now
end

function Shop:draw()
    local w, h = love.graphics.getDimensions()
    
    -- Helper function for DOS-style boxes (no shadows, no rounded corners)
    local function drawBox(x, y, width, height, bg_color, border_color)
        -- Background
        love.graphics.setColor(bg_color)
        love.graphics.rectangle("fill", x, y, width, height)
        -- Border
        love.graphics.setColor(border_color or DOS.LIGHT_GRAY)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", x, y, width, height)
    end
    
    -- DOS black background
    love.graphics.setColor(DOS.BLACK)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- HEADER - Top bar with souls and close button
    drawBox(0, 0, w, 60, DOS.BLUE, DOS.BLUE)
    
    -- Souls display centered in header
    love.graphics.setColor(DOS.BRIGHT_GREEN)
    love.graphics.setFont(Fonts.xxlarge)
    love.graphics.printf(math.floor(self.game_data.souls) .. " SOULS", 0, 15, w, "center")
    
    -- Close button (X) on the upper right
    local close_button_size = 40
    local close_button_x = w - close_button_size - 10
    local close_button_y = 10
    drawBox(close_button_x, close_button_y, close_button_size, close_button_size, DOS.RED, DOS.RED)
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.xxlarge)
    love.graphics.printf("X", close_button_x, close_button_y + 5, close_button_size, "center")
    
    -- "YOUR GEMS" section - wrapped layout (dynamic based on coin tier)
    local current_tier = CoinUpgrades.getTier(self.game_data.coin_tier)
    local max_card_slots = current_tier.max_card_slots
    local owned_card_width = 230
    local owned_card_height = 70
    local owned_spacing = 10
    local owned_y = 70
    
    -- Calculate wrapping layout (3 per row max)
    local cards_per_row = 3
    
    -- Title
    love.graphics.setColor(DOS.BRIGHT_CYAN)
    love.graphics.setFont(Fonts.large)
    love.graphics.printf("YOUR GEMS (" .. #self.game_data.owned_cards .. "/" .. max_card_slots .. ")", 20, owned_y, w - 40, "left")
    
    owned_y = owned_y + 35
    
    -- Track mouse position for hover
    local mx, my = love.mouse.getPosition()
    
    -- Draw all card slots in wrapped layout
    for i = 1, max_card_slots do
        local row = math.floor((i - 1) / cards_per_row)
        local col = (i - 1) % cards_per_row
        local cards_in_this_row = math.min(cards_per_row, max_card_slots - row * cards_per_row)
        
        -- Calculate total width for centering this row
        local row_width = cards_in_this_row * owned_card_width + (cards_in_this_row - 1) * owned_spacing
        local row_start_x = (w - row_width) / 2
        
        local owned_card_x = row_start_x + col * (owned_card_width + owned_spacing)
        local owned_card_y = owned_y + row * (owned_card_height + owned_spacing)
        local owned = self.game_data.owned_cards[i]
        
        -- Check if hovering over this slot
        local is_hovering = mx >= owned_card_x and mx <= owned_card_x + owned_card_width and
                            my >= owned_card_y and my <= owned_card_y + owned_card_height
        
        if owned then
            -- Filled slot - draw the owned card
            local card_def = Cards.getCard(owned.id)
            if card_def then
                -- Determine background color based on rarity
                local bg_color
                if card_def.rarity.name == "COMMON" then
                    bg_color = DOS.LIGHT_GRAY
                elseif card_def.rarity.name == "UNCOMMON" then
                    bg_color = DOS.BRIGHT_BLUE
                elseif card_def.rarity.name == "RARE" then
                    bg_color = DOS.MAGENTA
                elseif card_def.rarity.name == "LEGENDARY" then
                    bg_color = DOS.YELLOW
                else
                    bg_color = DOS.LIGHT_GRAY
                end
                
                -- Draw card box with level decorations
                drawBox(owned_card_x, owned_card_y, owned_card_width, owned_card_height, bg_color, bg_color)
                
                -- Level 2 and 3 get special border decorations
                if owned.level >= 2 then
                    love.graphics.setColor(DOS.YELLOW)
                    love.graphics.setLineWidth(2)
                    love.graphics.rectangle("line", owned_card_x + 2, owned_card_y + 2, owned_card_width - 4, owned_card_height - 4)
                end
                if owned.level >= 3 then
                    love.graphics.setColor(DOS.BRIGHT_CYAN)
                    love.graphics.setLineWidth(1)
                    love.graphics.rectangle("line", owned_card_x + 5, owned_card_y + 5, owned_card_width - 10, owned_card_height - 10)
                end
                
                -- Draw gem image if available (small version for owned cards)
                if Images and Images.gems and card_def.gem then
                    local gem = Images.gems[card_def.gem]
                    if gem then
                        local gem_scale = 2  -- Smaller scale for owned cards
                        local gem_x = owned_card_x + 8
                        local gem_y = owned_card_y + (owned_card_height / 2) - (gem:getHeight() * gem_scale / 2)
                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.draw(gem, gem_x, gem_y, 0, gem_scale, gem_scale)
                    end
                end
                
                -- Card name with level stars and level number
                local level_stars = string.rep("*", owned.level)
                love.graphics.setColor(DOS.BLACK)
                love.graphics.setFont(Fonts.small)
                
                if is_hovering then
                    -- Show sell price on hover (compact for horizontal layout)
                    local sell_price = math.floor(Cards.getCardCost(card_def, owned.level) * 0.5)
                    love.graphics.printf(level_stars .. " " .. card_def.name, owned_card_x + 5, owned_card_y + 5, owned_card_width - 10, "center")
                    love.graphics.printf("Lv." .. owned.level, owned_card_x + 5, owned_card_y + 22, owned_card_width - 10, "center")
                    love.graphics.setColor(DOS.RED)
                    love.graphics.setFont(Fonts.tiny)
                    love.graphics.printf("R-CLICK: " .. sell_price, owned_card_x + 5, owned_card_y + 40, owned_card_width - 10, "center")
                else
                    -- Normal display - compact layout
                    love.graphics.printf(level_stars .. " " .. card_def.name, owned_card_x + 5, owned_card_y + 8, owned_card_width - 10, "center")
                    love.graphics.printf("Lv." .. owned.level, owned_card_x + 5, owned_card_y + 25, owned_card_width - 10, "center")
                    
                    -- Effect preview (compact)
                    local effect = card_def.effect(owned.level, self.game_data)
                    local effect_text = self:formatEffect(effect, owned.level)
                    love.graphics.setColor(DOS.BLACK)
                    love.graphics.setFont(Fonts.tiny)
                    love.graphics.printf(effect_text, owned_card_x + 5, owned_card_y + 45, owned_card_width - 10, "center")
                end
            end
        else
            -- Empty slot - draw placeholder
            drawBox(owned_card_x, owned_card_y, owned_card_width, owned_card_height, DOS.DARK_GRAY, DOS.DARK_GRAY)
            love.graphics.setColor(DOS.LIGHT_GRAY)
            love.graphics.setFont(Fonts.small)
            love.graphics.printf("[ EMPTY SLOT ]", owned_card_x + 5, owned_card_y + 25, owned_card_width - 10, "center")
        end
    end
    
    -- Draw cards and coin at the bottom (3 cards + 1 coin = 4 slots)
    local card_width = 160
    local card_height = 200
    local card_spacing = 20
    local total_slots = 4  -- 3 cards + 1 coin
    local total_width = (total_slots * card_width) + ((total_slots - 1) * card_spacing)
    local start_x = (w - total_width) / 2  -- Centered
    local start_y = h - card_height - 100  -- Near bottom
    
    for i, shop_card in ipairs(self.shop_cards) do
        -- Skip maxed out cards
        if not shop_card.maxed_out then
            local card_x = start_x + (i - 1) * (card_width + card_spacing)
            local card_y = start_y
            
            -- Calculate card cost based on target level (with discount from Haggler card)
            local base_cost = Cards.getCardCost(shop_card.card, shop_card.target_level)
            local card_effects = Cards.applyEffects(self.game_data.owned_cards, self.game_data)
            local discount = card_effects.shop_discount
            local cost = math.floor(base_cost * (1 - discount))
            local can_afford = self.game_data.souls >= cost
            local is_upgrade = shop_card.target_level > 1
        
        -- Hover effect
        if self.hovered_index == i then
            card_y = card_y - 10
        end
        
        local rarity = shop_card.card.rarity
        
        -- DOS-style colored card backgrounds based on rarity
        local bg_color
        local border_color
        if not can_afford then
            -- Unaffordable cards have dark gray background with red border
            bg_color = DOS.DARK_GRAY
            border_color = DOS.RED
        else
            -- Affordable cards use rarity colors
            if rarity.name == "COMMON" then
                bg_color = DOS.LIGHT_GRAY
            elseif rarity.name == "UNCOMMON" then
                bg_color = DOS.BRIGHT_BLUE
            elseif rarity.name == "RARE" then
                bg_color = DOS.MAGENTA
            elseif rarity.name == "LEGENDARY" then
                bg_color = DOS.YELLOW
            else
                bg_color = DOS.LIGHT_GRAY
            end
            border_color = bg_color  -- Border matches background for affordable cards
        end
        
        -- Draw card with level-based decorations
        drawBox(card_x, card_y, card_width, card_height, bg_color, border_color)
        
        -- Level 2 and 3 get special border decorations
        if shop_card.target_level >= 2 and can_afford then
            love.graphics.setColor(DOS.YELLOW)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", card_x + 4, card_y + 4, card_width - 8, card_height - 8)
        end
        if shop_card.target_level >= 3 and can_afford then
            love.graphics.setColor(DOS.BRIGHT_CYAN)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", card_x + 8, card_y + 8, card_width - 16, card_height - 16)
        end
        
        -- Text color depends on affordability
        local text_color = can_afford and DOS.BLACK or DOS.LIGHT_GRAY
        
        -- Card name with level stars
        love.graphics.setColor(text_color)
        love.graphics.setFont(Fonts.medium)
        local level_stars = string.rep("*", shop_card.level)
        if shop_card.level > 0 then
            love.graphics.printf(level_stars .. " " .. shop_card.card.name .. " " .. level_stars, card_x + 5, card_y + 10, card_width - 10, "center")
        else
            love.graphics.printf(shop_card.card.name, card_x + 5, card_y + 10, card_width - 10, "center")
        end
        
        -- Rarity (moved up before gem)
        love.graphics.setColor(text_color)
        love.graphics.setFont(Fonts.small)
        love.graphics.printf(rarity.name, card_x + 5, card_y + 32, card_width - 10, "center")
        
        -- Upgrade indicator
        if is_upgrade then
            love.graphics.setColor(text_color)
            love.graphics.setFont(Fonts.small)
            love.graphics.printf("Upgrade to Lv." .. shop_card.target_level, card_x + 5, card_y + 48, card_width - 10, "center")
        end
        
        -- Draw gem image if available (larger and positioned in middle)
        if Images and Images.gems and shop_card.card.gem then
            local gem = Images.gems[shop_card.card.gem]
            if gem then
                local gem_scale = 5  -- Larger scale for better visibility
                local gem_x = card_x + (card_width / 2) - (gem:getWidth() * gem_scale / 2)
                local gem_y = card_y + 70
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(gem, gem_x, gem_y, 0, gem_scale, gem_scale)
            end
        end
        
        -- Description (moved down to avoid gem overlap)
        love.graphics.setColor(text_color)
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf(shop_card.card.description, card_x + 10, card_y + 120, card_width - 20, "center")
        
        -- Effect preview (moved down further)
        local effect = shop_card.card.effect(shop_card.level, self.game_data)
        local effect_text = self:formatEffect(effect, shop_card.level)
        love.graphics.setColor(text_color)
        love.graphics.setFont(Fonts.smallMed)
        love.graphics.printf(effect_text, card_x + 10, card_y + 150, card_width - 20, "center")
        
        -- Cost display (red for unaffordable, black for affordable)
        love.graphics.setColor(can_afford and DOS.BLACK or DOS.BRIGHT_RED)
        love.graphics.setFont(Fonts.large)
        love.graphics.printf(cost, card_x + 5, card_y + card_height - 30, card_width - 10, "center")
        
        -- Selection prompt
        if self.hovered_index == i then
            love.graphics.setColor(text_color)
            love.graphics.setFont(Fonts.small)
            if can_afford then
                love.graphics.printf("Click to Buy", card_x + 5, card_y + card_height - 12, card_width - 10, "center")
            else
                love.graphics.printf("Can't Afford", card_x + 5, card_y + card_height - 12, card_width - 10, "center")
            end
        end
        end -- End of "if not shop_card.maxed_out"
    end
    
    -- Draw coin upgrade in the 4th slot
    local current_tier = CoinUpgrades.getTier(self.game_data.coin_tier)
    local next_tier = CoinUpgrades.getNextTier(self.game_data.coin_tier)
    if next_tier then
        -- Position coin in the 4th slot
        local coin_slot_x = start_x + 3 * (card_width + card_spacing)
        local coin_slot_y = start_y
        local can_afford_coin = self.game_data.souls >= next_tier.cost
        
        -- Track if hovering over coin slot
        local mx, my = love.mouse.getPosition()
        local hovering_coin = mx >= coin_slot_x and mx <= coin_slot_x + card_width and
                              my >= coin_slot_y and my <= coin_slot_y + card_height
        
        if hovering_coin then
            coin_slot_y = coin_slot_y - 10  -- Hover effect like cards
        end
        
        -- Special layout for coin upgrade (no card background, text around coin)
        -- No border - the price box will convey affordability
        
        -- Draw coin name at very top
        love.graphics.setColor(can_afford_coin and DOS.WHITE or DOS.LIGHT_GRAY)
        love.graphics.setFont(Fonts.large)
        love.graphics.printf(next_tier.name, coin_slot_x + 5, coin_slot_y + 8, card_width - 10, "center")
        
        -- Draw the actual next tier coin in center
        local coin_center_x = coin_slot_x + card_width / 2
        local coin_center_y = coin_slot_y + 35 + 80  -- 35 = space from top, 80 = radius
        local coin_radius = 80  -- Match the gameplay coin size
        
        -- Create a temporary coin entity for display
        local Coin = require("entities.coin")
        local display_coin = Coin.new(coin_center_x, coin_center_y, coin_radius, next_tier.base_value, 
                                      next_tier.coin_image, next_tier.is_silver)
        
        -- Draw the coin with current owned cards (to show gems)
        display_coin:draw(self.game_data.owned_cards)
        
        -- Info text below coin
        local info_y = coin_slot_y + 35 + 160 + 5  -- Below coin
        
        -- Show slot unlock info
        if next_tier.max_card_slots > current_tier.max_card_slots then
            love.graphics.setColor(can_afford_coin and DOS.BRIGHT_GREEN or DOS.LIGHT_GRAY)
            love.graphics.setFont(Fonts.small)
            love.graphics.printf("+" .. (next_tier.max_card_slots - current_tier.max_card_slots) .. " Card Slot", coin_slot_x + 5, info_y, card_width - 10, "center")
            info_y = info_y + 14
        end
        
        -- Show base value info
        love.graphics.setColor(can_afford_coin and DOS.BRIGHT_CYAN or DOS.LIGHT_GRAY)
        love.graphics.setFont(Fonts.small)
        love.graphics.printf(next_tier.base_value * 100 .. " per flip", coin_slot_x + 5, info_y, card_width - 10, "center")
        
        -- Cost at the bottom with red box background
        local price_box_height = 26
        local price_box_y = coin_slot_y + card_height - price_box_height - 12
        local price_bg_color = can_afford_coin and DOS.GREEN or DOS.RED
        
        -- Draw price background box
        love.graphics.setColor(price_bg_color)
        love.graphics.rectangle("fill", coin_slot_x + 10, price_box_y, card_width - 20, price_box_height)
        
        -- Draw price text in black
        love.graphics.setColor(DOS.BLACK)
        love.graphics.setFont(Fonts.xlarge)
        love.graphics.printf(next_tier.cost, coin_slot_x + 5, price_box_y + 2, card_width - 10, "center")
        
        -- Selection prompt
        if hovering_coin then
            love.graphics.setColor(can_afford_coin and DOS.WHITE or DOS.LIGHT_GRAY)
            love.graphics.setFont(Fonts.tiny)
            if can_afford_coin then
                love.graphics.printf("[CLICK TO UPGRADE]", coin_slot_x + 5, coin_slot_y + card_height - 10, card_width - 10, "center")
            else
                love.graphics.printf("[CAN'T AFFORD]", coin_slot_x + 5, coin_slot_y + card_height - 10, card_width - 10, "center")
            end
        end
    end
    
    love.graphics.setColor(DOS.WHITE)
end

function Shop:formatEffect(effect, level)
    if effect.type == "heads_value" then
        return string.format("+%d%% Heads Value", math.floor((effect.multiplier - 1) * 100))
    elseif effect.type == "tails_value" then
        return string.format("Tails: %d", math.floor(effect.value * 100))
    elseif effect.type == "universal_multiplier" then
        return string.format("+%d%% All Flips", math.floor((effect.multiplier - 1) * 100))
    elseif effect.type == "tails_limit" then
        return string.format("Need %d tails to lose", effect.limit)
    elseif effect.type == "ignore_tails" then
        return string.format("Ignore %d tails", effect.count)
    elseif effect.type == "meter_speed" then
        return string.format("%d%% Meter Speed", math.floor(effect.multiplier * 100))
    elseif effect.type == "edge_multiplier" then
        return string.format("+%.1fx Edge", effect.increase)
    elseif effect.type == "heads_zone_size" then
        return string.format("+%d%% Larger Heads", math.floor((effect.multiplier - 1) * 100))
    elseif effect.type == "edge_zone_size" then
        return string.format("+%d%% Larger Edge", math.floor((effect.multiplier - 1) * 100))
    elseif effect.type == "extra_heads_zones" then
        return string.format("+%d Extra Heads Zone%s", effect.count, effect.count > 1 and "s" or "")
    elseif effect.type == "shop_discount" then
        return string.format("-%d%% Shop Costs", math.floor(effect.discount * 100))
    end
    return "Effect"
end

function Shop:mousemoved(x, y)
    -- Check hover on cards at bottom
    local w, h = love.graphics.getDimensions()
    local card_width = 160
    local card_height = 200
    local card_spacing = 20
    local total_slots = 4  -- 3 cards + 1 coin = 4 slots
    local total_width = (total_slots * card_width) + ((total_slots - 1) * card_spacing)
    local start_x = (w - total_width) / 2
    local start_y = h - card_height - 100
    
    self.hovered_index = nil
    
    for i, shop_card in ipairs(self.shop_cards) do
        -- Skip maxed out cards
        if not shop_card.maxed_out then
            local card_x = start_x + (i - 1) * (card_width + card_spacing)
            local card_y = start_y
            
            if x >= card_x and x <= card_x + card_width and 
               y >= card_y and y <= card_y + card_height then
                self.hovered_index = i
                break
            end
        end
    end
end

function Shop:mousepressed(x, y, button)
    local w, h = love.graphics.getDimensions()
    
    -- Check right-click on owned cards to sell (dynamic wrapped layout based on coin tier)
    if button == 2 then
        local current_tier = CoinUpgrades.getTier(self.game_data.coin_tier)
        local max_card_slots = current_tier.max_card_slots
        local owned_card_width = 230
        local owned_card_height = 70
        local owned_spacing = 10
        local owned_y = 105  -- 70 + 35 (title offset)
        local cards_per_row = 3
        
        for i = 1, max_card_slots do
            local row = math.floor((i - 1) / cards_per_row)
            local col = (i - 1) % cards_per_row
            local cards_in_this_row = math.min(cards_per_row, max_card_slots - row * cards_per_row)
            
            -- Calculate position for this card
            local row_width = cards_in_this_row * owned_card_width + (cards_in_this_row - 1) * owned_spacing
            local row_start_x = (w - row_width) / 2
            local owned_card_x = row_start_x + col * (owned_card_width + owned_spacing)
            local owned_card_y = owned_y + row * (owned_card_height + owned_spacing)
            local owned = self.game_data.owned_cards[i]
            
            if owned and x >= owned_card_x and x <= owned_card_x + owned_card_width and
               y >= owned_card_y and y <= owned_card_y + owned_card_height then
                self:sellCard(i)
                return
            end
        end
        return
    end
    
    if button ~= 1 then return end
    
    -- Check close button (X) in header (upper right)
    local close_button_size = 40
    local close_button_x = w - close_button_size - 10
    local close_button_y = 10
    
    if x >= close_button_x and x <= close_button_x + close_button_size and
       y >= close_button_y and y <= close_button_y + close_button_size then
        self:closeShop()
        return
    end
    
    -- Check card and coin selection at bottom
    local card_width = 160
    local card_height = 200
    local card_spacing = 20
    local total_slots = 4  -- 3 cards + 1 coin
    local total_width = (total_slots * card_width) + ((total_slots - 1) * card_spacing)
    local start_x = (w - total_width) / 2
    local start_y = h - card_height - 100
    
    -- Check coin upgrade button (4th slot)
    local next_tier = CoinUpgrades.getNextTier(self.game_data.coin_tier)
    if next_tier then
        local coin_slot_x = start_x + 3 * (card_width + card_spacing)
        local coin_slot_y = start_y
        
        if x >= coin_slot_x and x <= coin_slot_x + card_width and 
           y >= coin_slot_y and y <= coin_slot_y + card_height then
            self:upgradeCoin()
            return
        end
    end
    
    for i, shop_card in ipairs(self.shop_cards) do
        -- Skip maxed out cards
        if not shop_card.maxed_out then
            local card_x = start_x + (i - 1) * (card_width + card_spacing)
            local card_y = start_y
            
            if x >= card_x and x <= card_x + card_width and 
               y >= card_y and y <= card_y + card_height then
                self:selectCard(shop_card)
                return
            end
        end
    end
end

function Shop:keypressed(key)
    if key == "escape" then
        self:closeShop()
    end
end

function Shop:selectCard(shop_card)
    -- Check if player can afford the card (with discount from Haggler card)
    local base_cost = Cards.getCardCost(shop_card.card, shop_card.target_level)
    local card_effects = Cards.applyEffects(self.game_data.owned_cards, self.game_data)
    local discount = card_effects.shop_discount
    local cost = math.floor(base_cost * (1 - discount))
    if self.game_data.souls < cost then
        return -- Can't afford, do nothing
    end
    
    -- Deduct cost
    self.game_data.souls = self.game_data.souls - cost
    
    -- Add or level up card
    local found = false
    for _, owned in ipairs(self.game_data.owned_cards) do
        if owned.id == shop_card.card.id then
            owned.level = owned.level + 1
            found = true
            break
        end
    end
    
    if not found then
        -- Check if player has room (based on coin tier)
        local current_tier = CoinUpgrades.getTier(self.game_data.coin_tier)
        local max_slots = current_tier.max_card_slots
        
        if #self.game_data.owned_cards < max_slots then
            table.insert(self.game_data.owned_cards, {
                id = shop_card.card.id,
                level = 1
            })
        else
            -- Refund if no room
            self.game_data.souls = self.game_data.souls + cost
            return
        end
    end
    
    -- Update the shop card to show the next level (if available)
    local current_owned_level = 0
    for _, owned in ipairs(self.game_data.owned_cards) do
        if owned.id == shop_card.card.id then
            current_owned_level = owned.level
            break
        end
    end
    
    -- Check if card can be upgraded further
    if current_owned_level >= shop_card.card.max_level then
        -- Card is maxed out - remove it from shop display
        shop_card.maxed_out = true
    else
        -- Update to show next level
        shop_card.target_level = current_owned_level + 1
        shop_card.level = 1 -- Still display as level 1 (base appearance)
    end
    
    -- Stay in shop - don't automatically exit
end

function Shop:sellCard(slot_index)
    local owned = self.game_data.owned_cards[slot_index]
    if not owned then
        return -- No card in this slot
    end
    
    local card_def = Cards.getCard(owned.id)
    if not card_def then
        return
    end
    
    -- Calculate sell price (50% of card's current level cost)
    local sell_price = math.floor(Cards.getCardCost(card_def, owned.level) * 0.5)
    
    -- Give souls back
    self.game_data.souls = self.game_data.souls + sell_price
    
    -- Remove card from owned cards
    table.remove(self.game_data.owned_cards, slot_index)
    
    -- Update shop cards to include this card again (if it was maxed out)
    for _, shop_card in ipairs(self.shop_cards) do
        if shop_card.card.id == owned.id and shop_card.maxed_out then
            shop_card.maxed_out = false
            shop_card.target_level = 1
            shop_card.level = 1
        end
    end
end

function Shop:closeShop()
    -- Return to game
    local Gamestate = require("utils.gamestate")
    Gamestate.switch(self.previous_state, self.game_data)
end

function Shop:upgradeCoin()
    local next_tier = CoinUpgrades.getNextTier(self.game_data.coin_tier)
    if not next_tier then
        return -- Already at max tier
    end
    
    if self.game_data.souls < next_tier.cost then
        return -- Can't afford
    end
    
    -- Deduct cost and upgrade
    self.game_data.souls = self.game_data.souls - next_tier.cost
    self.game_data.coin_tier = next_tier.id
    
    -- Play upgrade coin sound
    Sounds.upgradeCoin:stop()
    Sounds.upgradeCoin:play()
    
    -- Stay in shop - don't automatically exit
end

return Shop

