-- Game Over state
local GameOver = {}

GameOver.final_souls = 0
GameOver.final_flips = 0
GameOver.flip_history = {}

function GameOver:enter()
    -- Calculate stats
    self.heads_count = 0
    self.tails_count = 0
    self.edge_count = 0
    
    for _, result in ipairs(self.flip_history) do
        if result == "heads" then
            self.heads_count = self.heads_count + 1
        elseif result == "tails" then
            self.tails_count = self.tails_count + 1
        elseif result == "edge" then
            self.edge_count = self.edge_count + 1
        end
    end
end

function GameOver:update(dt)
    -- Nothing to update
end

function GameOver:draw()
    local w, h = love.graphics.getDimensions()
    
    -- DOS black background
    love.graphics.setColor(DOS.BLACK)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Helper function for DOS-style boxes (no shadows, no rounded corners)
    local function drawBox(x, y, width, height, bg_color, border_color)
        -- Background
        love.graphics.setColor(bg_color)
        love.graphics.rectangle("fill", x, y, width, height)
        -- Border
        love.graphics.setColor(border_color or DOS.LIGHT_GRAY)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", x, y, width, height)
    end
    
    -- Top header bar
    drawBox(0, 0, w, 60, DOS.RED, DOS.RED)
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.title)
    love.graphics.printf("GAME OVER", 0, 15, w, "center")
    
    -- Reason box
    drawBox(w/2 - 200, 80, 400, 40, DOS.DARK_GRAY, DOS.RED)
    love.graphics.setColor(DOS.BRIGHT_RED)
    love.graphics.setFont(Fonts.large)
    love.graphics.printf("3 Consecutive Tails!", w/2 - 200, 90, 400, "center")
    
    -- Final score section
    drawBox(w/2 - 250, 140, 500, 180, DOS.BLUE, DOS.BRIGHT_CYAN)
    
    love.graphics.setColor(DOS.WHITE)
    love.graphics.setFont(Fonts.large)
    love.graphics.printf("FINAL SCORE", w/2 - 250, 155, 500, "center")
    
    love.graphics.setFont(Fonts.title)
    love.graphics.setColor(DOS.BRIGHT_GREEN)
    love.graphics.printf(math.floor(self.final_souls), w/2 - 250, 185, 500, "center")
    
    love.graphics.setColor(DOS.BRIGHT_CYAN)
    love.graphics.setFont(Fonts.large)
    love.graphics.printf("SOULS", w/2 - 250, 220, 500, "center")
    
    love.graphics.setColor(DOS.LIGHT_GRAY)
    love.graphics.setFont(Fonts.medium)
    love.graphics.printf("Total Flips: " .. self.final_flips, w/2 - 250, 255, 500, "center")
    
    -- Statistics breakdown
    local stats_y = 340
    local stats_width = 300
    local stats_x = w/2 - stats_width/2
    local row_height = 30
    
    -- Heads
    drawBox(stats_x, stats_y, stats_width, row_height, DOS.DARK_GRAY, DOS.BRIGHT_GREEN)
    love.graphics.setColor(DOS.BRIGHT_GREEN)
    love.graphics.setFont(Fonts.large)
    love.graphics.printf("HEADS: " .. self.heads_count, stats_x + 10, stats_y + 5, stats_width - 20, "left")
    
    -- Tails
    drawBox(stats_x, stats_y + row_height + 5, stats_width, row_height, DOS.DARK_GRAY, DOS.BRIGHT_RED)
    love.graphics.setColor(DOS.BRIGHT_RED)
    love.graphics.printf("TAILS: " .. self.tails_count, stats_x + 10, stats_y + row_height + 10, stats_width - 20, "left")
    
    -- Edges (if any)
    if self.edge_count > 0 then
        drawBox(stats_x, stats_y + (row_height + 5) * 2, stats_width, row_height, DOS.DARK_GRAY, DOS.YELLOW)
        love.graphics.setColor(DOS.YELLOW)
        love.graphics.printf("EDGES: " .. self.edge_count, stats_x + 10, stats_y + (row_height + 5) * 2 + 5, stats_width - 20, "left")
    end
    
    -- Restart button
    local button_y = h - 100
    drawBox(w/2 - 250, button_y, 500, 50, DOS.GREEN, DOS.GREEN)
    love.graphics.setColor(DOS.BLACK)
    love.graphics.setFont(Fonts.xlarge)
    love.graphics.printf("PRESS SPACE TO PLAY AGAIN", w/2 - 250, button_y + 12, 500, "center")
    
    -- ESC instructions
    love.graphics.setColor(DOS.DARK_GRAY)
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf("ESC to quit", 0, h - 25, w, "center")
    
    love.graphics.setColor(DOS.WHITE)
end

function GameOver:keypressed(key)
    if key == "space" or key == "return" then
        self:restart()
    elseif key == "escape" then
        love.event.quit()
    end
end

function GameOver:mousepressed(x, y, button)
    if button == 1 then
        self:restart()
    end
end

function GameOver:restart()
    local Gamestate = require("utils.gamestate")
    local Playing = require("states.playing")
    Gamestate.switch(Playing)
end

return GameOver

