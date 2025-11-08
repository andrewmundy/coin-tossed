-- Flipper - Coin Flip Roguelike
-- Main game file

local Gamestate = require("utils.gamestate")
local Playing = require("states.playing")

-- Global fonts table
Fonts = {}

-- Global sounds table
Sounds = {}

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
    
    -- Set up graphics
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("smooth")
    
    -- Seed random number generator
    love.math.setRandomSeed(os.time())
    
    -- Start with playing state
    Gamestate.switch(Playing)
end

function love.update(dt)
    Gamestate.update(dt)
end

function love.draw()
    Gamestate.draw()
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
    -- Handle window resize if needed
end
