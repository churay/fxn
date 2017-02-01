local bbox_t = require( 'fxn.bbox_t' )
local struct = require( 'fxn.struct' )
local colors = require( 'fxn.colors' )

--[[ Constructor ]]--

local renderable_t = struct( {}, '_subrenders', {}, '_targetratio', nil )

--[[ Public Functions ]]--

function renderable_t.render( self, renderbox, strict, _contextratio )
  local strict = strict or false
  local _contextratio = _contextratio or
    love.graphics.getWidth() / love.graphics.getHeight()

  if not strict and self._targetratio ~= nil then
    renderbox = bbox_t( renderbox.min.x, renderbox.min.y, renderbox.dim.x,
      (renderbox.dim.x / self._targetratio) * renderbox.dim.y )
  end

  love.graphics.push()
  love.graphics.translate( renderbox.min:xy() )
  love.graphics.scale( renderbox.dim:xy() )

  self:_render()
  for _, subrenders in ipairs( self._subrenders ) do
    local subrenderable, subbbox, substrict = unpack( subrender )
    subrenderable:render( subbbox, substrict, _contextratio * renderbox:ratio() )
  end

  love.graphics.pop()
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
