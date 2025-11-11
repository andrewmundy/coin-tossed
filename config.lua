-- Game Configuration
-- Centralized balance values for easy tweaking

local Config = {}

-- ============================================================================
-- COIN UPGRADE COSTS (in souls)
-- ============================================================================
Config.COIN_UPGRADE_COSTS = {
    level_1_to_2 = 5000,  -- Level 1 -> Level 2
    level_2_to_3 = 12000, -- Level 2 -> Level 3 (reduced from 20000)
    level_3_to_4 = 60000, -- Level 3 -> Level 4
    level_4_to_5 = 200000 -- Level 4 -> Level 5
}

-- ============================================================================
-- POWER METER SETTINGS
-- ============================================================================
Config.POWER_METER = {
    base_speed = 2.1,              -- Base cycles per second (reduced from 2.3)
    return_speed_multiplier = 4.0, -- Return speed multiplier (5x faster)

    -- Zone positions and sizes (positions are 0.0-1.0, sizes are percentage points 0-100)
    -- Arrays allow multiple zones of each type
    -- Heads zones can have levels (1-3) with multipliers:
    --   Level 1: 1.0x multiplier (default if not specified)
    --   Level 2: 1.25x multiplier
    --   Level 3: 1.5x multiplier
    heads = {
        {
            position = 0.15,
            size = 10, -- Size in percentage points
            level = 2
        },
        {
            position = 0.6,
            size = 25,
            level = 1
        },
    },
    edge = {
        {
            position = 0.05, -- Position along the meter (58%)
            size = 2         -- Size in percentage points (XXS size)
        }
        -- Add more edge zones here as needed:
        -- { position = 0.8, size = 1.5 },
    }
}

-- ============================================================================
-- CARD COSTS (optional - can be added here if needed)
-- ============================================================================
-- Config.CARD_COSTS = {
--     level_1 = { common = 500, uncommon = 700, rare = 1000, legendary = 1500 },
--     level_2 = 5000,
--     level_3 = { common = 10000, uncommon = 15000, rare = 20000, legendary = 30000 }
-- }

return Config
