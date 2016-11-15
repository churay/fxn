require( 'bustedext' )
local table_t = require( 'fxn.table_t' )

describe( 'table_t', function()
  --[[ Testing Constants ]]--

  local TEST_KEY, TEST_VALUE = 'five', 5

  local DEFAULT_NUMBER = 20
  local DEFAULT_STRING = 'twenty'

  --[[ Testing Variables ]]--

  local testdeftable = nil
  local testnumtable = nil
  local teststrtable = nil
  local testtables = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testdeftable = table_t()
    testnumtable = table_t( DEFAULT_NUMBER )
    teststrtable = table_t( DEFAULT_STRING )
    testtables = { testdeftable, testnumtable, teststrtable }

    for _, testtable in ipairs( testtables ) do
      testtable[TEST_KEY] = TEST_VALUE
    end
  end )

  --[[ Testing Functions ]]--

  it( 'functions like a normal table when setting values', function()
    for _, testtable in ipairs( testtables ) do
      assert.are.equal( TEST_VALUE, rawget(testtable, TEST_KEY) )
    end
  end )

  it( 'functions like a normal table when accessing non-nil values', function()
    for _, testtable in ipairs( testtables ) do
      assert.are.equal( TEST_VALUE, testtable[TEST_KEY] )
    end
  end )

  it( 'returns nil for nil values when no default key value is set', function()
    assert.are.equal( nil, testdeftable['emptykey'] )
  end )

  it( 'returns the default value when a default key value is set', function()
    assert.are.equal( DEFAULT_NUMBER, testnumtable['emptykey'] )
    assert.are.equal( DEFAULT_STRING, teststrtable['emptykey'] )
  end )
end )
