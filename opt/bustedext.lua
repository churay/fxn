local assert = require( 'luassert' )
local say = require( 'say' )

local function equaly( state, arguments )
  local expectednumber, actualnumber = arguments[1], arguments[2]
  local epsilon = arguments[3] or 1e-7

  return math.abs( expectednumber - actualnumber ) < epsilon
end

local function equalsets( state, arguments )
  local expectedset, actualset = arguments[1], arguments[2]
  local comparefxn = arguments[3] == nil and
    function(a, b) return a == b end or arguments[3]

  local tempset = {}
  for k, v in ipairs( actualset ) do tempset[k] = v end

  for expectedkey, expectedvalue in ipairs( expectedset ) do
    local expectedexists = false
    for actualkey, actualvalue in ipairs( tempset ) do
      if comparefxn( expectedvalue, actualvalue ) and not expectedexists then
        expectedexists = true
        table.remove( tempset, actualkey )
        break
      end
    end
    if not expectedexists then return false end
  end

  return #expectedset == #actualset
end

local function equallists( state, arguments )
  local expectedlist, actuallist = arguments[1], arguments[2]
  local comparefxn = arguments[3] == nil and
    function(a, b) return a == b end or arguments[3]

  for expectedkey, expectedvalue in ipairs( expectedlist ) do
    local actualvalue = actuallist[expectedkey]
    if not comparefxn( expectedvalue, actualvalue ) then return false end
  end

  return #expectedlist == #actuallist
end

local function equaltables( state, arguments )
  local expectedtable, actualtable = arguments[1], arguments[2]

  if type( expectedtable ) ~= type( actualtable ) then
    return false
  elseif type( expectedtable ) ~= 'table' then
    return expectedtable == actualtable
  else
    if expectedtable ~= actualtable then return false end

    for kexpected, vexpected in pairs( expectedtable ) do
      local kactual = nil
      for ka, va in pairs( actualtable ) do
        kactual = kexpected == ka and ka or kactual
      end

      local keysequal = kactual and equaltables( state, kexpected, kactual )
      local valuesequal = keysequal and
        equaltables( state, expectedtable[kexpected], actualtable[kactual] )

      if not keysequal or not valuesequal then return false end
    end

    local expectedlen, actuallen = 0, 0
    for _ in pairs( expectedtable ) do expectedlen = expectedlen + 1 end
    for _ in pairs( actualtable ) do actuallen = actuallen + 1 end

    return expectedlen == actuallen
  end
end

say:set_namespace( 'en' )

say:set( 'assertion.are.equaly',
  'Expected numbers to be nearly equal.\n' ..
  'Expected:\n%s\nPassed In:\n%s\nEpsilon:\n%s' )
say:set( 'assertion.are_not.equaly',
  'Expected numbers to be sufficiently different.\n' ..
  'Expected:\n%s\nPassed In:\n%s\nEpsilon:\n%s' )

say:set( 'assertion.are.equalsets',
  'Expected lists to be contain the same elements in any order.\n' ..
  'Expected:\n%s\nPassed In:\n%s' )
say:set( 'assertion.are_not.equalsets',
  'Expected lists to contain at least one differing element.\n' ..
  'Expected:\n%s\nPassed In:\n%s' )

say:set( 'assertion.are.equallists',
  'Expected lists to be contain the same elements in the same order.\n' ..
  'Expected:\n%s\nPassed In:\n%s' )
say:set( 'assertion.are_not.equallists',
  'Expected lists to contain at least one differing element.\n' ..
  'Expected:\n%s\nPassed In:\n%s' )

say:set( 'assertion.are.equaltables',
  'Expected tables to be contain the same key/value pairs.\n' ..
  'Expected:\n%s\nPassed In:\n%s' )
say:set( 'assertion.are_not.equaltables',
  'Expected tables to contain at least one key/value pair.\n' ..
  'Expected:\n%s\nPassed In:\n%s' )

assert:register( 'assertion', 'equaly', equaly,
  'assertion.are.equaly', 'assertion.are_not.equaly' )
assert:register( 'assertion', 'equalsets', equalsets,
  'assertion.are.equalsets', 'assertion.are_not.equalsets' )
assert:register( 'assertion', 'equallists', equallists,
  'assertion.are.equallists', 'assertion.are_not.equallists' )
assert:register( 'assertion', 'equaltables', equaltables,
  'assertion.are.equaltables', 'assertion.are_not.equaltables' )
