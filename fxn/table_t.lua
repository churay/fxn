local util = require( 'util' )

--[[ Constructor ]]--

local table_t, table_mt = {}, {}

function table_mt.__call( self, default )
  local objtable = setmetatable( {}, table_t )
  rawset( objtable, '__default', default )
  return objtable
end

--[[ Operators ]]--

function table_t.__index( self, key )
  local value = util.copy( rawget(self, '__default') )
  rawset( self, key, value )
  return value
end

--[[ Public Functions ]]--

return setmetatable( table_t, table_mt )
