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

--[[ Operators ]]--

-- TODO(JRC): Implement this function.
function bbox_t.__eq( self, bbox )
  return false
end

-- TODO(JRC): Implement this function.
function bbox_t.__tostring( self )
  return ""
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

function bbox_t.intersect( self, bbox )
  local function rangeintersect( lo1, hi1, lo2, hi2 )
    local vals = { {lo1, 1}, {hi1, 1}, {lo2, 2}, {hi2, 2} }
    table.sort( vals, function(v1, v2) return v1[1] < v2[1] end )
    if vals[1][2] ~= vals[2][2] then return vals[2][1], vals[3][1] end
  end

  local selfmin, selfmax = self:min(), self:max()
  local bboxmin, bboxmax = bbox:min(), bbox:max()

  local xlo, xhi = rangeintersect( selfmin.x, selfmax.x, bboxmin.x, bboxmax.x )
  local ylo, yhi = rangeintersect( selfmin.y, selfmax.y, bboxmin.y, bboxmax.y )

  if xlo ~= nil and xhi ~= nil and ylo ~= nil and yhi ~= nil then
    return bbox_t( xlo, ylo, xhi - xlo, yhi - ylo )
  end
end

function bbox_t.min( self )
  return vector_t( self.pos.x, self.pos.y )
end

function bbox_t.max( self )
  return vector_t( self.pos.x + self.dim.x, self.pos.y + self.dim.y )
end

return bbox_t
