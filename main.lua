local fxn = require( 'fxn' )
-- local dbg = require( 'debugger' )

local func = nil

function love.run()
  math.randomseed( os.time() )

  if love.load then love.load( arg ) end
  if love.timer then love.timer.step() end

  local isrunning = true
  local framestart, frameend, frameleft = 0, 0, 0
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
    if love.update then love.update( fxn.global.fdt + math.max(-frameleft, 0) ) end
    if love.window and love.graphics and love.window.isCreated() then
      -- TODO(JRC): Change to clear color back to black after testing is complete.
      love.graphics.clear( unpack(fxn.colors.white) )
      love.draw()
      love.graphics.present()
    end
    frameend = love.timer and love.timer.getTime() or 0

    if love.timer then
      frameleft = fxn.global.fdt - ( frameend - framestart )
      if frameleft > 0 then love.timer.sleep( frameleft ) end
      love.timer.step()
    end
  end
end

function love.load()
  func = fxn.func_t( function(x) return math.sin(x) end )
end

function love.keypressed( key, scancode, isrepeat )
  if key == 'q' then love.event.quit() end
end

function love.update( dt )
  
end

function love.draw()
  love.graphics.push()

  do -- transform from device coordinates to window coordinates
    love.graphics.scale( love.graphics.getDimensions() )
    love.graphics.translate( 0.0, 1.0 )
    love.graphics.scale( 1.0, -1.0 )
  end

  do -- plot example function
    love.graphics.setColor( unpack(fxn.colors.black) )
    love.graphics.setLineWidth( 0.01 )

    love.graphics.translate( 0.0, 0.5 )
    love.graphics.line( 0.01, 0.0, 0.99, 0.0 )
  end

  love.graphics.pop()
end
