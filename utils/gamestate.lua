-- Simple game state manager
local Gamestate = {}

Gamestate.current = nil
Gamestate.states = {}

function Gamestate.switch(state)
    if Gamestate.current and Gamestate.current.exit then
        Gamestate.current:exit()
    end
    
    Gamestate.current = state
    
    if Gamestate.current.enter then
        Gamestate.current:enter()
    end
end

function Gamestate.register(name, state)
    Gamestate.states[name] = state
end

function Gamestate.update(dt)
    if Gamestate.current and Gamestate.current.update then
        Gamestate.current:update(dt)
    end
end

function Gamestate.draw()
    if Gamestate.current and Gamestate.current.draw then
        Gamestate.current:draw()
    end
end

function Gamestate.mousepressed(x, y, button)
    if Gamestate.current and Gamestate.current.mousepressed then
        Gamestate.current:mousepressed(x, y, button)
    end
end

function Gamestate.keypressed(key)
    if Gamestate.current and Gamestate.current.keypressed then
        Gamestate.current:keypressed(key)
    end
end

return Gamestate

