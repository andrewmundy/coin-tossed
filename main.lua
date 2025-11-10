-- Flipper - Coin Flip Roguelike
-- Main game file

local Gamestate = require("utils.gamestate")
local Playing = require("states.playing")

-- Global fonts table
Fonts = {}

-- Global sounds table
Sounds = {}

-- Global images table
Images = {}

-- Global shaders table
Shaders = {}

-- Global time for shaders
ShaderTime = 0

-- Enable/disable CRT effect (set to false to disable)
UseCRTEffect = true  -- Enabled - using ultra-simple shader

-- CRT scanline intensity (0.0 = none, 0.05 = subtle, 0.1 = medium, 0.2 = strong)
CRTScanlineIntensity = 0.015  -- Adjust this value to make CRT more or less intense

-- DOS Color Palette (16 colors)
DOS = {
    BLACK = {0, 0, 0},
    BLUE = {0, 0, 0.667},
    GREEN = {0, 0.667, 0},
    CYAN = {0, 0.667, 0.667},
    RED = {0.667, 0, 0},
    MAGENTA = {0.667, 0, 0.667},
    BROWN = {0.667, 0.333, 0},
    LIGHT_GRAY = {0.667, 0.667, 0.667},
    DARK_GRAY = {0.333, 0.333, 0.333},
    BRIGHT_BLUE = {0.333, 0.333, 1},
    BRIGHT_GREEN = {0.333, 1, 0.333},
    BRIGHT_CYAN = {0.333, 1, 1},
    BRIGHT_RED = {1, 0.333, 0.333},
    BRIGHT_MAGENTA = {1, 0.333, 1},
    YELLOW = {1, 1, 0.333},
    WHITE = {1, 1, 1}
}

function love.load()
    -- Load custom font
    local font_path = "assets/fonts/MorePerfectDOSVGA.ttf"
    Fonts.tiny = love.graphics.newFont(font_path, 9)
    Fonts.small = love.graphics.newFont(font_path, 10)
    Fonts.smallMed = love.graphics.newFont(font_path, 11)
    Fonts.normal = love.graphics.newFont(font_path, 12)
    Fonts.medium = love.graphics.newFont(font_path, 14)
    Fonts.large = love.graphics.newFont(font_path, 16)
    Fonts.xlarge = love.graphics.newFont(font_path, 20)
    Fonts.xxlarge = love.graphics.newFont(font_path, 24)
    Fonts.huge = love.graphics.newFont(font_path, 28)
    Fonts.title = love.graphics.newFont(font_path, 40)
    
    -- Load sounds
    Sounds.coinFlip = love.audio.newSource("assets/sounds/coin-flip.WAV", "static")
    Sounds.heads = love.audio.newSource("assets/sounds/heads.WAV", "static")
    Sounds.tails = love.audio.newSource("assets/sounds/tails.WAV", "static")
    Sounds.gameLose = love.audio.newSource("assets/sounds/game-lose.WAV", "static")
    Sounds.upgradeCoin = love.audio.newSource("assets/sounds/upgrade-coin.WAV", "static")
    
    -- Set up graphics (must be before loading images)
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Load coin images
    Images.coin1 = love.graphics.newImage("assets/images/coin1.png")
    Images.coin1:setFilter("nearest", "nearest")
    Images.coin2 = love.graphics.newImage("assets/images/coin2.png")
    Images.coin2:setFilter("nearest", "nearest")
    
    -- Default coin (for backwards compatibility)
    Images.coin = Images.coin1
    
    -- Load gem images
    Images.gems = {
        aquamarine = love.graphics.newImage("assets/images/aquamarine.png"),
        garnet = love.graphics.newImage("assets/images/garnet.png"),
        jade = love.graphics.newImage("assets/images/jade.png"),
        lapis = love.graphics.newImage("assets/images/lapis.png"),
        moonstone = love.graphics.newImage("assets/images/moonstone.png"),
        ruby = love.graphics.newImage("assets/images/ruby.png"),
        topaz = love.graphics.newImage("assets/images/topaz.png")
    }
    
    -- Set filter for all gems
    for _, gem in pairs(Images.gems) do
        gem:setFilter("nearest", "nearest")
    end
    
    -- Define glow colors for each gem
    Images.gemColors = {
        aquamarine = {0.4, 0.9, 0.9},  -- Cyan/turquoise
        garnet = {0.8, 0.2, 0.2},      -- Red
        jade = {0.3, 0.8, 0.3},        -- Green
        lapis = {0.2, 0.4, 0.9},       -- Deep blue
        moonstone = {0.9, 0.9, 1.0},   -- White/silver
        ruby = {0.9, 0.1, 0.2},        -- Bright red
        topaz = {1.0, 0.8, 0.2}        -- Yellow/gold
    }
    love.graphics.setLineStyle("smooth")
    
    -- Load shaders with error handling
    local success, err = pcall(function()
        Shaders.background = love.graphics.newShader("assets/shaders/background.glsl")
    end)
    if not success then
        print("Background shader failed to load:", err)
    end
    
    success, err = pcall(function()
        Shaders.crt = love.graphics.newShader("assets/shaders/crt-simple.glsl")
    end)
    if not success then
        print("CRT shader failed to load:", err)
        Shaders.crt = nil
    end
    
    success, err = pcall(function()
        Shaders.silverCoin = love.graphics.newShader("assets/shaders/silver-coin.glsl")
    end)
    if not success then
        print("Silver coin shader failed to load:", err)
        Shaders.silverCoin = nil
    end
    
    success, err = pcall(function()
        Shaders.gemGlow = love.graphics.newShader("assets/shaders/gem-glow.glsl")
    end)
    if not success then
        print("Gem glow shader failed to load:", err)
        Shaders.gemGlow = nil
    end
    
    -- Create canvases (may fail in web version)
    local w, h = love.graphics.getDimensions()
    success, err = pcall(function()
        Shaders.backgroundCanvas = love.graphics.newCanvas(w, h)
        Shaders.gameCanvas = love.graphics.newCanvas(w, h)
    end)
    if not success then
        print("Canvas creation failed (this is okay for web version):", err)
        Shaders.backgroundCanvas = nil
        Shaders.gameCanvas = nil
    end
    
    -- Set initial shader parameters
    if Shaders.background then
        success, err = pcall(function()
            Shaders.background:send("resolution", {w, h})
            Shaders.background:send("time", 0)
            -- Set default values for background shader uniforms (required for WebGL)
            Shaders.background:send("spin_rotation_speed", 0.2)
            Shaders.background:send("move_speed", 0.2)
            Shaders.background:send("offset", {0.0, 0.0})
            Shaders.background:send("colour_1", {0.02, 0.02, 0.02, 1.0})  -- Almost pure black
            Shaders.background:send("colour_2", {0.05, 0.08, 0.15, 1.0})  -- Dark blue accent
            Shaders.background:send("colour_3", {0.05, 0.05, 0.05, 1.0})  -- Very dark gray
            Shaders.background:send("contrast", 3.5)
            Shaders.background:send("lighting", 0.05)
            Shaders.background:send("spin_amount", 0.25)
            Shaders.background:send("pixel_filter", 200.0)
            Shaders.background:send("is_rotating", true)
        end)
        if not success then
            print("Background shader parameter setup failed:", err)
        end
    end
    
    -- Set CRT shader parameters
    if Shaders.crt then
        success, err = pcall(function()
            Shaders.crt:send("scanline_intensity", CRTScanlineIntensity)
        end)
        if not success then
            print("CRT shader parameter setup failed:", err)
        end
    end
    
    -- Seed random number generator
    love.math.setRandomSeed(os.time())
    
    -- Start with playing state
    Gamestate.switch(Playing)
