-- Playing state - main gameplay
local Coin = require("entities.coin")
local PowerMeter = require("entities.powermeter")

local Playing = {}

function Playing:enter()
    -- Game state
    self.money = 0
    self.flips = 0
    self.consecutive_tails = 0
    self.base_value = 10
    self.flip_history = {}
    
    -- Create coin
    local w, h = love.graphics.getDimensions()
    self.coin = Coin.new(w / 2, h / 2 - 30)
    
    -- Create power meter
    self.power_meter = PowerMeter.new(w / 2 - 200, h - 120, 400, 40)
    
    -- Last flip result
    self.last_result = nil
    self.last_zone = nil
    self.last_earned = 0
    self.result_timer = 0
    self.result_display_time = 2.0
end

function Playing:update(dt)
    self.coin:update(dt)
    
    -- Only update power meter when not flipping
    if not self.coin.is_flipping then
        self.power_meter:update(dt)
    end
    
    -- Update result display timer
    if self.result_timer > 0 then
        self.result_timer = self.result_timer - dt
    end
    
    -- Check if flip animation finished and we need to show result
    if not self.coin.is_flipping and self.coin.result then
        self:processFlipResult(self.coin.result)
        self.coin.result = nil
    end
end

function Playing:draw()
    local w, h = love.graphics.getDimensions()
    
    -- Background with pattern
    love.graphics.setColor(0.08, 0.12, 0.1)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Draw subtle diagonal pattern
    love.graphics.setColor(0.1, 0.15, 0.12, 0.3)
    for i = -h, w, 40 do
        love.graphics.line(i, 0, i + h, h)
    end
    
    -- Helper function to draw a box with chunky shadow
    local function drawBox(x, y, width, height, bg_color, border_color)
        -- Layered shadows for depth (chunky pixel style)
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", x + 10, y + 10, width, height, 6, 6)
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", x + 6, y + 6, width, height, 6, 6)
        
        -- Background
        love.graphics.setColor(bg_color)
        love.graphics.rectangle("fill", x, y, width, height, 6, 6)
        
        -- Border (thick and chunky)
        love.graphics.setColor(border_color or {0.3, 0.3, 0.35})
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x, y, width, height, 6, 6)
    end
    
    -- Money display box (labels on right side)
    drawBox(20, 20, 200, 45, {0.12, 0.2, 0.15}, {0.2, 0.8, 0.3})
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.printf("$" .. self.money, 30, 30, 80, "left")
    love.graphics.setColor(0.7, 0.9, 0.7)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf("MONEY", 120, 35, 90, "left")
    
    -- Tails counter box with warning (labels on right side)
    local tails_bg = {0.2, 0.15, 0.15}
    local tails_border = {0.5, 0.3, 0.3}
    local tails_color = {1, 0.8, 0.8}
    
    if self.consecutive_tails >= 2 then
        tails_bg = {0.3, 0.1, 0.1}
        tails_border = {1, 0.2, 0.2}
        tails_color = {1, 0.3, 0.3}
    elseif self.consecutive_tails >= 1 then
        tails_bg = {0.3, 0.2, 0.1}
        tails_border = {1, 0.6, 0.2}
        tails_color = {1, 0.8, 0.3}
    end
    
    drawBox(20, 75, 200, 45, tails_bg, tails_border)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(tails_color)
    love.graphics.printf(self.consecutive_tails .. "/3", 30, 85, 80, "left")
    love.graphics.setColor(tails_color[1] * 0.7, tails_color[2] * 0.7, tails_color[3] * 0.7)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf("TAILS", 120, 90, 90, "left")
    
    -- Flips counter box (moved below, labels on right side)
    drawBox(20, 130, 200, 45, {0.15, 0.15, 0.25}, {0.5, 0.5, 0.7})
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(0.7, 0.7, 1)
    love.graphics.printf(self.flips, 30, 140, 80, "left")
    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf("FLIPS", 120, 145, 90, "left")
    
    if self.consecutive_tails >= 2 then
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.printf("⚠️ WARNING: One more tails and you lose!", 
            0, h - 100, w, "center")
    end
    
    -- Draw coin
    self.coin:draw()
    
    -- Draw power meter
    self.power_meter:draw()
    
    -- Display last result in a nice box
    if self.result_timer > 0 and self.last_result then
        local alpha = math.min(1, self.result_timer / 0.5)
        local result_text = ""
        local result_bg = {0.2, 0.2, 0.2}
        local result_border = {0.5, 0.5, 0.5}
        local result_color = {1, 1, 1}
        
        if self.last_result == "heads" then
            result_text = "HEADS! +$" .. self.last_earned
            result_bg = {0.1, 0.3, 0.1}
            result_border = {0.2, 1, 0.2}
            result_color = {0.3, 1, 0.3}
        elseif self.last_result == "tails" then
            result_text = "TAILS!"
            result_bg = {0.3, 0.1, 0.1}
            result_border = {1, 0.2, 0.2}
            result_color = {1, 0.3, 0.3}
        elseif self.last_result == "edge" then
            result_text = "EDGE LANDING!!! +$" .. self.last_earned
            result_bg = {0.3, 0.25, 0.1}
            result_border = {1, 0.84, 0}
            result_color = {1, 0.9, 0.3}
        end
        
        -- Draw result box with chunky shadow
        local box_y = h / 2 + 100
        love.graphics.setColor(0, 0, 0, 0.3 * alpha)
        love.graphics.rectangle("fill", w/2 - 190, box_y + 10, 400, 50, 6, 6)
        love.graphics.setColor(0, 0, 0, 0.5 * alpha)
        love.graphics.rectangle("fill", w/2 - 194, box_y + 6, 400, 50, 6, 6)
        
        love.graphics.setColor(result_bg[1], result_bg[2], result_bg[3], alpha)
        love.graphics.rectangle("fill", w/2 - 200, box_y, 400, 50, 6, 6)
        
        love.graphics.setColor(result_border[1], result_border[2], result_border[3], alpha)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", w/2 - 200, box_y, 400, 50, 6, 6)
        
        love.graphics.setColor(result_color[1], result_color[2], result_color[3], alpha)
        love.graphics.setFont(love.graphics.newFont(28))
        love.graphics.printf(result_text, w/2 - 200, box_y + 12, 400, "center")
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Playing:mousepressed(x, y, button)
    if button == 1 and self.coin:isHovered(x, y) then
        -- Get the zone first, then pass it to flip
        local zone = self.power_meter:hit()
        if self.coin:flip(zone) then
            self:doFlip(zone)
        end
    end
