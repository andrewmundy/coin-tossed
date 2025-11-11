-- Card system for upgrade cards
local Cards = {}

-- Rarity definitions
Cards.RARITY = {
    COMMON = { name = "Common", color = { 0.7, 0.7, 0.7 }, weight = 60 },
    UNCOMMON = { name = "Uncommon", color = { 0.3, 0.8, 0.3 }, weight = 30 },
    RARE = { name = "Rare", color = { 0.4, 0.6, 1.0 }, weight = 8 },
    LEGENDARY = { name = "Legendary", color = { 1.0, 0.84, 0.0 }, weight = 2 }
}

-- Card catalog
Cards.CATALOG = {
    -- Value Manipulation Cards
    {
        id = "golden_flip",
        name = "Golden Flip",
        description = "Heads worth more",
        rarity = Cards.RARITY.COMMON,
        max_level = 3,
        gem = "topaz",
        effect = function(level, game_state)
            return {
                type = "heads_value",
                multiplier = 1 + (level * 0.10) -- +10% per level
            }
        end
    },
    {
        id = "momentum",
        name = "Momentum",
        description = "Consecutive heads increase value",
        rarity = Cards.RARITY.COMMON,
        max_level = 3,
        gem = "garnet",
        effect = function(level, game_state)
            -- Count consecutive heads
            local consecutive = 0
            for i = #game_state.flip_history, 1, -1 do
                if game_state.flip_history[i] == "heads" then
                    consecutive = consecutive + 1
                else
                    break
                end
            end
            return {
                type = "heads_value",
                multiplier = 1 + (consecutive * 0.05 * level) -- +5% per consecutive head per level
            }
        end
    },
    {
        id = "silver_lining",
        name = "Silver Lining",
        description = "Tails earn money",
        rarity = Cards.RARITY.UNCOMMON,
        max_level = 3,
        gem = "moonstone",
        effect = function(level, game_state)
            return {
                type = "tails_value",
                value = level * 0.10 -- $0.10 per level
            }
        end
    },
    {
        id = "midas_touch",
        name = "Midas Touch",
        description = "All flips worth more",
        rarity = Cards.RARITY.RARE,
        max_level = 3,
        gem = "ruby",
        effect = function(level, game_state)
            return {
                type = "universal_multiplier",
                multiplier = 1 + (level * 0.08) -- +8% per level
            }
        end
    },

    -- Probability Engineering Cards
    {
        id = "weighted_coin",
        name = "Weighted Coin",
        description = "Larger heads zones",
        rarity = Cards.RARITY.COMMON,
        max_level = 3,
        gem = "jade",
        effect = function(level, game_state)
            return {
                type = "heads_zone_size",
                multiplier = 1 + (level * 0.08) -- +8% larger heads zones per level
            }
        end
    },
    {
        id = "lucky_strike",
        name = "Lucky Strike",
        description = "Adds extra small heads zone",
        rarity = Cards.RARITY.UNCOMMON,
        max_level = 3,
        gem = "aquamarine",
        effect = function(level, game_state)
            return {
                type = "extra_heads_zones",
                count = level -- Add 1, 2, or 3 extra small heads zones
            }
        end
    },
    {
        id = "edge_master",
        name = "Edge Lord",
        description = "Larger edge zones",
        rarity = Cards.RARITY.UNCOMMON,
        max_level = 3,
        gem = "lapis",
        effect = function(level, game_state)
            return {
                type = "edge_zone_size",
                multiplier = 1 + (level * 0.10) -- +10% larger edge zones per level
            }
        end
    },

    -- Safety Net Cards
    {
        id = "nine_lives",
        name = "Nine Lives",
        description = "Need 5 tails to lose!",
        rarity = Cards.RARITY.LEGENDARY,
        max_level = 1,
        gem = "moonstone",
        effect = function(level, game_state)
            return {
                type = "tails_limit",
                limit = 5 -- Fixed at 5 consecutive tails
            }
        end
    },
    {
        id = "tails_insurance",
        name = "Tails Insurance",
        description = "First N tails don't count",
        rarity = Cards.RARITY.UNCOMMON,
        max_level = 3,
        gem = "jade",
        effect = function(level, game_state)
            return {
                type = "ignore_tails",
                count = level -- Ignore 1, 2, or 3 tails
            }
        end
    },

    -- Power Meter Cards
    {
        id = "steady_hands",
        name = "Steady Hands",
        description = "Slower power meter",
        rarity = Cards.RARITY.COMMON,
        max_level = 3,
        gem = "aquamarine",
        effect = function(level, game_state)
            return {
                type = "meter_speed",
                multiplier = 1 - (level * 0.05) -- -5% speed per level
            }
        end
    },
    {
        id = "sharpshooter",
        name = "Sharpshooter",
        description = "Larger edge zones",
        rarity = Cards.RARITY.UNCOMMON,
        max_level = 3,
        gem = "garnet",
        effect = function(level, game_state)
            return {
                type = "edge_multiplier",
                increase = level * 0.2 -- +0.2x per level
            }
        end
    },

    -- Economic Cards
    {
        id = "haggler",
        name = "Haggler",
        description = "Shop cards cost less",
        rarity = Cards.RARITY.COMMON,
        max_level = 3,
        gem = "topaz",
        effect = function(level, game_state)
            return {
                type = "shop_discount",
                discount = level * 0.10 -- 10%/20%/30% discount per level
            }
        end
    }
}

