local util = {}

--[[ Mathematical Functions ]]--

function util.inrange( v, min, max, exclusive )
  if exclusive then return min < v and v < max
  else return min <= v and v <= max end
end

function util.clamp( v, min, max )
  return math.max( math.min(v, max), min )
end

function util.fequal( v1, v2, epsilon )
  local epsilon = epsilon or 1e-7
  return math.abs( v1 - v2 ) < epsilon
end

--[[ System Functions ]]--

function util.libload( libbase )
  local lib = {}

  local plibpaths = io.popen( 'ls -1a ' .. libbase )
  for libpath in plibpaths:lines() do
    if string.match( libpath, '^.*%.lua$' ) and libpath ~= 'init.lua' then
      local libmodule = string.sub( libpath, 1, string.find(libpath, '%.lua$')-1 )
      lib[libmodule] = require( libmodule )
    end
  end
  plibpaths:close()

  return lib
end

--[[ Table Functions ]]--

function util.map( l, fmap )
  local m = {}
  for k, v in ipairs( l ) do m[k] = fmap( v ) end
  return m
end

function util.reduce( l, facc, v0 )
  local liter, lnext = next( l, nil )
  local vacc = v0

  if vacc == nil then
    vacc = lnext
    liter, lnext = next( l, liter )
  end

  while liter do
    vacc = facc( vacc, lnext )
    liter, lnext = next( l, liter )
  end

  return vacc
end

function util.lmatches( l, v )
  local matches = 0
  for _, lv in ipairs( l ) do
    if lv == v then matches = matches + 1 end
  end
  return matches ~= 0 and matches or false
end

function util.lsub( l, v, rall )
  local rall = rall or false
  for i = #l, 1, -1 do
    if l[i] == v then
      table.remove( l, i )
      if not rall then break end
    end
  end
end

function util.len( l )
  local len = 0
  for _ in pairs( l ) do len = len + 1 end
  return len
end

--[[ Language Functions ]]--

function util.copy( orig, copymt, _copied )
  if type( orig ) ~= 'table' then return orig end
  if _copied and _copied[orig] then return _copied[orig] end

  local copied = _copied or {}
  local copy = copymt and setmetatable( {}, getmetatable(orig) ) or {}
  copied[orig] = copy
  for ok, ov in pairs( orig ) do
    copy[util.copy(ok, copymt, copied)] = ( util.copy(ov, copymt, copied) )
  end

  return copy
end

function util.unpack( t, i )
  local i = i or 1
  if t[i] ~= nil then return t[i], util.unpack( t, i + 1 ) end
end

return util
