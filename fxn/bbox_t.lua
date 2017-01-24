local struct = require( 'struct' )
local vector_t = require( 'vector_t' )

--[[ Constructor ]]--

local bbox_t = struct( {}, 'pos', vector_t(), 'dim', vector_t() )

function bbox_t._init( self, ... )
  local args = { ... }

  if #args == 2 then
    self.pos = vector_t( args[1].x, args[1].y )
    self.dim = vector_t( args[2].x, args[2].y )
  elseif #args == 4 then
    self.pos = vector_t( tonumber(args[1]), tonumber(args[2]) )
    self.dim = vector_t( tonumber(args[3]), tonumber(args[4]) )
  end
end

--[[ Public Functions ]]--

-- TODO(JRC): Determine a good interface for a set of function that
-- will allow for transforming the bounding box with standard linear
-- transformations (e.g. translation, scale, etc.).
function bbox_t.transform( self, ... )
  return nil
end

function bbox_t.contains( self, point )
  return nil
end

function bbox_t.overlay( self, bbox )
  return nil
end

return bbox_t