-- Get a card definition by ID
function Cards.getCard(id)
    for _, card in ipairs(Cards.CATALOG) do
        if card.id == id then
            return card
        end
    end
    return nil
end

-- Calculate the cost of a card based on rarity and level
function Cards.getCardCost(card, level)
    -- Level 1: 500-1500 souls, Level 2: 5000 souls, Level 3: 10000+ souls
    local base_costs = {
        [Cards.RARITY.COMMON] = 500,
        [Cards.RARITY.UNCOMMON] = 700,
        [Cards.RARITY.RARE] = 1000,
        [Cards.RARITY.LEGENDARY] = 1500
    }

    local base_cost = base_costs[card.rarity] or 500

    -- Cost progression: Level 1 = base (500-1500 souls), Level 2 = 5000 souls, Level 3 = 10000+ souls
    if level == 1 then
        return base_cost
    elseif level == 2 then
        return 5000
    elseif level == 3 then
        -- Scale thousands based on rarity
        local level3_costs = {
            [Cards.RARITY.COMMON] = 10000,
            [Cards.RARITY.UNCOMMON] = 15000,
            [Cards.RARITY.RARE] = 20000,
            [Cards.RARITY.LEGENDARY] = 30000
        }
        return level3_costs[card.rarity] or 10000
    end

    return base_cost
end

-- Generate random cards for shop (5 cards based on rarity weights)
function Cards.generateShopCards(num_cards, exclude_ids)
    exclude_ids = exclude_ids or {}
    local shop_cards = {}
    local available_cards = {}

    -- Build available cards pool (excluding already owned at max level)
    for _, card in ipairs(Cards.CATALOG) do
        local should_exclude = false
        for _, exclude_id in ipairs(exclude_ids) do
            if card.id == exclude_id then
                should_exclude = true
                break
            end
        end
        if not should_exclude then
            table.insert(available_cards, card)
        end
    end

    -- Generate cards based on rarity weights
    for i = 1, num_cards do
        if #available_cards == 0 then break end

        -- Calculate total weight
        local total_weight = 0
        for _, card in ipairs(available_cards) do
            total_weight = total_weight + card.rarity.weight
        end

        -- Random selection
        local roll = love.math.random() * total_weight
        local cumulative = 0

        for idx, card in ipairs(available_cards) do
            cumulative = cumulative + card.rarity.weight
            if roll <= cumulative then
                table.insert(shop_cards, {
                    card = card,
                    level = 1 -- Will be updated based on owned cards
                })
                table.remove(available_cards, idx)
                break
            end
        end
    end

    return shop_cards
end

-- Apply all active card effects to calculate final multipliers
function Cards.applyEffects(owned_cards, game_state)
    local effects = {
        heads_value_multiplier = 1.0,
        tails_value = 0,
        universal_multiplier = 1.0,
        tails_limit = 3,
        ignored_tails = 0,
        meter_speed_multiplier = 1.0,
        edge_multiplier_bonus = 0,
        heads_zone_size_multiplier = 1.0,
        edge_zone_size_multiplier = 1.0,
        extra_heads_zones = 0,
        shop_discount = 0
    }

    -- Apply each owned card's effect
    for _, owned_card in ipairs(owned_cards) do
        local card_def = Cards.getCard(owned_card.id)
        if card_def then
            local effect = card_def.effect(owned_card.level, game_state)

            if effect.type == "heads_value" then
                effects.heads_value_multiplier = effects.heads_value_multiplier * effect.multiplier
            elseif effect.type == "tails_value" then
                effects.tails_value = effects.tails_value + effect.value
            elseif effect.type == "universal_multiplier" then
                effects.universal_multiplier = effects.universal_multiplier * effect.multiplier
            elseif effect.type == "tails_limit" then
                effects.tails_limit = math.max(effects.tails_limit, effect.limit)
            elseif effect.type == "ignore_tails" then
                effects.ignored_tails = effects.ignored_tails + effect.count
            elseif effect.type == "meter_speed" then
                effects.meter_speed_multiplier = effects.meter_speed_multiplier * effect.multiplier
            elseif effect.type == "edge_multiplier" then
                effects.edge_multiplier_bonus = effects.edge_multiplier_bonus + effect.increase
            elseif effect.type == "heads_zone_size" then
                effects.heads_zone_size_multiplier = effects.heads_zone_size_multiplier * effect.multiplier
            elseif effect.type == "edge_zone_size" then
                effects.edge_zone_size_multiplier = effects.edge_zone_size_multiplier * effect.multiplier
            elseif effect.type == "extra_heads_zones" then
                effects.extra_heads_zones = effects.extra_heads_zones + effect.count
            elseif effect.type == "shop_discount" then
                effects.shop_discount = effects.shop_discount + effect.discount
            end
        end
    end

    return effects
end

return Cards
