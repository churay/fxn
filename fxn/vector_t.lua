local struct = require( 'fxn.struct' )
local util = require( 'fxn.util' )

--[[ Constructor ]]--

local vector_t = struct( {}, 'x', 0.0, 'y', 0.0 )
local vector_ipfxns = {}

--[[ Operators ]]--

function vector_ipfxns.__add( self, vector )
  self.x = self.x + vector.x
  self.y = self.y + vector.y
end

function vector_ipfxns.__sub( self, vector )
  self.x = self.x - vector.x
  self.y = self.y - vector.y
end

function vector_ipfxns.__mul( lvalue, rvalue )
  local self, scalar = nil, nil
  if type( lvalue ) == 'number' then self, scalar = rvalue, lvalue
  else self, scalar = lvalue, rvalue end

  self.x = scalar * self.x
  self.y = scalar * self.y
end

function vector_ipfxns.__unm( self )
  self.x = -self.x
  self.y = -self.y
end

function vector_t.__eq( self, vector )
  return util.fequal( self.x, vector.x ) and util.fequal( self.y, vector.y )
end

function vector_t.__tostring( self )
  return string.format( '<%.6f, %.6f>', self.x, self.y )
end

--[[ Public Functions ]]--

function vector_t.dot( self, vector )
  return self.x * vector.x + self.y * vector.y
end

function vector_t.magnitude( self )
  return math.sqrt( self:dot(self) )
end

function vector_ipfxns.norm( self )
  local magnitude = self:magnitude()
  self:mulip( 1.0 / magnitude )
end

function vector_t.angleto( self, vector )
  -- a.b = |a||b|cos(t) ==> t = acos( a.b / |a||b| )
  return math.acos( self:dot(vector) / (self:magnitude()*vector:magnitude()) )
end

function vector_ipfxns.project( self, vector )
  -- a->b = (|a|cos(t)/|b|) * b ==> (a.b/b.b) * b
  local projscale = self:dot( vector ) / vector:dot( vector )
  self.x, self.y = vector.x, vector.y
  self:mulip( projscale )
end

function vector_t.xy( self )
  return self.x, self.y
end

--[[ In-Place Functions ]]--

-- NOTE(JRC): This could be improved by removing the 'vector_ipfxn' table and
-- auto-detecting the correct set of in-place by performing tests and identifying
-- all functions that return a 'vector_t' instance when passed default arguments.

for fxnname, ipfxn in pairs( vector_ipfxns ) do
  local ipname = string.sub( fxnname, string.match(fxnname, '__.*') and 3 or 1 )
  local opname = fxnname

  vector_t[ipname .. 'ip'] = ipfxn
  vector_t[opname] = function( ... )
    local args = { ... }
    local self = table.remove( args, getmetatable(args[1]) == vector_t and 1 or 2 )

    local copy = vector_t( self.x, self.y )
    ipfxn( copy, util.unpack(args) )
    return copy
  end
end

return vector_t
