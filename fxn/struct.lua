local function struct( basetable, ... )
  local newstruct, newstructmt = {}, {}

  local basestructs = ... and { ... } or {}
  for sidx = #basestructs, 1, -1 do
    local basestruct = basestructs[sidx]
    for sk, sv in pairs( basestruct ) do newstruct[sk] = sv end
  end

  for bk, bv in pairs( basetable or {} ) do newstruct[bk] = bv end

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
