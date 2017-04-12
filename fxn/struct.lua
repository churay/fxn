local util = require( 'util' )

-- Struct Rules:
-- Distribute copies of all default fields (per-instance fields).
-- Allow overriding of extra fields, but do not allow for overrides.
--
-- Struct Function Override Order:
-- 1. Local Object
-- 2. Struct for Local Object (Metatable)
-- 3. Parent Struct of Struct
--   3+N. Nth Listed Parent Struct of Struct
local function struct( basestructs, ... )
  local newstruct, newstructmt = { __fields = {}, __fieldnames = {} }, {}
  local structfields = { ... }

  local basestructs = basestructs or {}
  table.insert( basestructs, 1, newstruct )

  for fidx = 1, #structfields - 1, 2 do
    local fname, fval = structfields[fidx+0], structfields[fidx+1]
    if type( fname ) ~= 'string' then return nil end

    newstruct.__fields[fname] = fval
    newstruct.__fieldnames[( fidx + 1 ) / 2] = fname
  end

  newstruct.__index = function( _, key )
    for bsidx = 1, #basestructs do
      if basestructs[bsidx][key] ~= nil then return basestructs[bsidx][key] end
    end
  end

  newstructmt.__call = function( newstruct_t, ... )
    local objtable = setmetatable( {}, newstruct )
    local objfields = { ... }

    for bsidx = 1, #basestructs do
      for fname, fval in pairs( basestructs[bsidx].__fields ) do
        if objtable[fname] == nil then objtable[fname] = util.copy( fval, true ) end
      end
    end

    if objtable._init ~= nil then
      objtable:_init( ... )
    else
      for fidx = 1, math.min( #objfields, #newstruct.__fieldnames ) do
        objtable[newstruct.__fieldnames[fidx]] = objfields[fidx]
      end
    end

    return objtable
  end

  return setmetatable( newstruct, newstructmt )
end

return struct
