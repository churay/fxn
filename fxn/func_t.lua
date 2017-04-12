local struct = require( 'fxn.struct' )
local util = require( 'util' )

-- NOTE(JRC): This module tends to create a lot of lightweight functions that only
-- serve one purpose, which may cause problems come time for garbage collection.

--[[ Constructor ]]--

local func_t = struct( {}, '_fxn', function(x) return 0 end, '_sfxns', {} )

function func_t._init( self, fxn, ... )
  self._fxn = fxn or function(x) return 0 end
  self._sfxns = { ... }
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
