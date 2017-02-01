local fxn = require( 'fxn' )
love.ext = require( 'opt.loveext' )

local state = {
  func = 0,
  board = 0,
}

local input = {
  mouse = { x=0, y=0 },
  mousexy = function( s ) return s.mouse.x, s.mouse.y end,
}

local meta = {
  framenum = 1,
  avgfps = 0,
  showstats = true,
}

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
      love.graphics.clear( fxn.colors.tuple('white') )
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
  state.func = fxn.func_t( function(x) return math.sin(x) end )
  state.board = fxn.board_t( 10, 10 )
  state.renderable = fxn.renderable_t( {}, 1.0 )
end

function love.keypressed( key, scancode, isrepeat )
  if key == 'd' then meta.showstats = not meta.showstats end
  if key == 'q' then love.event.quit() end
end

function love.update( dt )
  input.mouse.x, input.mouse.y = love.mouse.getPosition()

  meta.framenum = meta.framenum + 1
  meta.avgfps = 1 / dt
end

function love.draw()
  love.graphics.push()

  do -- transform from device coordinates to window coordinates
    love.graphics.scale( love.graphics.getDimensions() )
    love.graphics.translate( 0.0, 1.0 )
    love.graphics.scale( 1.0, -1.0 )
  end

  --[[
  local mousex, mousey = love.graphics.itransform( input:mousexy() )
  love.graphics.push() state.board:render() love.graphics.pop()
  love.graphics.push() state.board:rendercell( mousex, mousey ) love.graphics.pop()
  ]]--

  state.renderable:render( fxn.bbox_t(0.25, 0.25, 0.5, 0.5) )

  --[[
  -- TODO(JRC): Figure out how each individual entity will be rendered
  -- (i.e. the arguments they'll take and configuration they'll allow).
  do -- render all entities
    for _, entity in ipairs( entities ) do
      love.graphics.push() entity:render() love.graphics.pop()
    end
  end
  --]]

  --[[
  do -- plot example function
    -- TODO(JRC): Adjust the number of sampling points based on the
    -- dimensions of the rendering window (fewer points for smaller space).
    local plsamplenum = 100
    -- TODO(JRC): Adjust this number to be the number of turns (calculated
    -- by something like turns per value * value range).
    local plsamplesteps = 4
    -- TODO(JRC): Figure out what the actual values for the sample
    -- range of the graph will be (min must be related to turn offset,
    -- max must be related to maximum lookahead).
    local plsamplemin, plsamplemax = 0, 2 * math.pi
    -- TODO(JRC): Find the maximum and minimum bounds for the plot
    -- by taking the function derivatives and finding their zero points.
    local plresultmin, plresultmax = -1.0, 1.0
    -- TODO(JRC): Consider adjusting these based on the size of the display.
    local pltickxnum, pltickynum = 10, 10

    local ploriginx, ploriginy = 1e-1, 0e0
    local plpad = 3e-2
    local plscalex = ( 1.0 - ploriginx - plpad ) * 1.0 / ( plsamplemax - plsamplemin )
    local plscaley = ( 1.0 - 2.0*plpad ) * 1.0 / ( plresultmax - plresultmin )

    love.graphics.setColor( fxn.colors.tuple('black') )
    love.graphics.setLineWidth( 0.01 )

    love.graphics.translate( 0.0, 0.5 )
    do     -- plot axes
      love.graphics.line( 0.0+plpad, 0.0, 1.0-plpad, 0.0 )
      love.graphics.line( ploriginx, -0.5+plpad, ploriginx, 0.5-plpad )
    end do -- plot ticks
      love.graphics.push()
      love.graphics.translate( ploriginx, ploriginy )

      love.graphics.pop()
    end do -- plot function
      love.graphics.push()
      love.graphics.translate( ploriginx, ploriginy )
      love.graphics.scale( plscalex, plscaley )

      local samples = {}
      for sidx = 1, plsamplenum do
        local sratio = ( sidx - 1 ) / ( plsamplenum - 1 )
        local sx = plsamplemin + ( plsamplemax - plsamplemin ) * sratio
        local sy = state.func( sx )
        table.insert( samples, sx ); table.insert( samples, sy )
      end
      love.graphics.setColor( fxn.colors.tuple('dgray') )
      love.graphics.line( unpack(samples) )

      love.graphics.pop()
    end do -- plot discretized function
      love.graphics.push()
      love.graphics.translate( ploriginx, ploriginy )
      love.graphics.scale( plscalex, plscaley )

      for sidx = 1, plsamplesteps do
        local sminrx, smaxrx = ( sidx - 1 ) / plsamplesteps, sidx / plsamplesteps
        local smidrx = ( sidx - 0.5 ) / plsamplesteps

        local sminx = plsamplemin + ( plsamplemax - plsamplemin ) * sminrx
        local smaxx = plsamplemin + ( plsamplemax - plsamplemin ) * smaxrx
        local smidx = plsamplemin + ( plsamplemax - plsamplemin ) * smidrx

        local szeroy = ( plresultmax + plresultmin ) / 2.0
        local smidy = state.func( smidx )

        love.graphics.polygon( 'line', sminx, szeroy, smaxx, szeroy,
          smaxx, smidy, sminx, smidy )
      end

      love.graphics.pop()
    end do -- display plot values at mouse
      love.graphics.push()
      love.graphics.translate( ploriginx, ploriginy )
      love.graphics.scale( plscalex, plscaley )

      local plmousex, plmousey = love.graphics.itransform( input:mousexy() )
      love.graphics.setColor( fxn.colors.tuple('red') )
      love.graphics.line( plmousex, plresultmin, plmousex, plresultmax )

      local plmousefuncy = state.func( plmousex )
      plmousex, plmousefuncy = love.graphics.transform( plmousex, plmousefuncy )
      love.graphics.pop()
      plmousex, plmousefuncy = love.graphics.itransform( plmousex, plmousefuncy )

      love.graphics.circle( 'fill', plmousex, plmousefuncy, 0.01 )
    end
  end
  --]]

  if meta.showstats then -- display the game statistics hud
    local stats = {
      string.format( 'Frame #: %d', meta.framenum ),
      string.format( 'FPS: %.2f', meta.avgfps ),
    }

    local font = love.graphics.getFont()
    local fontx, fonty, fonts = 1e-2, 1.0 - 1e-2, 2.0
    local fontsx, fontsy = love.graphics.itransform( fonts, fonts, true )
    function statxy( si, fw, fh ) return fontx, fonty + fh * ( si - 1 ) end

    for statidx, stat in ipairs( stats ) do
      local statw, stath = love.graphics.itransform(
        fonts * font:getWidth(stat), fonts * font:getHeight(), true )
      local statx, staty = statxy( statidx, statw, stath )
      local nstatx, nstaty = statxy( statidx + 1, statw, stath )

      love.graphics.setColor( fxn.colors.tuple('lgray', 200) )
      love.graphics.polygon( 'fill',
        statx, staty, statx + statw, staty,
        statx + statw, nstaty, statx, nstaty )

      love.graphics.setColor( fxn.colors.tuple('dgray', 200) )
      love.graphics.print( stat, statx, staty, 0, fontsx, fontsy )
    end
  end

  love.graphics.pop()
end
