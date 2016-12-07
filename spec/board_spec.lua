require( 'bustedext' )
local board_t = require( 'fxn.board_t' )

describe( 'board_t', function()
  --[[ Testing Constants ]]--

  local BOARD_DIMS = { 3, 3 }

  --[[ Testing Variables ]]--

  local testboard = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
      --[[
      --  Test Board Diagram
      --
      --  O----------------> X
      --  |     1   2   3
      --  |   |---+---+---|
      --  | 1 | 1 | 2 | 3 |
      --  |   |---+---+---|
      --  | 2 | 4 | 5 | 6 |
      --  |   |---+---+---|
      --  | 3 | 7 | 8 | 9 |
      --  |   |---+---+---|
      --  V
      --
      --  Y
      --]]
    testboard = board_t( BOARD_DIMS[1], BOARD_DIMS[2] )
  end )

  --[[ Testing Functions ]]--

  describe( 'constructor', function()
    it( 'properly initializes the width and height of the board', function()
      assert.are.equal( BOARD_DIMS[1], testboard.width )
      assert.are.equal( BOARD_DIMS[1], testboard.height )
    end )

    it( 'properly initializes cell contents of the board', function()
      assert.are.equal( BOARD_DIMS[1]*BOARD_DIMS[2], #testboard._cells )

      for cellidx = 1, #testboard._cells do
        assert.are.equal( false, testboard._cells[cellidx] )
      end
    end )

    it( 'properly initializes the underlying graph for the board', function()
      local boardcells = testboard._graph:querynodes()
      assert.are.equal( BOARD_DIMS[1]*BOARD_DIMS[2], #boardcells )

      for _, boardcell in ipairs( boardcells ) do
        local cellidx = boardcell:getlabel()
        local cellx, celly = testboard:_getcellpos( cellidx )

        local expectedouts = {}
        if cellx > 1 then
          expectedouts['-x'] = testboard:_getcellidx(cellx-1, celly)
        end if cellx < BOARD_DIMS[1] then
          expectedouts['+x'] = testboard:_getcellidx(cellx+1, celly)
        end if celly > 1 then
          expectedouts['-y'] = testboard:_getcellidx(cellx, celly-1)
        end if celly < BOARD_DIMS[2] then
          expectedouts['+y'] = testboard:_getcellidx(cellx, celly+1)
        end

        local actualouts = {}
        for _, outedge in ipairs( boardcell:getoutedges() ) do
          actualouts[outedge:getlabel()] = outedge:getdst():getlabel()
        end

        assert.are.same( expectedouts, actualouts )
      end
    end )
  end )

  describe( 'movement calculation', function()
    it( 'works', function()
      pending( 'TODO(JRC)' )
    end )
  end )

end )
