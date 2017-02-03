local bbox_t = require( 'fxn.bbox_t' )
local vector_t = require( 'fxn.vector_t' )
local struct = require( 'fxn.struct' )
local colors = require( 'fxn.colors' )

--[[ Constructor ]]--

local renderable_t = struct( {},
  '_rbox', false,
  '_rratio', false,
  '_rparent', false,
  '_rchildren', {}
)

--[[ Public Functions ]]--

function renderable_t.render( self, debug )
  local debug = debug or false

  -- TODO(JRC): Update this code so that the original ratio can be viewed
  -- if it's still useful for debugging.
  --[[
  if debug then -- render bounding box for debugging
    love.graphics.push()
    love.graphics.translate( self._rbox.min:xy() )
    love.graphics.scale( self._rbox.dim:xy() )

    -- TODO(JRC): Set a better line width value based on the current scale
    -- being used for the renderable.
    love.graphics.setLineWidth( 0.01 )
    love.graphics.setColor( colors.tuple('magenta') )
    love.graphics.polygon( 'line', 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0 )
    love.graphics.pop()
  end
  --]]

  do -- render actual object contents
    love.graphics.push()
    love.graphics.translate( self._rbox.min:xy() )
    love.graphics.scale( self._rbox.dim:xy() )

    self:_render()
    for _, renderlayer in ipairs( self._rlayers ) do
      renderlayer:render( debug )
    end

    love.graphics.pop()
  end
end

-- TODO(JRC): Consider changing this interface so that it manipulates the
-- existing render box instead of outright replacing it.
-- TODO(JRC): Come up with a better name for this function.
function renderable_t.setrbox( self, rbox, strict, _cratio )
  local strict = strict or false
  -- TODO(JRC): Take this value from parent renderable instead of argument.
  local _cratio = _cratio or love.graphics.getRatio()

  local roffset, rdims = vector_t(), vector_t( rbox.dim:xy() )
  if not strict and self._rratio then
    local wscaled = self._rratio * rbox.dim.y / _cratio
    local hscaled = _cratio * rbox.dim.x / self._rratio

    if wscaled < rbox.dim.x then
      roffset.x, rdims.x = ( rbox.dim.x - wscaled ) / 2.0, wscaled
    else
      roffset.y, rdims.y = ( rbox.dim.y - hscaled ) / 2.0, hscaled
    end
  end

  self._rbox = bbox_t( rbox.min + roffset, rdims )
  _cratio = _cratio * self._rbox:ratio()

  -- TODO(JRC): Fix this so that the correct values are set when setting
  -- up the rendering boxes for all layers.
  for _, renderlayer in ipairs( self._rlayers ) do
    renderlayer:setrbox( renderlayer._rbox, strict, _cratio )
  end
end

-- TODO(JRC): This function will return the window box of the instance renderable,
-- which can be used for mouse intersection.  This is calculated by using inverse
-- transformation of all of the parent transformations.
function renderable_t.wbox( self )
  return nil
end

--[[ Private Functions ]]--

-- NOTE(JRC): This function should be overridden in all subtypes and filled
-- with the implementation that renders the object to a one-by-one space with
-- the origin in the bottom-left corner.
function renderable_t._render( self, ... )
  local cpadding = 1.0e-1

  love.graphics.setColor( colors.tuple('red') )
  love.graphics.polygon( 'fill',
    cpadding, 0.0, 1.0, 1.0 - cpadding,
    1.0 - cpadding, 1.0, 0.0, cpadding )
  love.graphics.polygon( 'fill',
    0.0, 1.0 - cpadding, 1.0 - cpadding, 0.0,
    1.0, cpadding, cpadding, 1.0 )
end

return renderable_t
