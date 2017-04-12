local util = require( 'util' )
local struct = require( 'fxn.struct' )
local vector_t = require( 'fxn.vector_t' )

--[[ Constructor ]]--

local bbox_t = struct( {}, 'min', vector_t(), 'max', vector_t(), 'dim', vector_t() )

function bbox_t._init( self, ... )
  local args = { ... }

  if #args == 2 then
    self.min.x, self.min.y = args[1].x, args[1].y
    self.dim.x, self.dim.y = args[2].x, args[2].y
  elseif #args == 4 then
    self.min.x, self.min.y = tonumber( args[1] ), tonumber( args[2] )
    self.dim.x, self.dim.y = tonumber( args[3] ), tonumber( args[4] )
  end
  self.max.x, self.max.y = self.min.x + self.dim.x, self.min.y + self.dim.y
end

--[[ Operators ]]--

function bbox_t.__eq( self, bbox )
  return self.min == bbox.min and self.max == bbox.max and self.dim == bbox.dim
end

function bbox_t.__tostring( self )
  return string.format( '[%s, %s]', tostring(self.min), tostring(self.max) )
end

--[[ Public Functions ]]--

function bbox_t.translate( self, ... )
  local args = { ... }
  local tvec = #args == 2 and vector_t( ... ) or args[1]
  self.min:addip( tvec )
  self.max:addip( tvec )
end

function bbox_t.scale( self, ... )
  local args = { ... }
  local svec = #args == 2 and vector_t( ... ) or args[1]
  self.dim.x, self.dim.y = svec.x * self.dim.x, svec.y * self.dim.y
  self.max.x, self.max.y = self.min.x + self.dim.x, self.min.y + self.dim.y
end

function bbox_t.contains( self, point )
  return util.inrange( point.x, self.min.x, self.max.x ) and
    util.inrange( point.y, self.min.y, self.max.y )
end

function bbox_t.intersect( self, bbox )
  local function rangeintersect( lo1, hi1, lo2, hi2 )
    local vals = { {lo1, 1}, {hi1, 1}, {lo2, 2}, {hi2, 2} }
    table.sort( vals, function(v1, v2) return v1[1] < v2[1] end )
    if vals[1][2] ~= vals[2][2] then return vals[2][1], vals[3][1] end
  end

  local xlo, xhi = rangeintersect( self.min.x, self.max.x, bbox.min.x, bbox.max.x )
  local ylo, yhi = rangeintersect( self.min.y, self.max.y, bbox.min.y, bbox.max.y )

  if xlo ~= nil and xhi ~= nil and ylo ~= nil and yhi ~= nil then
    return bbox_t( xlo, ylo, xhi - xlo, yhi - ylo )
  end
end

function bbox_t.ratio( self )
  return self.dim.x / self.dim.y
end

return bbox_t
