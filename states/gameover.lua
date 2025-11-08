-- Game Over state
local GameOver = {}

GameOver.final_money = 0
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
    
    -- Background with pattern
    love.graphics.setColor(0.08, 0.08, 0.1)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Draw subtle diagonal pattern
    love.graphics.setColor(0.12, 0.1, 0.12, 0.3)
    for i = -h, w, 40 do
        love.graphics.line(i, 0, i + h, h)
    end
    
    -- Helper function to draw a box with chunky shadow
    local function drawBox(x, y, width, height, bg_color, border_color)
        -- Layered shadows for depth (chunky pixel style)
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", x + 10, y + 10, width, height, 6, 6)
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", x + 6, y + 6, width, height, 6, 6)
        
        -- Background
        love.graphics.setColor(bg_color)
        love.graphics.rectangle("fill", x, y, width, height, 6, 6)
        
        -- Border (thick and chunky)
        love.graphics.setColor(border_color or {0.3, 0.3, 0.35})
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x, y, width, height, 6, 6)
    end
    
    -- Game Over title box
    drawBox(w/2 - 250, 60, 500, 70, {0.25, 0.1, 0.1}, {1, 0.2, 0.2})
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.setFont(Fonts.title)
    love.graphics.printf("GAME OVER", w/2 - 250, 75, 500, "center")
    
    -- Subtitle box
    drawBox(w/2 - 200, 145, 400, 40, {0.15, 0.12, 0.12}, {0.6, 0.3, 0.3})
    love.graphics.setColor(1, 0.8, 0.8)
    love.graphics.setFont(Fonts.large)
    love.graphics.printf("3 Consecutive Tails!", w/2 - 200, 155, 400, "center")
    
    -- Final score box
    drawBox(w/2 - 220, 210, 440, 200, {0.12, 0.15, 0.12}, {0.3, 0.6, 0.3})
    
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setFont(Fonts.large)
    love.graphics.printf("FINAL SCORE", 0, 225, w, "center")
    
    love.graphics.setFont(Fonts.title)
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.printf("$" .. self.final_money, 0, 255, w, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(Fonts.medium)
    love.graphics.printf("Total Flips: " .. self.final_flips, 0, 320, w, "center")
    
    -- Breakdown with colored boxes
    local breakdown_y = 350
    love.graphics.setFont(Fonts.medium)
    
    love.graphics.setColor(0.1, 0.3, 0.1)
    love.graphics.rectangle("fill", w/2 - 80, breakdown_y, 160, 20, 2, 2)
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.printf("Heads: " .. self.heads_count, w/2 - 70, breakdown_y + 3, 140, "left")
    
    love.graphics.setColor(0.3, 0.1, 0.1)
    love.graphics.rectangle("fill", w/2 - 80, breakdown_y + 25, 160, 20, 2, 2)
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.printf("Tails: " .. self.tails_count, w/2 - 70, breakdown_y + 28, 140, "left")
    
    if self.edge_count > 0 then
        love.graphics.setColor(0.3, 0.25, 0.1)
        love.graphics.rectangle("fill", w/2 - 80, breakdown_y + 50, 160, 20, 2, 2)
        love.graphics.setColor(1, 0.84, 0)
        love.graphics.printf("Edges: " .. self.edge_count, w/2 - 70, breakdown_y + 53, 140, "left")
    end
    
    -- Restart button box
    drawBox(w/2 - 200, h - 110, 400, 50, {0.15, 0.2, 0.15}, {0.3, 0.8, 0.3})
    love.graphics.setColor(0.5, 1, 0.5)
    love.graphics.setFont(Fonts.xlarge)
    love.graphics.printf("Press SPACE to Play Again", w/2 - 200, h - 95, 400, "center")
    
    -- ESC instructions
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf("ESC to quit", 0, h - 25, w, "center")
    
    love.graphics.setColor(1, 1, 1)
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

