require( 'bustedext' )
local bbox_t = require( 'fxn.bbox_t' )
local vector_t = require( 'fxn.vector_t' )

describe( 'bbox_t', function()
  --[[ Testing Constants ]]--

  local TEST_BBOX_POS = vector_t( 1, 2 )
  local TEST_BBOX_DIM = vector_t( 3, 4 )

  --[[ Testing Variables ]]--

  local testbbox = nil
  local unitbbox = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testbbox = bbox_t( TEST_BBOX_POS, TEST_BBOX_DIM )
    unitbbox = bbox_t( 0, 0, 1, 1 )
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

  describe( 'intersect', function()
    it( 'returns nil for a given disjoint box', function()
      local emptybbox = bbox_t()
      assert.falsy( testbbox:intersect(emptybbox) )
      assert.falsy( emptybbox:intersect(testbbox) )

      local disjointbbox = bbox_t( 10, 20, 30, 40 )
      assert.falsy( testbbox:intersect(disjointbbox) )
      assert.falsy( disjointbbox:intersect(testbbox) )
    end )

    it( 'returns the intersection volume for a given embedded box', function()
      local halfbbox = bbox_t( 0.25, 0.25, 0.75, 0.75 )

      for oidx = 1, 2 do
        local resultbbox = oidx == 1 and unitbbox:intersect( halfbbox ) or
          halfbbox:intersect( unitbbox )
        assert.are.same( halfbbox.pos, resultbbox.pos )
        assert.are.same( halfbbox.dim, resultbbox.dim )
      end
    end )

    it( 'returns the intersection volume for a given overlapping box', function()
      local otherbbox = bbox_t( 0.8, 0.9, 1.5, 1.2 )
      local expectedbbox = bbox_t( 0.8, 0.9, 0.2, 0.1 )

      for oidx = 1, 2 do
        local resultbbox = oidx == 1 and unitbbox:intersect( otherbbox ) or
          otherbbox:intersect( unitbbox )
        assert.are.same( expectedbbox.pos, resultbbox.pos )
        assert.are.same( expectedbbox.dim, resultbbox.dim )
      end
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
