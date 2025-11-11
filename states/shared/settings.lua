-- Settings/Pause menu state
local Settings = {}

function Settings:enter(previous_state, game_data)
    self.previous_state = previous_state  -- The playing state
    self.game_data = game_data  -- Game data to preserve if resuming
    self.selected_option = nil
    self.hovered_option = nil
end

function Settings:update(dt)
    -- Pause menu doesn't need updates
end

function Settings:draw()
    local w, h = love.graphics.getDimensions()
    
    -- Draw semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Helper function for DOS-style boxes
    local function drawBox(x, y, width, height, bg_color, border_color)
        love.graphics.setColor(bg_color)
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(border_color or DOS.LIGHT_GRAY)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", x, y, width, height)
    end
    
    -- Settings menu box
    local menu_width = 400
    local menu_height = 300
    local menu_x = (w - menu_width) / 2
    local menu_y = (h - menu_height) / 2
    
    drawBox(menu_x, menu_y, menu_width, menu_height, DOS.BLUE, DOS.BRIGHT_CYAN)
    
    -- Title
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.title)
    love.graphics.printf("SETTINGS", menu_x, menu_y + 20, menu_width, "center")
    
    -- Menu options
    local option_height = 50
    local option_spacing = 15
    local start_y = menu_y + 100
    local option_width = menu_width - 40
    local option_x = menu_x + 20
    
    -- Resume option
    local resume_y = start_y
    local resume_hovered = (self.hovered_option == "resume")
    local resume_bg = resume_hovered and DOS.BRIGHT_BLUE or DOS.DARK_GRAY
    drawBox(option_x, resume_y, option_width, option_height, resume_bg, DOS.WHITE)
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.xlarge)
    love.graphics.printf("RESUME", option_x, resume_y + 12, option_width, "center")
    
    -- Return to Main Menu option
    local menu_y_pos = start_y + option_height + option_spacing
    local menu_hovered = (self.hovered_option == "main_menu")
    local menu_bg = menu_hovered and DOS.BRIGHT_BLUE or DOS.DARK_GRAY
    drawBox(option_x, menu_y_pos, option_width, option_height, menu_bg, DOS.WHITE)
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.xlarge)
    love.graphics.printf("MAIN MENU", option_x, menu_y_pos + 12, option_width, "center")
    
    -- Quit option
    local quit_y = menu_y_pos + option_height + option_spacing
    local quit_hovered = (self.hovered_option == "quit")
    local quit_bg = quit_hovered and DOS.RED or DOS.DARK_GRAY
    drawBox(option_x, quit_y, option_width, option_height, quit_bg, DOS.WHITE)
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.xlarge)
    love.graphics.printf("QUIT", option_x, quit_y + 12, option_width, "center")
    
    -- Instructions
    love.graphics.setColor(DOS.LIGHT_GRAY)
    love.graphics.setFont(Fonts.small)
    love.graphics.printf("ESC to resume", menu_x, menu_y + menu_height - 30, menu_width, "center")
    
    love.graphics.setColor(DOS.WHITE)
end

function Settings:mousemoved(x, y)
    local w, h = love.graphics.getDimensions()
    local menu_width = 400
    local menu_height = 300
    local menu_x = (w - menu_width) / 2
    local menu_y = (h - menu_height) / 2
    
    local option_height = 50
    local option_spacing = 15
    local start_y = menu_y + 100
    local option_width = menu_width - 40
    local option_x = menu_x + 20
    
    -- Check resume option
    local resume_y = start_y
    if x >= option_x and x <= option_x + option_width and
       y >= resume_y and y <= resume_y + option_height then
        self.hovered_option = "resume"
        return
    end
    
    -- Check main menu option
    local menu_y_pos = start_y + option_height + option_spacing
    if x >= option_x and x <= option_x + option_width and
       y >= menu_y_pos and y <= menu_y_pos + option_height then
        self.hovered_option = "main_menu"
        return
    end
    
    -- Check quit option
    local quit_y = menu_y_pos + option_height + option_spacing
    if x >= option_x and x <= option_x + option_width and
       y >= quit_y and y <= quit_y + option_height then
        self.hovered_option = "quit"
        return
    end
    
    self.hovered_option = nil
end

function Settings:mousepressed(x, y, button)
    if button == 1 and self.hovered_option then
        self.selected_option = self.hovered_option
        self:handleSelection()
    end
end

function Settings:keypressed(key)
    if key == "escape" then
        -- Resume game
        self:resume()
    elseif key == "r" then
        -- Resume with R key
        self:resume()
    elseif key == "m" then
        -- Main menu with M key
        self:goToMainMenu()
    elseif key == "q" then
        -- Quit with Q key
        self:quit()
    end
end

function Settings:handleSelection()
    if self.selected_option == "resume" then
        self:resume()
    elseif self.selected_option == "main_menu" then
        self:goToMainMenu()
    elseif self.selected_option == "quit" then
        self:quit()
    end
end

function Settings:resume()
    local Gamestate = require("utils.gamestate")
    -- Return to previous state (playing) with preserved game data
    Gamestate.switch(self.previous_state, nil, self.game_data)
end

function Settings:goToMainMenu()
    local Gamestate = require("utils.gamestate")
    local Intro = require("states.shared.intro")
    -- Return to intro screen
    Gamestate.switch(Intro)
end

function Settings:quit()
    love.event.quit()
end

return Settings

