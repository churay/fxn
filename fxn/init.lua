local util = require( 'fxn.util' )
local fxn = util.libload( 'fxn' )

-- NOTE(JRC): If any of the reserved variable tables are overloaded with
-- a module name, then this module should fail to load.
if fxn.global ~= nil or fxn.model ~= nil or fxn.view ~= nil or fxn.input ~= nil then
  return nil
end

--[[ Global Values ]]--

fxn.global = {}
fxn.global.debug = true
fxn.global.fnum = 1
fxn.global.fps = 60.0
fxn.global.avgfps = 0.0
fxn.global.fdt = 1 / fxn.global.fps

--[[ Model Values ]]--

fxn.model = {}
fxn.model.board = 0
fxn.model.func = 0

--[[ View Values ]]--

fxn.view = {}
fxn.view.viewport = 0

--[[ Input Values ]]--

fxn.input = {}
fxn.input.mouse = 0

return fxn
