local bbox_t = require( 'fxn.bbox_t' )
local struct = require( 'fxn.struct' )

--[[ Constructor ]]--

-- TODO(JRC): Update this type so that each render type has a list of
-- embedded render types that are overlayed on top on the instance
-- at some specified sub-box.
local render_t = struct( {}, '_subrenders', {}, '_ratio', nil )

--[[ Public Functions ]]--

function render_t.render( self, rbox, strict, _ratio )
  local _ratio = love.graphics.getWidth() / love.graphics.getHeight()

  -- TODO(JRC): Fix the implementation of this function so that the
  -- render box has its y dimension scaled properly given the target
  -- aspect ratio and the original render box dimensions.
  love.graphics.push()
  if not strict and self._ratio ~= nil then
    rbox = bbox_t( rbox.min.x, rbox.min.y, rbox.dim.x, rbox.dim.y )
  end
  love.graphics.scale( rbox.dim.xy() )
  love.graphics.translate( rbox.min.xy() )
  love.graphics.pop()
end

--[[ Private Functions ]]--

function render_t._render( self, arg )
  
end

return render_t
