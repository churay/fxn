local util = require( 'util' )
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
-- Constructor: f(x, f1, ..., fn), f_1, ..., f_n
--  - f(x, f1, ..., fn): function that relates all other subfunctions
--  - f_1: the first function that comprises the new function
--  - f_n: the nth function that comprises the new function
--
--  Example Usage:
--
--  local f1 = func_t( function(x) return x end )
--  local f2 = func_t( function(x) return math.sin(x) end )
--  local fadd = f1 + f2
--
--  local fadd0 = fadd(0)        --> 0 + sin(0) = 1
--  local fadd1 = fadd(1)        --> 1 + sin(1) = 1 + sin(1)
--  local faddpi = fadd(math.pi) --> pi + sin(pi) = pi - 1

--[[ Constructor ]]--

local func_t = struct( {}, '_fxn', function(x) return 0 end, '_sfxns', {} )

function func_t._init( self, fxn, ... )
  self._fxn = fxn or function(x) return 0 end
  self._sfxns = util.pack( ... )
end

--[[ Static Functions ]]--

function func_t.binop( fxn )
  return function( x, f1, f2 ) return fxn( f1(x), f2(x) ) end
end

--[[ Operators ]]--

function func_t.__call( self, x )
  return self._fxn( x, util.unpack(self._sfxns) )
end

function func_t.__add( self, other )
  return func_t( func_t.binop(function(v1, v2) return v1 + v2 end), self, other )
end

function func_t.__sub( self, other )
  return func_t( func_t.binop(function(v1, v2) return v1 - v2 end), self, other )
end

function func_t.__mul( self, other )
  return func_t( func_t.binop(function(v1, v2) return v1 * v2 end), self, other )
end

function func_t.__div( self, other )
  return func_t( func_t.binop(function(v1, v2) return v1 / v2 end), self, other )
end

--[[ Public Functions ]]--

--[[ Private Functions ]]--

return func_t
