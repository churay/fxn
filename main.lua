-- TODO(JRC): Eliminate this path inclusion somehow.
package.path = package.path .. ";fxn/?.lua"
local fxn = require( "fxn" )

-- package.path = package.path .. ";debug/?.lua"
-- ldb = require( "debug.debugger" )

function love.run()
  math.randomseed( os.time() )

  if love.load then love.load( arg ) end
  if love.timer then love.timer.step() end

  local timedelta = 0
  local isrunning = true
  while isrunning do
    if love.event then
      love.event.pump()
      for levent, a, b, c, d in love.event.poll() do
        if levent == "quit" then
          isrunning = false
        end

        love.handlers[levent]( a, b, c, d )
      end
    end

    if love.timer then
      love.timer.step()
      timedelta = love.timer.getDelta()
    end

    if love.getinput then love.getinput() end
    if love.update then love.update( timedelta ) end
    if love.window and love.graphics and love.window.isCreated() then
      love.graphics.clear( 0, 0, 0 )
      love.draw()
      love.graphics.present()
    end

    if love.timer then love.timer.sleep( 1.0e-3 ) end
  end
end

function love.load()
  
end

function love.keypressed( key, scancode, isrepeat )
  if key == "q" then love.event.quit() end
end

function love.update( timedelta )
  
end

function love.draw()
  love.graphics.print( "Hello World", 400, 300 )
end
