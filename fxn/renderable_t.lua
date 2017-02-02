local bbox_t = require( 'fxn.bbox_t' )
local vector_t = require( 'fxn.vector_t' )
local struct = require( 'fxn.struct' )
local colors = require( 'fxn.colors' )

--[[ Constructor ]]--

local renderable_t = struct( {}, '_subrenders', {}, '_targetratio', false )

--[[ Public Functions ]]--

function renderable_t.render( self, bbox, strict, _contextratio )
  local strict = strict or false
  local _contextratio = _contextratio or
    love.graphics.getWidth() / love.graphics.getHeight()

  local roffset, rdims = vector_t(), vector_t( bbox.dim:xy() )
  if not strict and self._targetratio then
    local wscaled = self._targetratio * bbox.dim.y / _contextratio
    local hscaled = _contextratio * bbox.dim.x / self._targetratio

    if wscaled < bbox.dim.x then
      roffset.x, rdims.x = ( bbox.dim.x - wscaled ) / 2.0, wscaled
    else
      roffset.y, rdims.y = ( bbox.dim.y - hscaled ) / 2.0, hscaled
    end
  end

  local rbox = bbox_t( bbox.min + roffset, rdims )
  _contextratio = _contextratio * rbox:ratio()

  --[[
  do -- render bounding box for debugging
    love.graphics.push()
    love.graphics.translate( bbox.min:xy() )
    love.graphics.scale( bbox.dim:xy() )

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
    love.graphics.translate( rbox.min:xy() )
    love.graphics.scale( rbox.dim:xy() )

    self:_render()
    for _, subrenders in ipairs( self._subrenders ) do
      local subrenderable, subbbox, substrict = unpack( subrender )
      subrenderable:render( subbbox, substrict, _contextratio )
    end

    love.graphics.pop()
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

return renderable_t
