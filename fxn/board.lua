local struct = require( 'struct' )
local graph_t = require( 'graph' )

local board_t = struct( {}, '_graph', graph_t() )

return board_t
