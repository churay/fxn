require( 'bustedext' )
local vector_t = require( 'fxn.vector' )

describe( 'vector', function()
  --[[ Testing Constants ]]--

  local TEST_VECTOR_X = 1
  local TEST_VECTOR_Y = 2

  --[[ Testing Variables ]]--

  local testvector = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testvector = vector_t( TEST_VECTOR_X, TEST_VECTOR_Y )
  end )

  after_each( function()
    testvector = nil
  end )

  --[[ Testing Functions ]]--

  it( 'constructor initializes vector components', function()
    assert.are.equal( TEST_VECTOR_X, testvector.x )
    assert.are.equal( TEST_VECTOR_Y, testvector.y )
  end )

  it( 'add operator properly adds vectors', function()
    local addvector = testvector + testvector

    assert.are.equal( 2*TEST_VECTOR_X, addvector.x )
    assert.are.equal( 2*TEST_VECTOR_Y, addvector.y )
  end )

  it( 'subtraction operator properly subtracts vectors', function()
    local subvector = testvector - testvector

    assert.are.equal( 0, subvector.x )
    assert.are.equal( 0, subvector.y )
  end )

  it( 'multiplication operator supports scalar multiplication', function()
    local mulscalar = 10.0

    local mulvector = mulscalar * testvector
    assert.are.equal( mulscalar*TEST_VECTOR_X, mulvector.x )
    assert.are.equal( mulscalar*TEST_VECTOR_Y, mulvector.y )

    local revmulvector = testvector * mulscalar
    assert.are.equal( mulscalar*TEST_VECTOR_X, revmulvector.x )
    assert.are.equal( mulscalar*TEST_VECTOR_Y, revmulvector.y )
  end )

  it( 'unary subtraction operator properly inverts vectors', function()
    local negvector = -testvector

    assert.are.equal( -1*TEST_VECTOR_X, negvector.x )
    assert.are.equal( -1*TEST_VECTOR_Y, negvector.y )
  end )

  it( 'equality operator only returns true for like vectors', function()
    local diffvector = vector_t( TEST_VECTOR_Y, TEST_VECTOR_X )
    local equivvector = vector_t( TEST_VECTOR_X, TEST_VECTOR_Y )

    assert.are.equal( testvector, testvector )
    assert.are.equal( equivvector, testvector )
    assert.are_not.equal( diffvector, testvector )
  end )

  it( 'angle operator returns the proper angle between vectors', function()
    assert.are.equaly( 0, testvector:angleto(testvector) )
    assert.are.equaly( math.pi/2, vector_t(1, 0):angleto(vector_t(0, 1)) )
    assert.are.equaly( math.pi, vector_t(1, 0):angleto(vector_t(-1, 0)) )
    assert.are.equaly( math.pi/2, vector_t(1, 0):angleto(vector_t(0, -1)) )
  end )

  it( 'normalize properly turns vector to a unit equivalent', function()
    local hugevector = vector_t( 10, 0 )
    hugevector:normalize()
    assert.are.equal( 1, hugevector.x )
    assert.are.equal( 0, hugevector.y )
    assert.are.equal( 1, hugevector:magnitude() )

    local enormousvector = vector_t( 300, 300 )
    enormousvector:normalize()
    assert.are.equaly( math.sqrt(2)/2, enormousvector.x )
    assert.are.equaly( math.sqrt(2)/2, enormousvector.y )
    assert.are.equaly( 1, enormousvector:magnitude() )
  end )
end )
