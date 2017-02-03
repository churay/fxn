local lxt = {}

--[[ love.graphics extensions ]]--

local lgstack = {}
local lgxform = { 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0 }

local function getmatidx( r, c, nc )
  local nc = nc or 3
  return nc * ( r - 1 ) + c
end

local function getmatmult( mlhs, mrhs )
  local mres = { 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0 }

  for ridx = 1, 3 do
    for cidx = 1, 3 do
      local e = 0
      for eidx = 1, 3 do e = e + mlhs[getmatidx(ridx, eidx)] * mrhs[getmatidx(eidx, cidx)] end
      mres[getmatidx(ridx, cidx)] = e
    end
  end

  return mres
end

local function getvecmult( mlhs, vrhs )
  local vres = { 0.0, 0.0, 0.0 }

  for ridx = 1, 3 do
    local e = 0
    for eidx = 1, 3 do e = e + mlhs[getmatidx(ridx, eidx)] * vrhs[eidx] end
    vres[ridx] = e
  end

  return vres
end

local function getmatinv( mat )
  local maug = {
    mat[1], mat[2], mat[3], 1.0, 0.0, 0.0,
    mat[4], mat[5], mat[6], 0.0, 1.0, 0.0,
    mat[7], mat[8], mat[9], 0.0, 0.0, 1.0
  }

  local function getmidx( r, c ) return getmatidx( r, c, 6 ) end

  local function rowswap( row1, row2 )
    for col = 1, 6 do
      local eidx1, eidx2 = getmidx( row1, col ), getmidx( row2, col )
      maug[eidx1], maug[eidx2] = maug[eidx2], maug[eidx1]
    end
  end

  local function rowscale( row, scale )
    for col = 1, 6 do
      local eidx = getmidx( row, col )
      maug[eidx] = scale * maug[eidx]
    end
  end

  local function rowadd( srow, drow, scale )
    for col = 1, 6 do
      local sidx, didx = getmidx( srow, col ), getmidx( drow, col )
      maug[didx] = maug[didx] + scale * maug[sidx]
    end
  end

  for ridx = 1, 3 do
    local pidx = ridx
    for kridx = ridx, 3 do
      if math.abs(maug[getmidx(pidx, ridx, 6)]) < math.abs(maug[getmidx(kridx, ridx)]) then
        pidx = kridx
      end
    end
    rowswap( pidx, ridx )

    for kridx = 1, 3 do
      if kridx ~= ridx then
        local krscale = -1.0 * maug[getmidx(kridx, ridx)] / maug[getmidx(ridx, ridx)]
        rowadd( ridx, kridx, krscale )
        maug[getmidx(kridx, ridx)] = 0.0
      end
    end

    local rscale = 1 / maug[getmidx(ridx, ridx)]
    rowscale( ridx, rscale )
  end

  return {
    maug[04], maug[05], maug[06],
    maug[10], maug[11], maug[12],
    maug[16], maug[17], maug[18]
  }
end

local function lgapplyxform( xform )
  lgxform = getmatmult( lgxform, xform )
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

function love.graphics.transform( posx, posy, linear )
  local linear = linear or false
  local vpos = { posx, posy, linear and 0.0 or 1.0 }

  local vres = getvecmult( lgxform, vpos )
  return vres[1], vres[2]
end

function love.graphics.itransform( posx, posy, linear )
  local linear = linear or false
  local vpos = { posx, posy, linear and 0.0 or 1.0 }

  local vres = getvecmult( getmatinv(lgxform), vpos )
  return vres[1], vres[2]
end

function love.graphics.getTransform()
  local lgxformcopy = {}
  for _, exform in ipairs( lgxform ) do table.insert( lgxformcopy, exform ) end
  return lgxformcopy
end

function love.graphics.getRatio()
  return love.graphics.getWidth() / love.graphics.getHeight()
end

return lxt
