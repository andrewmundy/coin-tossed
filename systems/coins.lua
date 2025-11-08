-- Coin upgrade system
local CoinUpgrades = {}

-- Coin tiers with their properties
CoinUpgrades.TIERS = {
    {
        id = "bronze",
        name = "Bronze Coin",
        base_value = 1,
        max_card_slots = 2,
        color = {0.8, 0.5, 0.3},
        cost = 0 -- Starting tier
    },
    {
        id = "silver",
        name = "Silver Coin",
        base_value = 2,
        max_card_slots = 3,
        color = {0.75, 0.75, 0.8},
        cost = 50
    },
    {
        id = "gold",
        name = "Gold Coin",
        base_value = 4,
        max_card_slots = 4,
        color = {1, 0.84, 0},
        cost = 300
    },
    {
        id = "platinum",
        name = "Platinum Coin",
        base_value = 8,
        max_card_slots = 5,
        color = {0.7, 0.9, 1},
        cost = 1500
    },
    {
        id = "diamond",
        name = "Diamond Coin",
        base_value = 16,
        max_card_slots = 6,
        color = {0.5, 1, 1},
        cost = 5000
    }
}

-- Get tier by ID
function CoinUpgrades.getTier(tier_id)
    for _, tier in ipairs(CoinUpgrades.TIERS) do
        if tier.id == tier_id then
            return tier
        end
    end
    return CoinUpgrades.TIERS[1] -- Default to bronze
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
function CoinUpgrades.canUpgrade(current_tier_id, money)
    local next_tier = CoinUpgrades.getNextTier(current_tier_id)
    if not next_tier then
        return false, "Max tier reached"
    end
    if money < next_tier.cost then
        return false, "Not enough money"
    end
    return true, next_tier
end

return CoinUpgrades

