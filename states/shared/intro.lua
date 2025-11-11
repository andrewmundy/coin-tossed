-- Intro/Menu state - game mode selection
local Intro = {}

function Intro:enter()
    self.selected_mode = nil
    self.hovered_mode = nil
end

function Intro:update(dt)
    -- Nothing to update for now
end

function Intro:draw()
    local w, h = love.graphics.getDimensions()
    
    -- Draw background (will be replaced with image later)
    love.graphics.setColor(DOS.BLACK)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- TODO: Draw background image here when available
    -- if Images.introBackground then
    --     love.graphics.setColor(1, 1, 1, 1)
    --     love.graphics.draw(Images.introBackground, 0, 0, 0, w / Images.introBackground:getWidth(), h / Images.introBackground:getHeight())
    -- end
    
    -- Draw title "Stater"
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.title)
    local title_text = "STATER"
    local title_width = Fonts.title:getWidth(title_text)
    love.graphics.printf(title_text, 0, h * 0.2, w, "center")
    
    -- Draw game mode selection buttons
    local button_width = 300
    local button_height = 80
    local button_spacing = 30
    local total_height = (button_height * 2) + button_spacing
    local start_y = h * 0.5 - total_height / 2
    
    -- Coin Mode button
    local coin_button_x = (w - button_width) / 2
    local coin_button_y = start_y
    local coin_hovered = (self.hovered_mode == "coin")
    
    -- Button background
    local coin_bg_color = coin_hovered and DOS.BRIGHT_BLUE or DOS.DARK_GRAY
    love.graphics.setColor(coin_bg_color)
    love.graphics.rectangle("fill", coin_button_x, coin_button_y, button_width, button_height)
    
    -- Button border
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", coin_button_x, coin_button_y, button_width, button_height)
    
    -- Button text
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.xlarge)
    love.graphics.printf("COIN MODE", coin_button_x, coin_button_y + button_height / 2 - 15, button_width, "center")
    
    -- Battle Mode button
    local battle_button_x = (w - button_width) / 2
    local battle_button_y = start_y + button_height + button_spacing
    local battle_hovered = (self.hovered_mode == "battle")
    
    -- Button background
    local battle_bg_color = battle_hovered and DOS.BRIGHT_BLUE or DOS.DARK_GRAY
    love.graphics.setColor(battle_bg_color)
    love.graphics.rectangle("fill", battle_button_x, battle_button_y, button_width, button_height)
    
    -- Button border
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", battle_button_x, battle_button_y, button_width, button_height)
    
    -- Button text
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.xlarge)
    love.graphics.printf("BATTLE MODE", battle_button_x, battle_button_y + button_height / 2 - 15, button_width, "center")
    
    -- Instructions
    love.graphics.setColor(DOS.LIGHT_GRAY)
    love.graphics.setFont(Fonts.medium)
    love.graphics.printf("Select a game mode", 0, h * 0.85, w, "center")
    
    love.graphics.setColor(DOS.WHITE)
end

function Intro:mousemoved(x, y)
    local w, h = love.graphics.getDimensions()
    local button_width = 300
    local button_height = 80
    local button_spacing = 30
    local total_height = (button_height * 2) + button_spacing
    local start_y = h * 0.5 - total_height / 2
    
    local button_x = (w - button_width) / 2
    
    -- Check coin mode button
    local coin_button_y = start_y
    if x >= button_x and x <= button_x + button_width and
       y >= coin_button_y and y <= coin_button_y + button_height then
        self.hovered_mode = "coin"
        return
    end
    
    -- Check battle mode button
    local battle_button_y = start_y + button_height + button_spacing
    if x >= button_x and x <= button_x + button_width and
       y >= battle_button_y and y <= battle_button_y + button_height then
        self.hovered_mode = "battle"
        return
    end
    
    self.hovered_mode = nil
end

function Intro:mousepressed(x, y, button)
    if button == 1 then -- Left click
        if self.hovered_mode then
            self.selected_mode = self.hovered_mode
            self:startGame()
        end
    end
end

function Intro:keypressed(key)
    if key == "1" or key == "c" then
        self.selected_mode = "coin"
        self:startGame()
    elseif key == "2" or key == "b" then
        self.selected_mode = "battle"
        self:startGame()
    elseif key == "escape" then
        love.event.quit()
    end
end

function Intro:startGame()
    local Gamestate = require("utils.gamestate")
    
    -- Load the appropriate playing state based on selected mode
    if self.selected_mode == "coin" then
        local Playing = require("states.coin.playing")
        Gamestate.switch(Playing, nil, {game_mode = self.selected_mode})
    elseif self.selected_mode == "battle" then
        local Playing = require("states.battle.playing")
        Gamestate.switch(Playing, nil, {game_mode = self.selected_mode})
    end
end

return Intro

