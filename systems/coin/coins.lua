-- Coin upgrade system
local Config = require("config")
local CoinUpgrades = {}

-- Coin tiers with their properties
CoinUpgrades.TIERS = {
    {
        id = "level_1",
        name = "Level 1 Coin",
        base_value = 1,
        max_card_slots = 2,
        coin_image = "coin1",
        is_silver = true,
        cost = 0 -- Starting tier
    },
    {
        id = "level_2",
        name = "Level 2 Coin",
        base_value = 2,
        max_card_slots = 2,
        coin_image = "coin1",
        is_silver = false,
        cost = Config.COIN_UPGRADE_COSTS.level_1_to_2
    },
    {
        id = "level_3",
        name = "Level 3 Coin",
        base_value = 3,
        max_card_slots = 3,
        coin_image = "coin2",
        is_silver = true,
        cost = Config.COIN_UPGRADE_COSTS.level_2_to_3
    },
    {
        id = "level_4",
        name = "Level 4 Coin",
        base_value = 5,
        max_card_slots = 4,
        coin_image = "coin2",
        is_silver = false,
        cost = Config.COIN_UPGRADE_COSTS.level_3_to_4
    },
    {
        id = "level_5",
        name = "Level 5 Coin",
        base_value = 8,
        max_card_slots = 5,
        coin_image = "coin2",
        is_silver = false,
        cost = Config.COIN_UPGRADE_COSTS.level_4_to_5
    }
}

-- Get tier by ID
function CoinUpgrades.getTier(tier_id)
    for _, tier in ipairs(CoinUpgrades.TIERS) do
        if tier.id == tier_id then
            return tier
        end
    end
    return CoinUpgrades.TIERS[1] -- Default to level 1
end

-- Get next tier
function CoinUpgrades.getNextTier(current_tier_id)
    for i, tier in ipairs(CoinUpgrades.TIERS) do
        if tier.id == current_tier_id and i < #CoinUpgrades.TIERS then
            return CoinUpgrades.TIERS[i + 1]
        end
    end
    return nil -- Already at max tier
end

-- Check if can upgrade
function CoinUpgrades.canUpgrade(current_tier_id, souls)
    local next_tier = CoinUpgrades.getNextTier(current_tier_id)
    if not next_tier then
        return false, "Max tier reached"
    end
    if souls < next_tier.cost then
        return false, "Not enough souls"
    end
    return true, next_tier
end

return CoinUpgrades