end

function Playing:keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" and not self.coin.is_flipping then
        -- Get the zone first, then pass it to flip
        local zone = self.power_meter:hit()
        if self.coin:flip(zone) then
            self:doFlip(zone)
        end
    end
end

function Playing:doFlip(zone)
    -- Use the zone passed in (already hit from mousepressed/keypressed)
    self.last_zone = zone
    
    -- Zone now directly determines the result - pure skill!
    local result = zone.result
    
    self.coin.result = result
    self.coin.zone = zone
    self.flips = self.flips + 1
    table.insert(self.flip_history, result)
end

function Playing:processFlipResult(result)
    self.last_result = result
    self.result_timer = self.result_display_time
    
    -- Get the zone multiplier from the coin (stored during flip)
    local multiplier = self.coin.zone and self.coin.zone.multiplier or 1.0
    
    if result == "heads" then
        local earned = math.floor(self.base_value * multiplier)
        self.money = self.money + earned
        self.last_earned = earned
        self.consecutive_tails = 0
    elseif result == "tails" then
        self.last_earned = 0
        self.consecutive_tails = self.consecutive_tails + 1
        
        -- Check for loss condition
        if self.consecutive_tails >= 3 then
            self:gameOver()
        end
    elseif result == "edge" then
        local earned = math.floor(self.base_value * 100 * multiplier)
        self.money = self.money + earned
        self.last_earned = earned
        self.consecutive_tails = 0
    end
end

function Playing:gameOver()
    local Gamestate = require("utils.gamestate")
    local GameOver = require("states.gameover")
    
    GameOver.final_money = self.money
    GameOver.final_flips = self.flips
    GameOver.flip_history = self.flip_history
    
    Gamestate.switch(GameOver)
end

return Playing

