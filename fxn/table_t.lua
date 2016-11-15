local struct = require( 'struct' )
local util = require( 'util' )

--[[ Constructor ]]--

local table_t = struct( {}, '_default', nil )

--[[ Operators ]]--

function table_t.__index( self, key )
  local defaultvalue = rawget( self, '_default' )
  if defaultvalue ~= nil then
    local value = util.copy( defaultvalue )
    rawset( self, key, value )
    return value
  else
    return nil
  end
end

return table_t
