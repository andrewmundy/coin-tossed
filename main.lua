-- Flipper - Coin Flip Roguelike
-- Main game file

local Gamestate = require("utils.gamestate")
local Playing = require("states.playing")

function love.load()
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

function love.resize(w, h)
    -- Handle window resize if needed
end
