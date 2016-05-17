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

-- TODO(JRC): This function currently only supports Unix operating systems and
-- should be expanded to support Windows systems.
function util.ls( d )
  local items = {}
  local pitems = io.popen( 'ls -la ' .. d )
  for item in pitems:lines() do table.insert( items, item ) end
  return items
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
