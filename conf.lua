function love.conf( config )
  config.identity = "fxn"
  config.version = "0.10.1"
  config.console = false

  config.window.title = "fxn"
  config.window.icon = nil
  config.window.borderless = false
  config.window.resizable = false
  config.window.width = 640
  config.window.height = 480
  config.window.vsync = true

  config.modules.audio = false
  config.modules.event = true
  config.modules.graphics = true
  config.modules.math = true
  config.modules.physics = false
  config.modules.sound = false
  config.modules.system = true
  config.modules.timer = true
  config.modules.window = true
  config.modules.thread = false
end
