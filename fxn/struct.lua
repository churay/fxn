local function struct( basetable, ... )
  local newstruct = basetable or {}
  local newstructmt = {}

  local basestructs = ... and { ... } or {}
  for sidx = #basestructs, 1, -1 do
    local basestruct = basestructs[sidx]
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
