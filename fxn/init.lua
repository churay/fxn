-- TODO(JRC): The following is a list of all of the features that should/could
-- be in the 'fxn' library table:
-- - [ ] Automatic population with all of the modules in the library directory.
-- - [ ] Fetching of modules on-demand to make it possible to import only subsets
--   of the library.

local fxn = {}

-- NOTE(JRC): Adding subdirectory/submodule support for this would be pretty
-- radical.
-- for each file f in the same directory as this file :
--   fxn.(f.name) = require( f.name )

-- get all files in this directory:
--   find the path to the current directory (basename of current file)
--   find all files in this directory with 'find . -maxdepth 1 -type f -printf "%f\n"'
--   simply return a list of all the names that end with ".lua"
--   (paths do not need to be prepended because all of these files must be in the lua path)

-- TODO(JRC): Extend this code to be capable of handling an arbitrary base
-- directory so this code can be used in multiple libraries.
-- TODO(JRC): Extend this code so that it can recursve to subdirectories and
-- load modules in these directories.
-- TODO(JRC): Remove the 'init.lua' file contained in the 'filenames' list.
local filenames, pfilenames = {}, io.popen( 'ls -1a fxn' )
for filename in pfilenames:lines() do
  if string.find( filename, '^.*%.lua$' ) then table.insert( filenames, filename ) end
end
pfilenames:close()

for _, filename in ipairs( filenames ) do print( filename ) end

return fxn
