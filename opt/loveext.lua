local lxt = {}

--[[ love.graphics extensions ]]--

local lgstack = {}
local lgxform = { 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0 }

local function getmidx( r, c )
  return 3 * ( c - 1 ) + r
end

local function lgapplyxform( xform )
  local newxform = { 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0 }

  for ridx = 1, 3 do
    for cidx = 1, 3 do
      local entry = 0
      for eidx = 1, 3 do
        entry = entry + lgxform[getmidx(ridx, eidx)] * xform[getmidx(eidx, cidx)]
      end
      newxform[getmidx(ridx, cidx)] = entry
    end
  end

  lgxform = newxform
end

local lgexts = {}

function lgexts.origin()
  lgxform = { 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0 }
end

function lgexts.pop()
  if next( lgstack ) then lgxform = table.remove( lgstack ) end
end

function lgexts.push()
  local lgxformcopy = {}
  for _, entry in ipairs( lgxform ) do table.insert( lgxformcopy, entry ) end
  table.insert( lgstack, lgxformcopy )
end

function lgexts.rotate( angle )
  local angle = angle or 0.0
  local rotxform = {
    math.cos(angle), -math.sin(angle), 0.0,
    math.sin(angle),  math.cos(angle), 0.0,
    0.0, 0.0, 1.0
  }
  lgapplyxform( rotxform )
end

function lgexts.scale( scalex, scaley )
  local scalex, scaley = scalex or 1.0, scaley or 1.0
  local scalexform = { scalex, 0.0, 0.0, 0.0, scaley, 0.0, 0.0, 0.0, 1.0 }
  lgapplyxform( scalexform )
end

function lgexts.shear( shearx, sheary )
  local shearx, sheary = shearx or 0.0, sheary or 0.0
  local shearxform = { 1.0, shearx, 0.0, sheary, 1.0, 0.0, 0.0, 0.0, 1.0 }
  lgapplyxform( shearxform )
end

function lgexts.translate( transx, transy )
  local transx, transy = transx or 0.0, transy or 0.0
  local transxform = { 1.0, 0.0, transx, 0.0, 1.0, transy, 0.0, 0.0, 1.0 }
  lgapplyxform( transxform )
end

for lgfname, lgfext in pairs( lgexts ) do
  local lgforg = love.graphics[lgfname]

  love.graphics[lgfname] = function( ... )
    lgfext( ... )
    lgforg( ... )
  end
end

function love.graphics.getTransform()
  local lgxformcopy = {}
  for _, exform in ipairs( lgxform ) do table.insert( lgxformcopy, exform ) end
  return lgxformcopy
end

return lxt
