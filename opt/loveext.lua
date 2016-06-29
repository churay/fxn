local lxt = {}

--[[ love.graphics extensions ]]--

local lgstack = {}
local lgxform = { 1.0, 0.0, 0.0, 0.0, 1.0, 0.0 }

function love.graphics.getTransform()
  local lgxformcopy = {}
  for _, exform in ipairs( lgxform ) do table.insert( lgxformcopy, exform ) end
  return lgxformcopy
end

local lgexts = {}

function lgexts.origin()
  lgstack = {}
  lgxform = { 1.0, 0.0, 0.0, 0.0, 1.0, 0.0 }
end

function lgexts.pop()
  lgxform = table.remove( lgstack )
end

function lgexts.push()
  local lgxformcopy = {}
  for _, exform in ipairs( lgxform ) do table.insert( lgxformcopy, exform ) end
  table.insert( lgstack, lgxformcopy )
end

function lgexts.rotate( angle )
  -- TODO(JRC)
end

function lgexts.scale( scalex, scaley )
  -- TODO(JRC)
end

function lgexts.shear( shearx, sheary )
  -- TODO(JRC)
end

function lgexts.translate( transx, transy )
  -- TODO(JRC)
end

for lgfname, lgfext in pairs( lgexts ) do
  love.graphics[lgfname] = function( ... )
    lgfext( ... )
    love.graphics[lgfname]( ... )
  end
end

return lxt
