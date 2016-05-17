-- TODO(JRC): A structure for use by Lua modules acts as a factory that
-- produces tables that all have the same data members with default values.
-- Essentially, a struct is a factory for a table type that contains
-- functions specified by patterns (which have default implementations)
-- and local functions of their own (which replace interface functions).
--
-- TODO(JRC): What does the interface really buy me here?  Since Lua isn't
-- a statically typed language, it cannot be used to help with types.  If
-- a struct is expanded to be able to define default functions, then 
--
-- TODO(JRC): It might be best to watch Jon Blow's talk about data structures
-- in Jai again and see if his approach would fit; 'subclasses' would essentially
-- expand functions in 'superclasses' and replace all redefined instances.
--
-- Precedence of Operations:
-- - Struct
-- - First Pattern
-- - ...
-- - Last Pattern

local struct = {}

return struct


--[[
The following is an example implementation using a Go struct:

local struct = require( 'struct' )
local interf = require( 'interface' )

local simobj = require( 'simobj' ) -- one type of interface; defines draw and update

local bubble = struct({}, ...)

function bubble.draw( gfx )
  -- overrides
end




]]--

--[[
The following is an example implementation using a Jai struct:

local struct = require( 'struct' )
local vector = require( 'vector' ) -- defines coordinate data, vector functions
local simobj = require( 'simobj' ) -- defines position data, draw, update

-- grab and duplicate all functions from predeccesor (duplicate all values as well to enhance data locality)
-- replace all redefined functions with local redefinitions


local bubble = struct({-- new data --}, {-- contained structs??? (stupid; should probably be specified as an extra field) --})


]]--
