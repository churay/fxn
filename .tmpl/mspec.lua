require( 'bustedext' )
local %TYPE% = require( 'fxn.%TYPE%' )

describe( '%TYPE%', function()
  --[[ Testing Constants ]]--

  local TEST_CONSTANT = nil

  --[[ Testing Variables ]]--

  local testobj = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testobj = nil
  end )

  --[[ Testing Functions ]]--

  describe( 'function', function()
    local testvalue = nil

    before_each( function()
      testvalue = nil
    end )

    it( 'exhibits some behavior', function()
      local expected, actual = true, false
      assert.are.equal( expected, actual )
    end )
  end )
end )
