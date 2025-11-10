function love.conf(t)
    t.identity = "flipper"
    t.version = "11.4"
    t.console = false
    
    t.window.title = "Flipper - Coin Flip Roguelike"
    t.window.icon = nil
    t.window.width = 800
    t.window.height = 600
    t.window.borderless = false
    t.window.resizable = true
    t.window.minwidth = 400
    t.window.minheight = 300
    t.window.fullscreen = false
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.highdpi = true  -- Enable high DPI support for better mobile display
    
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = false
    t.modules.timer = true
    t.modules.touch = true  -- Enable touch for mobile support
    t.modules.video = false
    t.modules.window = true
end

