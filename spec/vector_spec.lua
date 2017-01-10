require( 'bustedext' )
local vector_t = require( 'fxn.vector_t' )

describe( 'vector_t', function()
  --[[ Testing Constants ]]--

  local TEST_VECTOR_X = 3
  local TEST_VECTOR_Y = 4

  --[[ Testing Variables ]]--

  local testvector = nil
  local zerovector = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testvector = vector_t( TEST_VECTOR_X, TEST_VECTOR_Y )
    zerovector = vector_t( 0, 0 )
  end )

  --[[ Testing Functions ]]--

  describe( 'constructor', function()
    it( 'initializes component values to arguments in (x, y) order', function()
      assert.are.equal( TEST_VECTOR_X, testvector.x )
      assert.are.equal( TEST_VECTOR_Y, testvector.y )
    end )
  end )

  describe( 'eq', function()
    it( 'properly returns true for identical vectors', function()
      local samevector = vector_t( TEST_VECTOR_X, TEST_VECTOR_Y )

      assert.are.equal( testvector, testvector )
      assert.are.equal( samevector, samevector )

      assert.are.equal( testvector, samevector )
      assert.are.equal( samevector, testvector )
    end )

    it( 'properly returns true for vectors with differences', function()
      local diffvector = vector_t( TEST_VECTOR_X + 1, TEST_VECTOR_Y )

      assert.are_not.equal( testvector, zerovector )
      assert.are_not.equal( testvector, diffvector )

      assert.are_not.equal( zerovector, testvector )
      assert.are_not.equal( diffvector, testvector )
    end )
  end )

  describe( 'add', function()
    local testdoublevector = nil

    before_each( function()
      testdoublevector = vector_t( 2 * TEST_VECTOR_X, 2 * TEST_VECTOR_Y )
    end )

    it( 'can be performed through the + operator', function()
      assert.are.equal( testvector, testvector + zerovector )
      assert.are.equal( testvector, zerovector + testvector )

      assert.are.equal( testdoublevector, testvector + testvector )
    end )

    it( 'can be performed in-place', function()
      testvector:addip( testvector )
      assert.are.equal( testdoublevector, testvector )
    end )
  end )

  describe( 'sub', function()
    local testnegvector = nil

    before_each( function()
      testnegvector = vector_t( -1 * TEST_VECTOR_X, -1 * TEST_VECTOR_Y )
    end )

    it( 'can be performed through the - operator', function()
      assert.are.equal( testvector, testvector - zerovector )
      assert.are.equal( zerovector, testvector - testvector )

      assert.are.equal( testnegvector, zerovector - testvector )
    end )

    it( 'can be performed in-place', function()
      testvector:subip( testvector )
      assert.are.equal( zerovector, testvector )
    end )
  end )

  describe( 'mul', function()
    local testquadvector = nil

    before_each( function()
      testquadvector = vector_t( 4 * TEST_VECTOR_X, 4 * TEST_VECTOR_Y )
    end )

    it( 'can be performed through the * operator', function()
      assert.are.equal( testvector, 1 * testvector )
      assert.are.equal( zerovector, 0 * testvector )
      assert.are.equal( testquadvector, 4 * testvector )

      assert.are.equal( testvector, testvector * 1 )
      assert.are.equal( zerovector, testvector * 0 )
      assert.are.equal( testquadvector, testvector * 4 )
    end )

    it( 'can be performed in-place', function()
      testvector:mulip( 4 )
      assert.are.equal( testquadvector, testvector )
    end )
  end )

  describe( 'unm', function()
    local testinvvector = nil

    before_each( function()
      testinvvector = vector_t( -1 * TEST_VECTOR_X, -1 * TEST_VECTOR_Y )
    end )

    it( 'can be performed through the unary - operator', function()
      assert.are.equal( zerovector, -zerovector )
      assert.are.equal( testinvvector, -testvector )
    end )

    it( 'can be performed in-place', function()
      testvector:unmip()
      assert.are.equal( testinvvector, testvector )
    end )
  end )

  describe( 'dot', function()
    it( 'properly calculates the dot product of two vectors', function()
      assert.are.equaly( 0, testvector:dot(zerovector) )
      assert.are.equaly( 0, zerovector:dot(testvector) )

      local testdot = testvector:dot( testvector )
      assert.are.equaly( TEST_VECTOR_X^2 + TEST_VECTOR_Y^2, testdot )
    end )
  end )

  describe( 'magnitude', function()
    it( 'properly calculates the instance vector magnitude', function()
      assert.are.equaly( 0, zerovector:magnitude() )
      assert.are.equaly( 5, testvector:magnitude() )
    end )
  end )

  describe( 'norm', function()
    it( 'properly calculates the normalization of the instance vector', function()
      local normvector = testvector:norm()
      assert.are.equaly( 3/5, normvector.x )
      assert.are.equaly( 4/5, normvector.y )

      local normvector2 = vector_t( 10, 0 ):norm()
      assert.are.equaly( 1, normvector2.x )
      assert.are.equaly( 0, normvector2.y )
    end )

    it( 'can be performed in-place', function()
      testvector:normip()
      assert.are.equaly( 3/5, testvector.x )
      assert.are.equaly( 4/5, testvector.y )
    end )
  end )

  describe( 'angleto', function()
    it( 'properly calculates the angle between two vectors', function()
      assert.are.equaly( 0, testvector:angleto(testvector) )

      assert.are.equaly( 0, vector_t(1, 0):angleto(vector_t(1, 0)) )
      assert.are.equaly( math.pi/2, vector_t(1, 0):angleto(vector_t(0, 1)) )
      assert.are.equaly( math.pi, vector_t(1, 0):angleto(vector_t(-1, 0)) )
      assert.are.equaly( math.pi/2, vector_t(1, 0):angleto(vector_t(0, -1)) )
    end )
  end )

  describe( 'project', function()
    local xunitvector = nil
    local yunitvector = nil

    before_each( function()
      xunitvector = vector_t( 1.0, 0.0 )
      yunitvector = vector_t( 0.0, 1.0 )
    end )

    it( 'properly calculates the projection of the first vector onto the ' ..
        'second', function()
      assert.are.equal( zerovector, zerovector:project(testvector) )
      assert.are.equal( testvector, testvector:project(testvector) )

      assert.are.equal( vector_t(TEST_VECTOR_X, 0), testvector:project(xunitvector) )
      assert.are.equal( vector_t(0, TEST_VECTOR_Y), testvector:project(yunitvector) )
    end )

    it( 'can be performed in-place', function()
      testvector:projectip( xunitvector )
      assert.are.equal( vector_t(TEST_VECTOR_X, 0), testvector )

      testvector:projectip( yunitvector )
      assert.are.equal( zerovector, testvector )
    end )
  end )
end )
