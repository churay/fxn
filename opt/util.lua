local util = {}

--[[ Language Functions ]]--

function util.pprint( o )
  print( util.pretty(o) )
end

-- TODO(JRC): Update this function so that metatable values are printed.
function util.pretty( o, noexpand, _currdepth )
  local noexpand = noexpand or false
  local _currdepth = _currdepth or 0
  local padding = '  '

  local prefix = string.rep( padding, _currdepth )
  if type( o ) == 'string' then
    return string.format( '%q', o )
  elseif type( o ) == 'table' and not noexpand then
    local elemstrs = {}
    for k, v in pairs( o ) do
      local kstr = util.pretty(k, true, 0)
      local vstr = util.pretty(v, false, _currdepth + 1)
      local elemstr = string.format( '%s%s[%s] = %s', prefix, padding, kstr, vstr )
      table.insert( elemstrs, elemstr )
    end

    return string.format( '{%s%s}', ( #elemstrs ~= 0 and '\n' or ''),
      table.concat(elemstrs, ',\n') )
  else
    return tostring( o )
  end
end

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

--[[ String Functions ]]--

function util.iterstring( str, sep )
  local sep = sep or '\n'
  local pattern = string.format( '(.-)(%s)', sep )

  local ipos, iidx = 1, 0
  return function()
    iidx = iidx + 1

    local spos, epos, capture = string.find( str, pattern, ipos )
    if spos then
      ipos = epos + 1
      return iidx, capture
    elseif ipos <= #str then
      capture = string.sub( str, ipos )
      ipos = #str + 1
      return iidx, capture
    end
  end
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

function util.lconcat( l1, l2, ip )
  local l = ip and l1 or {}
  if not ip then for _, v1 in ipairs( l1 ) do table.insert( l, v1 ) end end
  for _, v2 in ipairs( l2 ) do table.insert( l, v2 ) end
  return l
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

--[[ System Functions ]]--

function util.libload( libbase, debug )
  local debug = debug or false
  local lib, libmt = { __modules={} }, {}

  -- TODO(JRC): Ammend this section so that it uses 'package.searchpath' to
  -- determine whether the contents of the directory are valid or not.
  local libpaths = io.popen( 'ls -1a ' .. libbase )
  for libpath in libpaths:lines() do
    if not string.match( libpath, '^%.+$' ) and libpath ~= 'init.lua' then
      if os.execute( 'test -d ' .. libpath ) == 0 then
        lib.__modules[libpath] = true
      elseif string.match( libpath, '^.*%.lua$' ) then
        local modname = string.sub( libpath, 1, string.find(libpath, '%.lua$')-1 )
        lib.__modules[modname] = true
      end
    end
  end
  libpaths:close()

  function libmt.__index( libtable, libpath )
    local libenv, libenvpath = libtable, libbase
    for partidx, libpathpart in util.iterstring( libpath, '%.' ) do
      libenvpath = string.format( '%s.%s', libenvpath, libpathpart )

      local libenvmods = rawget( libenv, '__modules' )
      if libenvmods and libenvmods[libpathpart] then
        if debug then
          local loadsuccess, loadresult = pcall( require, libenvpath )
          if not loadsuccess then print( loadresult ); return nil end
        end
        local libsubtable = require( libenvpath )
        rawset( libenv, libpathpart, libsubtable )
        libenv = libsubtable
      elseif not libenvmods then libenv = libenv[libpathpart]
      else libenv = nil end
    end

    return libenv
  end

  return setmetatable( lib, libmt )
end

return util
