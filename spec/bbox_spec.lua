require( 'bustedext' )
local bbox_t = require( 'fxn.bbox_t' )
local vector_t = require( 'fxn.vector_t' )
local util = require( 'util' )

describe( 'bbox_t', function()
  --[[ Testing Constants ]]--

  local TEST_BBOX_MIN = vector_t( 1, 2 )
  local TEST_BBOX_DIM = vector_t( 3, 4 )
  local TEST_BBOX_CENTER = vector_t( 2.5, 4 )

  --[[ Testing Variables ]]--

  local testbbox = nil
  local unitbbox = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    testbbox = bbox_t( TEST_BBOX_MIN, TEST_BBOX_DIM )
    unitbbox = bbox_t( 0, 0, 1, 1 )
  end )

  --[[ Testing Functions ]]--

  describe( 'constructor', function()
    it( 'generates an empty box at the origin when given no parameters', function()
      local emptybox = bbox_t()
      local emptyvec = vector_t()
      assert.are.equal( vector_t(), emptybox.min )
      assert.are.equal( vector_t(), emptybox.max )
      assert.are.equal( vector_t(), emptybox.dim )
    end )

    it( 'creates a box with the given position and dimension vectors if ' ..
        'two parameters are given', function()
      local vectorbox = bbox_t( TEST_BBOX_MIN, TEST_BBOX_DIM )
      assert.are.equal( TEST_BBOX_MIN, vectorbox.min )
      assert.are.equal( TEST_BBOX_MIN + TEST_BBOX_DIM, vectorbox.max )
      assert.are.equal( TEST_BBOX_DIM, vectorbox.dim )
    end )

    it( 'creates a box with the given x position, y position, width, and ' ..
        'height if four parameters are given', function()
      local fullbox = bbox_t(
        TEST_BBOX_MIN.x, TEST_BBOX_MIN.y,
        TEST_BBOX_DIM.x, TEST_BBOX_DIM.y )
      assert.are.equal( TEST_BBOX_MIN, fullbox.min )
      assert.are.equal( TEST_BBOX_MIN + TEST_BBOX_DIM, fullbox.max )
      assert.are.equal( TEST_BBOX_DIM, fullbox.dim )
    end )
  end )

  describe( 'eq', function()
    it( 'properly returns true for identical bounding boxes', function()
      local samebbox = bbox_t( TEST_BBOX_MIN, TEST_BBOX_DIM )

      assert.are.equal( testbbox, testbbox )
      assert.are.equal( samebbox, samebbox )

      assert.are.equal( testbbox, samebbox )
      assert.are.equal( samebbox, testbbox )
    end )

    it( 'properly returns false for bounding boxes with differences', function()
      local diffbbox = bbox_t( TEST_BBOX_MIN + TEST_BBOX_MIN, TEST_BBOX_DIM )

      assert.are_not.equal( textbbox, unitbbox )
      assert.are_not.equal( unitbbox, testbbox )

      assert.are_not.equal( textbbox, diffbbox )
      assert.are_not.equal( diffbbox, testbbox )
    end )
  end )

  describe( 'translate', function()
    it( 'properly transforms the coordinates of the box when provided with ' ..
        'a vector argument', function()
      testbbox:translate( vector_t() )
      assert.are.equal( bbox_t(TEST_BBOX_MIN, TEST_BBOX_DIM), testbbox )

      testbbox:translate( TEST_BBOX_MIN )
      assert.are.equal( bbox_t(2*TEST_BBOX_MIN, TEST_BBOX_DIM), testbbox )
    end )

    it( 'properly transforms the coordinates of the box when provided with ' ..
        'two coordinate arguments', function()
      testbbox:translate( vector_t():xy() )
      assert.are.equal( bbox_t(TEST_BBOX_MIN, TEST_BBOX_DIM), testbbox )

      testbbox:translate( TEST_BBOX_MIN:xy() )
      assert.are.equal( bbox_t(2*TEST_BBOX_MIN, TEST_BBOX_DIM), testbbox )
    end )
  end )

  describe( 'scale', function()
    it( 'properly scales the dimensions of the box when provided with ' ..
        'a vector argument', function()
      testbbox:scale( vector_t(1, 1) )
      assert.are.equal( bbox_t(TEST_BBOX_MIN, TEST_BBOX_DIM), testbbox )

      testbbox:scale( vector_t(2, 2) )
      assert.are.equal( bbox_t(TEST_BBOX_MIN, 2*TEST_BBOX_DIM), testbbox )
    end )

    it( 'properly scales the dimensions of the box when provided with ' ..
        'two coordinate arguments', function()
      testbbox:scale( 1, 1 )
      assert.are.equal( bbox_t(TEST_BBOX_MIN, TEST_BBOX_DIM), testbbox )

      testbbox:scale( 2, 2 )
      assert.are.equal( bbox_t(TEST_BBOX_MIN, 2*TEST_BBOX_DIM), testbbox )
    end )
  end )

  describe( 'contains', function()
    local testmovevecs = nil

    before_each( function()
      testmovevecs = {}

      for movedim = 1, 2 do
        for movedir = -1, 1, 2 do
          local moved = movedim == 1 and 'x' or 'y'
          local movevec = 0.5 * movedir * testbbox.dim[moved] *
            vector_t( movedim == 1 and 1 or 0, movedim == 2 and 1 or 0 )
          table.insert( testmovevecs, movevec )
        end
      end
    end )

    it( 'returns false for given points outside the bounding box', function()
      for _, testmovevec in ipairs( testmovevecs ) do
        local testpoint = TEST_BBOX_CENTER + 1.1 * testmovevec
        assert.is_false( testbbox:contains(testpoint) )
      end
    end )

    it( 'returns true for given points inside the bounding box', function()
      for _, testmovevec in ipairs( testmovevecs ) do
        local testpoint = TEST_BBOX_CENTER + 0.9 * testmovevec
        assert.is_true( testbbox:contains(testpoint) )
      end
    end )

    it( 'returns true for given points on the bounding box boundary', function()
      for _, testmovevec in ipairs( testmovevecs ) do
        local testpoint = TEST_BBOX_CENTER + 1.0 * testmovevec
        assert.is_true( testbbox:contains(testpoint) )
      end
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
        assert.are.equal( halfbbox.min, resultbbox.min )
        assert.are.equal( halfbbox.dim, resultbbox.dim )
      end
    end )

    it( 'returns the intersection volume for a given overlapping box', function()
      local otherbbox = bbox_t( 0.8, 0.9, 1.5, 1.2 )
      local expectedbbox = bbox_t( 0.8, 0.9, 0.2, 0.1 )

      for oidx = 1, 2 do
        local resultbbox = oidx == 1 and unitbbox:intersect( otherbbox ) or
          otherbbox:intersect( unitbbox )
        assert.are.equal( expectedbbox.min, resultbbox.min )
        assert.are.equal( expectedbbox.dim, resultbbox.dim )
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
