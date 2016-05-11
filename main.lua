package.path = package.path .. ";fxn/?.lua;etc/?.lua"

local fxn = require( "fxn" )
-- local dbg = require( "debugger" )

function love.run()
  math.randomseed( os.time() )

  if love.load then love.load( arg ) end
  if love.timer then love.timer.step() end

  local dt = 0
  local isrunning = true
  while isrunning do
    if love.event then
      love.event.pump()
      for levent, a, b, c, d in love.event.poll() do
        if levent == "quit" then isrunning = false end
        love.handlers[levent]( a, b, c, d )
      end
    end

    if love.timer then
      love.timer.step()
      dt = love.timer.getDelta()
    end

    if love.getinput then love.getinput() end
    if love.update then love.update( dt ) end
    if love.window and love.graphics and love.window.isCreated() then
      love.graphics.clear( 0, 0, 0 )
      love.draw()
      love.graphics.present()
    end

    if love.timer then love.timer.sleep( 1.0e-3 ) end
  end
end

function love.load()
  print(fxn)
  print(dbg)
end

function love.keypressed( key, scancode, isrepeat )
  if key == "q" then love.event.quit() end
end

function love.update( dt )
  
end

function love.draw()
  love.graphics.print( "Hello World", 400, 300 )
end
