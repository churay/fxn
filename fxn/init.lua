-- TODO(JRC): The following is a list of all of the features that should/could
-- be in the 'fxn' library table:
-- - [x] Automatic population with all of the modules in the library directory.
-- - [ ] Fetching of modules on-demand to make it possible to import only subsets
--   of the library.
-- - [ ] Extend the loading code to be capable of handling an arbitrary base
--   directory so that the code can be executed in locations aside from the
--   project root.

local fxn = {}

local fxnmodules = {}
local pfxnfilenames = io.popen( 'ls -1a fxn' )
for fxnfilename in pfxnfilenames:lines() do
  if string.match( fxnfilename, '^.*%.lua$' ) and fxnfilename ~= 'init.lua' then
    local extpos = string.find( fxnfilename, '%.lua$' )
    local fxnfilemodule = string.sub( fxnfilename, 1, extpos-1 )
    table.insert( fxnmodules, fxnfilemodule )
  end
end
pfxnfilenames:close()

for _, fxnmodule in ipairs( fxnmodules ) do
  fxn[fxnmodule] = require( fxnmodule )
end

return fxn
