local assert = require( "luassert" )
local say = require( "say" )

local function equaly( state, arguments )
  local expectednumber = arguments[1]; local actualnumber = arguments[2]
  local epsilon = arguments[3] or 1e-7

  return math.abs( expectednumber - actualnumber ) < epsilon
end

-- TODO(JRC): Add a flag to this function to make it possible to perform deep
-- comparisons on the lists being compared.
local function equallists( state, arguments )
  local expectedlist = arguments[1]; local actuallist = arguments[2]
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

assert:register( "assertion", "equaly", equaly,
  "assertion.are.equaly", "assertion.are_not.equaly" )
assert:register( "assertion", "equallists", equallists,
  "assertion.are.equallists", "assertion.are_not.equallists" )
