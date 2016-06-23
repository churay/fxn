local struct = require( 'struct' )

--[[ Constructor ]]--

local vector_t = struct( {}, 'x', 0.0, 'y', 0.0 )

--[[ Operators ]]--

function vector_t.__add( self, vector )
  return vector_t( self.x + vector.x, self.y + vector.y )
end

function vector_t.__sub( self, vector )
  return vector_t( self.x - vector.x, self.y - vector.y )
end

function vector_t.__mul( lvalue, rvalue )
  local self, scalar = nil, nil
  if type( lvalue ) == "number" then self, scalar = rvalue, lvalue
  else self, scalar = lvalue, rvalue end

  return vector_t( scalar * self.x, scalar * self.y )
end

function vector_t.__unm( self )
  return vector_t( -self.x, -self.y )
end

function vector_t.__eq( self, vector )
  return self.x == vector.x and self.y == vector.y
end

function vector_t.__tostring( self )
  return "vec( " .. self.x .. ", " .. self.y .. " )"
end

--[[ Public Functions ]]--

function vector_t.dot( self, vector )
  return self.x * vector.x + self.y * vector.y
end

function vector_t.magnitude( self )
  return math.sqrt( self:dot(self) )
end

function vector_t.normalize( self )
  local magnitude = self:magnitude()
  return vector_t( self.x / magnitude, self.y / magnitude )
end

function vector_t.angleto( self, vector )
  -- a.b = |a||b|cos(t) ==> t = acos( a.b / |a||b| )
  return math.acos( self:dot(vector) / (self:magnitude()*vector:magnitude()) )
end

function vector_t.projonto( self, vector )
  -- a->b = (|a|cos(t)/|b|) * b ==> (a.b/b.b) * b
  return vector * ( self:dot(vector) / vector:dot(vector) )
end

function vector_t.xy( self )
  return self.x, self.y
end

return vector_t
