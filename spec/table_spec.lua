require( 'bustedext' )
local table_t = require( 'fxn.table_t' )

describe( 'table_t', function()
  --[[ Testing Constants ]]--

  local TEST_KEY, TEST_VALUE = 'five', 5

  local DEFAULT_NUMBER = 20
  local DEFAULT_STRING = 'twenty'
  local DEFAULT_TABLE = {}

  --[[ Testing Variables ]]--

  local testdeftable = nil
  local testnumtable = nil
  local teststrtable = nil
  local testtbltable = nil
  local testtables = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testdeftable = table_t()
    testnumtable = table_t( DEFAULT_NUMBER )
    teststrtable = table_t( DEFAULT_STRING )
    testtbltable = table_t( DEFAULT_TABLE )
    testtables = { testdeftable, testnumtable, teststrtable, testtbltable }

    for _, testtable in ipairs( testtables ) do
      testtable[TEST_KEY] = TEST_VALUE
    end
  end )

  --[[ Testing Functions ]]--

  it( 'functions like a normal table when setting values', function()
    for _, testtable in ipairs( testtables ) do
      assert.are.same( TEST_VALUE, rawget(testtable, TEST_KEY) )
    end
  end )

  it( 'functions like a normal table when accessing non-nil values', function()
    for _, testtable in ipairs( testtables ) do
      assert.are.same( TEST_VALUE, testtable[TEST_KEY] )
    end
  end )

  it( 'returns nil for nil values when no default key value is set', function()
    assert.are.same( nil, testdeftable['emptykey'] )
  end )

  it( 'returns the default value when a default key value is set', function()
    assert.are.same( DEFAULT_NUMBER, testnumtable['emptykey'] )
    assert.are.same( DEFAULT_STRING, teststrtable['emptykey'] )
    assert.are.same( DEFAULT_TABLE, testtbltable['emptykey'] )
  end )
end )
