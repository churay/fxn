local bbox_t = require( 'fxn.bbox_t' )
local vector_t = require( 'fxn.vector_t' )
local struct = require( 'fxn.struct' )
local colors = require( 'fxn.colors' )

--[[ Constructor ]]--

local renderable_t = struct( {},
  '_rbox', false,
  '_rratio', false,
  '_cratio', false,
  '_wbox', false,
  '_rcanvas', false,
  '_rlayers', {}
)

--[[ Public Functions ]]--

function renderable_t.addlayer( self, layer, rbox, strict )
  local rbox = rbox or bbox_t( 0.0, 0.0, 1.0, 1.0 )
  local strict = strict or false

  table.insert( self._rlayers, layer )
  layer._rcanvas = self
  layer:_setrbox( rbox, strict )
  layer._wbox = false
end

function renderable_t.remlayer( self, layeridx )
  local layer = table.remove( self._rlayers, layeridx )
  layer._rcanvas = false
  layer._wbox = false
  return layer
end

function renderable_t.render( self, debug )
  local debug = debug or false

  love.graphics.push()
  love.graphics.translate( self._rbox.min:xy() )
  love.graphics.scale( self._rbox.dim:xy() )

  if not self._wbox then
    local wboxx, wboxy = love.graphics.transform( 0.0, 0.0, false )
    local wboxw, wboxh = love.graphics.transform( 1.0, 1.0, true )
    -- NOTE(JRC): Adjustments for inverted Y axis in screen space.
    self._wbox = bbox_t( wboxx, wboxy + wboxh, wboxw, -wboxh )
  end

  self:_render()
  for _, layer in ipairs( self._rlayers ) do layer:render( debug ) end

  -- TODO(JRC): Set different colors based on the canvas in order to avoid
  -- ambiguity in debug bounding box renders.
  if debug then
    love.graphics.setLineWidth( 0.01 )
    love.graphics.setColor( colors.tuple('magenta') )
    love.graphics.polygon( 'line', 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0 )
  end
  love.graphics.pop()
end

function renderable_t.getrpos( self, wpos )
  if self._wbox and self._wbox:contains( wpos ) then
    local sxpos = ( (wpos.x - self._wbox.min.x) / self._wbox.dim.x )
    local sypos = 1.0 - ( (wpos.y - self._wbox.min.y) / self._wbox.dim.y )
    return vector_t( sxpos, sypos )
  end
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

-- TODO(JRC): Consider changing this interface so that it manipulates the
-- existing render box instead of outright replacing it.
function renderable_t._setrbox( self, rbox, strict )
  local strict = strict or false
  local cratio = self._rcanvas._cratio

  local roffset, rdims = vector_t(), vector_t( rbox.dim:xy() )
  if not strict and self._rratio then
    local wscaled = self._rratio * rbox.dim.y / cratio
    local hscaled = cratio * rbox.dim.x / self._rratio

    if wscaled < rbox.dim.x then
      roffset.x, rdims.x = ( rbox.dim.x - wscaled ) / 2.0, wscaled
    else
      roffset.y, rdims.y = ( rbox.dim.y - hscaled ) / 2.0, hscaled
    end
  end

  self._rbox = bbox_t( rbox.min + roffset, rdims )
  self._cratio = cratio * self._rbox:ratio()

  -- TODO(JRC): Fix this so that the correct values are set when setting
  -- up the rendering boxes for all layers.
  for _, layer in ipairs( self._rlayers ) do
    layer:_setrbox( layer._rbox, strict )
  end
end

return renderable_t
