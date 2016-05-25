local function struct( basestructs, ... )
  local newstruct, newstructmt = {}, {}

  local basestructs = basestructs or {}
  for sidx = #basestructs, 1, -1 do
    local basestruct = basestructs[sidx]
    for sk, sv in pairs( basestruct ) do newstruct[sk] = sv end
  end

  local basefields = ... and { ... } or {}
  for bfidx = 1, #basefields - 1, 2 do
    local bfname, bfval = basefields[bfidx+0], basefields[bfidx+1]
    newstructmt.__fields[bfidx] = bfname
    newstruct[bfname] = bfval
  end

  newstruct.__index = newstruct
  newstructmt.__call = function( ... )
    local objtable = setmetatable( {}, newstruct )

    if objtable._init ~= nil then
      objtable:_init( ... )
    else
      local overfields = ... and { ... } or {}
      for fidx = 1, math.min(#overfields, #newstructmt.__fields) do
        local fname = newstructmt.__fields[fidx]
        objtable[fname] = overfields[fidx]
      end
    end

    return objtable
  end

  setmetatable( newstruct, newstructmt )

  return newstruct
end

return struct