end

function love.update(dt)
    -- Update shader time
    ShaderTime = ShaderTime + dt
    if Shaders.background then
        local success, err = pcall(function()
            Shaders.background:send("time", ShaderTime)
        end)
        if not success then
            print("Failed to update background shader time:", err)
        end
    end
    -- Simple CRT shader doesn't need time updates
    
    Gamestate.update(dt)
end

function love.draw()
    -- Render game to canvas and apply CRT effect if enabled
    if UseCRTEffect and Shaders.gameCanvas and Shaders.crt then
        love.graphics.setCanvas(Shaders.gameCanvas)
        love.graphics.clear()
        Gamestate.draw()
        love.graphics.setCanvas()
        
        -- Apply CRT shader and draw to screen
        love.graphics.setShader(Shaders.crt)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Shaders.gameCanvas, 0, 0)
        love.graphics.setShader()
    else
        -- Draw directly without CRT effect
        Gamestate.draw()
    end
end

function love.mousepressed(x, y, button)
    Gamestate.mousepressed(x, y, button)
end

function love.keypressed(key)
    Gamestate.keypressed(key)
end

function love.mousemoved(x, y, dx, dy)
    Gamestate.mousemoved(x, y, dx, dy)
end

function love.resize(w, h)
    -- Recreate canvases for new window size (may fail in web version)
    if Shaders.backgroundCanvas then
        local success, result = pcall(function()
            return love.graphics.newCanvas(w, h)
        end)
        if success then
            Shaders.backgroundCanvas = result
        else
            print("Failed to recreate background canvas:", result)
        end
    end
    if Shaders.gameCanvas then
        local success, result = pcall(function()
            return love.graphics.newCanvas(w, h)
        end)
        if success then
            Shaders.gameCanvas = result
        else
            print("Failed to recreate game canvas:", result)
        end
    end
    
    -- Update shader resolutions
    if Shaders.background then
        local success, err = pcall(function()
            Shaders.background:send("resolution", {w, h})
        end)
        if not success then
            print("Failed to update background shader resolution:", err)
        end
    end
    if Shaders.crt then
        local success, err = pcall(function()
            Shaders.crt:send("resolution", {w, h})
        end)
        if not success then
            print("Failed to update CRT shader resolution:", err)
        end
    end
end
