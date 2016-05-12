package.path = package.path .. ';fxn/?.lua;opt/?.lua'

local fxn = require( 'fxn' )
-- local dbg = require( 'debugger' )

function love.run()
  math.randomseed( os.time() )

  if love.load then love.load( arg ) end
  if love.timer then love.timer.step() end

  local isrunning = true
  local framestart, frameend, frameleftover = 0, 0, 0
  while isrunning do
    if love.event then
      love.event.pump()
      for levent, a, b, c, d in love.event.poll() do
        if levent == 'quit' then isrunning = false end
        love.handlers[levent]( a, b, c, d )
      end
    end

    framestart = love.timer and love.timer.getTime() or 0
    if love.getinput then love.getinput() end
    if love.update then love.update( fxn.global.fdt + math.max(-frameleftover, 0) ) end
    if love.window and love.graphics and love.window.isCreated() then
      love.graphics.clear( 0, 0, 0 )
      love.draw()
      love.graphics.present()
    end
    frameend = love.timer and love.timer.getTime() or 0

    if love.timer then
      frameleftover = fxn.global.fdt - ( frameend - framestart )
      if frameleftover > 0 then love.timer.sleep( frameleftover ) end
      love.timer.step()
    end
  end
end

function love.load()
  fxn.global = {}

  fxn.global.fps = 60.0
  fxn.global.fdt = 1.0 / fxn.global.fps
end

function love.keypressed( key, scancode, isrepeat )
  if key == 'q' then love.event.quit() end
end

function love.update( dt )
  
end

function love.draw()
  love.graphics.clear( 255, 255, 255 )
end
