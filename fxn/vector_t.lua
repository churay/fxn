local struct = require( 'struct' )

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
  if type( lvalue ) == "number" then self, scalar = rvalue, lvalue
  else self, scalar = lvalue, rvalue end

  self.x = scalar * self.x
  self.y = scalar * self.y
end

function vector_ipfxns.__unm( self )
  self.x = -self.x
  self.y = -self.y
end

function vector_t.__eq( self, vector )
  return self.x == vector.x and self.y == vector.y
end

function vector_t.__tostring( self )
  return "< " .. self.x .. ", " .. self.y .. " >"
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
  self:mulip( self:dot(vector) / vector:dot(vector) )
end

function vector_t.xy( self )
  return self.x, self.y
end

--[[ In-Place Functions ]]--

for fxnname, ipfxn in pairs( vector_ipfxns ) do
  local ipname = string.sub( string.match(fxnname, '__.*') and 3 or 1 ) .. 'ip'
  local opname = fxnname

  vector_t[ipname] = ipfxn
  vector_t[opname] = function( ... )
    local args = { ... }
    local copy = util.copy( table.remove(args, 1) )
    return ipfxn( copy, args )
  end
end

return vector_t
