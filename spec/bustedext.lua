local assert = require( "luassert" )
local say = require( "say" )

local function equaly( state, arguments )
  local expectednumber, actualnumber = arguments[1], arguments[2]
  local epsilon = arguments[3] or 1e-7

  return math.abs( expectednumber - actualnumber ) < epsilon
end

-- TODO(JRC): Add a flag to this function to make it possible to perform deep
-- comparisons on the lists being compared.
local function equallists( state, arguments )
  local expectedlist, actuallist = arguments[1], arguments[2]
  local ignoreorder = arguments[3] or true

  for expectedkey, expectedvalue in ipairs( expectedlist ) do
    local expectedexists = false

    if ignoreorder then
      for _, actualvalue in ipairs( actuallist ) do
        expectedexists = expectedexists or expectedvalue == actualvalue
      end
    else
      local actualvalue = actuallist[expectedkey]
      expectedexists = actualvalue ~= nil and expectedvalue == actualvalue
    end

    if not expectedexists then return false end
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

say:set_namespace( "en" )

say:set( "assertion.are.equaly",
  "Expected numbers to be nearly equal.\n" ..
  "Expected:\n%s\nPassed In:\n%s\nEpsilon:\n%s" )
say:set( "assertion.are_not.equaly",
  "Expected numbers to be sufficiently different.\n" ..
  "Expected:\n%s\nPassed In:\n%s\nEpsilon:\n%s" )

say:set( "assertion.are.equallists",
  "Expected lists to be contain the same elements.\n" ..
  "Expected:\n%s\nPassed In:\n%s" )
say:set( "assertion.are_not.equallists",
  "Expected lists to contain at least one differing element.\n" ..
  "Expected:\n%s\nPassed In:\n%s" )

say:set( "assertion.are.equaltables",
  "Expected tables to be contain the same key/value pairs.\n" ..
  "Expected:\n%s\nPassed In:\n%s" )
say:set( "assertion.are_not.equaltables",
  "Expected tables to contain at least one key/value pair.\n" ..
  "Expected:\n%s\nPassed In:\n%s" )

assert:register( "assertion", "equaly", equaly,
  "assertion.are.equaly", "assertion.are_not.equaly" )
assert:register( "assertion", "equallists", equallists,
  "assertion.are.equallists", "assertion.are_not.equallists" )
assert:register( "assertion", "equaltables", equaltables,
  "assertion.are.equaltables", "assertion.are_not.equaltables" )
