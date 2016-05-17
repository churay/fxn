local util = {}

--[[ Mathematical Functions ]]--

function util.inrange( v, min, max, exclusive )
  if exclusive then return min < v and v < max
  else return min <= v and v <= max end
end

function util.clamp( v, min, max )
  return math.max( math.min(v, max), min )
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

--[[ Lua Language Functions ]]--

function util.map( l, fmap )
  local m = {}
  for k, v in ipairs( l ) do m[k] = fmap( v ) end
  return m
end

function util.reduce( l, facc, v0 )
  local liter, lnext = next( l, nil )
  local vacc = v0

  if not vacc then
    vacc = lnext
    liter, lnext = next( l, liter )
  end

  while liter do
    vacc = facc( vacc, lnext )
    liter, lnext = next( l, liter )
  end

  return vacc
end

function util.len( l )
  local len = 0
  for _ in pairs( l ) do len = len + 1 end
  return len
end

function util.pack( ... )
  return { n = select("#", ...), ... }
end

function util.unpack( vargs )
  return unpack( vargs, 1, vargs.n )
end

return util
