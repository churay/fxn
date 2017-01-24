require( 'bustedext' )
local %TYPE%_t = require( 'fxn.%TYPE%_t' )

describe( '%TYPE%_t', function()
  --[[ Testing Constants ]]--

  local TEST_CONSTANT = nil

  --[[ Testing Variables ]]--

  local test%TYPE% = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    test%TYPE% = nil
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
