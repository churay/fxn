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

local function struct( basetable, ... )
  local newstruct = basetable or {}
  local newstructmt = {}

  local basestructs = ... and { ... } or {}
  for sidx = #basestructs, 1, -1 do
    local basestruct = basestructs[sidx]
    local basestructmt = getmetatable( basestruct ) or {}

    for sk, sv in pairs( basestructmt ) do newstruct[sk] = sv end
    for sk, sv in pairs( basestruct ) do newstruct[sk] = sv end
  end

  newstruct.__index = newstruct
  newstructmt.__call = function( overtable )
    local objtable = setmetatable( {}, newstruct )
    for ok, ov in pairs( overtable ) do objtable[ok] = ov end
    return objtable
  end

  setmetatable( newstruct, newstructmt )

  return newstruct
end

return struct

--[[
local test = struct({s=10, y=20})

function test.gets( self )
  return self.s
end

function test.gety( self )
  return self.y
end

local derp = test() -- pass in nothing, get default values
print(derp:gets())

local herp = test({s=22}) -- pass in table, table values will override (only if already exist)
print(derp:gets())
]]--

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
