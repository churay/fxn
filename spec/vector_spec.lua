require( 'bustedext' )
local vector_t = require( 'fxn.vector' )

describe( 'vector', function()
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

  it( 'initializes its component values to arguments in (x, y) order', function()
    assert.are.equal( TEST_VECTOR_X, testvector.x )
    assert.are.equal( TEST_VECTOR_Y, testvector.y )
  end )

  it( 'supports vector addition', function()
    local addvector = testvector + testvector

    assert.are.equal( 2*TEST_VECTOR_X, addvector.x )
    assert.are.equal( 2*TEST_VECTOR_Y, addvector.y )
  end )

  it( 'supports vector subtraction', function()
    local subvector = testvector - testvector

    assert.are.equal( 0, subvector.x )
    assert.are.equal( 0, subvector.y )
  end )

  it( 'supports scalar multiplication', function()
    local mulscalar = 10.0

    local mulvector = mulscalar * testvector
    assert.are.equal( mulscalar*TEST_VECTOR_X, mulvector.x )
    assert.are.equal( mulscalar*TEST_VECTOR_Y, mulvector.y )

    local revmulvector = testvector * mulscalar
    assert.are.equal( mulscalar*TEST_VECTOR_X, revmulvector.x )
    assert.are.equal( mulscalar*TEST_VECTOR_Y, revmulvector.y )
  end )

  it( 'supports vector unary negation', function()
    local negvector = -testvector

    assert.are.equal( -1*TEST_VECTOR_X, negvector.x )
    assert.are.equal( -1*TEST_VECTOR_Y, negvector.y )
  end )

  it( 'supports the equality operator', function()
    local diffvector = vector_t( TEST_VECTOR_Y, TEST_VECTOR_X )
    local equivvector = vector_t( TEST_VECTOR_X, TEST_VECTOR_Y )

    assert.are.equal( testvector, testvector )
    assert.are.equal( equivvector, testvector )
    assert.are_not.equal( diffvector, testvector )
  end )

  it( 'implements the vector dot product operation', function()
    local zerodot = testvector:dot(zerovector)
    assert.are.equaly( 0, zerodot )

    local testdot = testvector:dot(testvector)
    assert.are.equaly( TEST_VECTOR_X^2 + TEST_VECTOR_Y^2, testdot )
  end )

  it( 'implements the vector magnitude operation', function()
    assert.are.equaly( 0, zerovector:magnitude() )
    assert.are.equaly( 5, testvector:magnitude() )
  end )

  it( 'implements the vector normalization operation', function()
    local normvector = testvector:normalize()
    assert.are.equaly( 3/5, normvector.x )
    assert.are.equaly( 4/5, normvector.y )

    local normvector2 = vector_t( 10, 0 ):normalize()
    assert.are.equaly( 1, normvector2.x )
    assert.are.equaly( 0, normvector2.y )
  end )

  it( 'implements the vector angle between operation', function()
    assert.are.equaly( 0, testvector:angleto(testvector) )

    assert.are.equaly( 0, vector_t(1, 0):angleto(vector_t(1, 0)) )
    assert.are.equaly( math.pi/2, vector_t(1, 0):angleto(vector_t(0, 1)) )
    assert.are.equaly( math.pi, vector_t(1, 0):angleto(vector_t(-1, 0)) )
    assert.are.equaly( math.pi/2, vector_t(1, 0):angleto(vector_t(0, -1)) )
  end )

  it( 'implements the vector projection operation', function()
    assert.are.equal( zerovector, zerovector:projonto(testvector) )
    assert.are.equal( testvector, testvector:projonto(testvector) )

    assert.are.equal( vector_t(TEST_VECTOR_X, 0), testvector:projonto(vector_t(1, 0)) )
    assert.are.equal( vector_t(0, TEST_VECTOR_Y), testvector:projonto(vector_t(0, 1)) )
  end )
end )
