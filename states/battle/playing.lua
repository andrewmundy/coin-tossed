-- Playing state - Battle Mode
-- TODO: Implement battle mode gameplay

local Playing = {}

function Playing:enter(previous_state, game_data)
    -- Store game mode
    self.game_mode = game_data and game_data.game_mode or "battle"
    
    -- Initialize battle mode game state
    -- TODO: Add battle-specific initialization
    self.health = 100
    self.max_health = 100
    self.stamina = 100
    self.max_stamina = 100
    
    -- Placeholder: For now, just show a message
    self.message = "BATTLE MODE - Coming Soon!"
    self.message_timer = 0
end

function Playing:update(dt)
    self.message_timer = self.message_timer + dt
end

function Playing:draw()
    local w, h = love.graphics.getDimensions()
    
    -- Draw background
    love.graphics.setColor(DOS.BLACK)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Draw placeholder message
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.title)
    love.graphics.printf(self.message, 0, h / 2 - 50, w, "center")
    
    love.graphics.setColor(DOS.LIGHT_GRAY)
    love.graphics.setFont(Fonts.large)
    love.graphics.printf("Press ESC to open settings", 0, h / 2 + 50, w, "center")
end

function Playing:keypressed(key)
    if key == "escape" then
        self:openSettings()
    end
end

function Playing:openSettings()
    local Gamestate = require("utils.gamestate")
    local Settings = require("states.shared.settings")
    
    -- Package game data to pass to settings
    local game_data = {
        game_mode = self.game_mode or "battle",
        health = self.health,
        max_health = self.max_health,
        stamina = self.stamina,
        max_stamina = self.max_stamina
    }
    
    Gamestate.switch(Settings, self, game_data)
end

function Playing:mousemoved(x, y)
    -- TODO: Handle mouse movement for battle mode
end

function Playing:mousepressed(x, y, button)
    -- TODO: Handle mouse clicks for battle mode
end

return Playing

