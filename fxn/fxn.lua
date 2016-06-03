local struct = require( 'struct' )

-- A function is a tree defined by one or more functions.
-- E.g. f(x) = g(x) + h(x)
--      g(x) = sin(x)
--      h(x) = x
-- It's probably best to represent each function as an AST that's created
-- from an infix notation processed by the shunting yard algorithm.
-- E.g. f(x) = g(x) + h(x)
--            f(x)
--            / \
--         g(x)  h(x)
-- Trees probably will not be more than one level deep, but it will be
-- interesting to play around with multiple children and multiple levels
-- of depth.
--
-- Constructor: f(1, ..., n), f_1, ..., f_n
--  - f(1, ..., n): function that relates all other subfunctions
--  - f_1: the first function that comprises the new function
--  - f_n: the nth function that comprises the new function

local fxn_t = struct( {}, '_fxn', function(x) return 0 end )

--[[
function fxn_t.__add( self, other )

  return vector_t( self.x + vector.x, self.y + vector.y )
end

function fxn_t.__sub( self, other )
  return vector_t( self.x - vector.x, self.y - vector.y )
end

function fxn_t.__mul( self, other )
  return 0
end
]]--

return fxn_t
