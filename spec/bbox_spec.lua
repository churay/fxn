require( 'bustedext' )
local bbox_t = require( 'fxn.bbox_t' )
local vector_t = require( 'fxn.vector_t' )

describe( 'bbox_t', function()
  --[[ Testing Constants ]]--

  local TEST_BBOX_POS = vector_t( 1, 2 )
  local TEST_BBOX_DIM = vector_t( 3, 4 )

  --[[ Testing Variables ]]--

  local testbbox = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testbbox = bbox_t( TEST_BBOX_POS, TEST_BBOX_DIM )
  end )

  --[[ Testing Functions ]]--

  describe( 'constructor', function()
    it( 'generates an empty box at the origin when given no parameters', function()
      local emptybox = bbox_t()
      assert.are.same( vector_t(), emptybox.pos )
      assert.are.same( vector_t(), emptybox.dim )
    end )

    it( 'creates a box with the given position and dimension vectors if ' ..
        'two parameters are given', function()
      local vectorbox = bbox_t( TEST_BBOX_POS, TEST_BBOX_DIM )
      assert.are.same( TEST_BBOX_POS, vectorbox.pos )
      assert.are.same( TEST_BBOX_DIM, vectorbox.dim )
    end )

    it( 'creates a box with the given x position, y position, width, and ' ..
        'height if four parameters are given', function()
      local fullbox = bbox_t(
        TEST_BBOX_POS.x, TEST_BBOX_POS.y,
        TEST_BBOX_DIM.x, TEST_BBOX_DIM.y )
      assert.are.same( TEST_BBOX_POS, fullbox.pos )
      assert.are.same( TEST_BBOX_DIM, fullbox.dim )
    end )
  end )

  --[[
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
  --]]
end )
