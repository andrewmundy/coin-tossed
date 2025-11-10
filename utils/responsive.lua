-- Responsive layout system
-- Provides adaptive layouts for different screen sizes

local Responsive = {}

-- Screen size breakpoints
Responsive.MOBILE_MAX_WIDTH = 768
Responsive.MOBILE_MAX_HEIGHT = 1024

-- Layout modes
Responsive.LAYOUT_MOBILE = "mobile"
Responsive.LAYOUT_DESKTOP = "desktop"

-- Cache for mobile detection
local _isMobileDevice = nil

-- Detect current layout mode
function Responsive.getLayoutMode()
    local w, h = love.graphics.getDimensions()
    
    -- Check command line args for mobile flag (set by web build)
    if _isMobileDevice == nil then
        _isMobileDevice = false
        local args = arg or {}
        for i, v in ipairs(args) do
            if v == "--mobile" then
                _isMobileDevice = true
                break
            end
        end
    end
    
    -- If mobile flag is set (from web build), use mobile layout
    if _isMobileDevice then
        return Responsive.LAYOUT_MOBILE
    end
    
    -- Native builds: check dimensions
    -- Mobile: narrow screens or portrait orientation  
    if w <= Responsive.MOBILE_MAX_WIDTH or (w < h and w <= 600) then
        return Responsive.LAYOUT_MOBILE
    end
    
    return Responsive.LAYOUT_DESKTOP
end

-- Check if current layout is mobile
function Responsive.isMobile()
    return Responsive.getLayoutMode() == Responsive.LAYOUT_MOBILE
end

-- Get responsive layout values for Playing state
function Responsive.getPlayingLayout()
    local w, h = love.graphics.getDimensions()
    local isMobile = Responsive.isMobile()
    
    local layout = {}
    
    if isMobile then
        -- Mobile layout: stack everything vertically, full width
        local padding = 10
        local boxWidth = w - (padding * 2)
        local boxHeight = 40
        local currentY = padding
        
        -- Top stats (souls, tails, flips) - stacked vertically
        layout.souls = {x = padding, y = currentY, width = boxWidth, height = boxHeight}
        currentY = currentY + boxHeight + padding
        
        layout.tails = {x = padding, y = currentY, width = boxWidth, height = boxHeight}
        currentY = currentY + boxHeight + padding
        
        layout.flips = {x = padding, y = currentY, width = boxWidth, height = boxHeight}
        currentY = currentY + boxHeight + padding
        
        -- Multipliers - side by side but smaller
        local multWidth = (boxWidth - padding) / 2
        layout.coinMult = {x = padding, y = currentY, width = multWidth, height = 50}
        layout.streakMult = {x = padding + multWidth + padding, y = currentY, width = multWidth, height = 50}
        layout.multSeparator = {x = padding + multWidth + (padding / 2), y = currentY + 15}
        currentY = currentY + 50 + padding
        
        -- Coin - centered, larger
        local coinRadius = math.min(100, w * 0.2)
        layout.coin = {x = w / 2, y = h / 2, radius = coinRadius}
        
        -- Power meter - bottom, full width with padding
        local meterHeight = 30
        local meterY = h - meterHeight - padding - 40  -- Leave room for hints
        layout.powerMeter = {x = padding, y = meterY, width = boxWidth, height = meterHeight}
        
        -- Cards - hide in mobile or show as compact overlay
        layout.showCards = false  -- Hide by default in mobile
        
        -- Hints - bottom right, smaller
        layout.hints = {x = w - 85, y = h - 45}
        
        -- Warning message
        layout.warning = {y = meterY - 30}
        
        -- Result popup - centered
        layout.result = {x = w / 2 - 150, y = h / 2 - 100, width = 300, height = 80}
        
        -- Font scale
        layout.fontScale = 0.9  -- Slightly smaller fonts on mobile
        
    else
        -- Desktop layout: current layout
        layout.souls = {x = 20, y = 20, width = 200, height = 45}
        layout.tails = {x = 20, y = 75, width = 200, height = 45}
        layout.flips = {x = 20, y = 130, width = 200, height = 45}
        
        layout.coinMult = {x = 20, y = 185, width = 92, height = 60}
        layout.streakMult = {x = 128, y = 185, width = 92, height = 60}
        layout.multSeparator = {x = 112, y = 200}
        
        layout.coin = {x = w / 2, y = h / 2 - 30, radius = 80}
        
        layout.powerMeter = {x = w / 2 - 200, y = h - 120, width = 400, height = 40}
        
        layout.showCards = true
        layout.cardsX = w - 180
        layout.cardsCompactX = w - 160
        layout.cardsY = 20
        
        layout.hints = {x = w - 80, y = h - 40}
        
        layout.warning = {y = h - 100}
        
        layout.result = {x = w / 2 - 150, y = h / 2 - 80, width = 300, height = 80}
        
        layout.fontScale = 1.0
    end
    
    return layout
end

-- Get responsive layout values for Shop state
function Responsive.getShopLayout()
    local w, h = love.graphics.getDimensions()
    local isMobile = Responsive.isMobile()
    
    local layout = {}
    
    if isMobile then
        -- Mobile shop layout
        local padding = 10
        
        layout.headerHeight = 50
        layout.footerHeight = 0  -- No footer in mobile
        
        layout.closeButton = {x = w - 45, y = 10, width = 35, height = 35}
        layout.money = {x = 10, y = 10, width = w - 70, height = 35}
        
        -- Scrollable card grid
        layout.cardsPerRow = 2  -- 2 columns on mobile
        layout.cardWidth = (w - (padding * 3)) / 2
        layout.cardHeight = layout.cardWidth * 1.4
        layout.cardPadding = padding
        layout.cardsStartY = layout.headerHeight + padding
        
        -- Coin upgrade - top of scrollable area or as a banner
        layout.coinUpgrade = {
            x = padding,
            y = layout.cardsStartY,
            width = w - (padding * 2),
            height = 120
        }
        
        layout.scrollable = true
        
    else
        -- Desktop shop layout (current)
        layout.headerHeight = 50
        layout.footerHeight = 60
        
        layout.closeButton = {x = w - 45, y = 10, width = 35, height = 35}
        layout.money = {x = w / 2 - 100, y = 15, width = 200, height = 30}
        
        layout.cardsPerRow = 3
        layout.cardWidth = 180
        layout.cardHeight = 240
        layout.cardPadding = 20
        layout.cardsStartY = 180
        
        layout.coinUpgrade = {
            x = w / 2 - 200,
            y = 80,
            width = 400,
            height = 240
        }
        
        layout.scrollable = false
    end
    
    return layout
end

return Responsive

