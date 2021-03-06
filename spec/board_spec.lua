require( 'bustedext' )
local board_t = require( 'fxn.board_t' )

describe( 'board_t', function()
  --[[ Testing Constants ]]--

  local BOARD_DIMS = { 5, 5 }

  --[[ Testing Variables ]]--

  local testboard = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
      --[[
      --  Test Board Diagram
      --
      --  Y
      --  ^
      --  |   |---+---+---+---+---|
      --  | 5 | 21| 22| 23| 24| 25|
      --  |   |---+---+---+---+---|
      --  | 4 | 16| 17| 18| 19| 20|
      --  |   |---+---+---+---+---|
      --  | 3 | 11| 12| 13| 14| 15|
      --  |   |---+---+---+---+---|
      --  | 2 | 6 | 7 | 8 | 9 | 10|
      --  |   |---+---+---+---+---|
      --  | 1 | 1 | 2 | 3 | 4 | 5 |
      --  |   |---+---+---+---+---|
      --  |     1   2   3   4   5
      --  O------------------------>X
      --
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
      assert.are.equal( testboard.width*testboard.height, #testboard._cells )

      for cellidx = 1, #testboard._cells do
        assert.are.equal( false, testboard._cells[cellidx] )
      end
    end )

    it( 'properly initializes the underlying graph for the board', function()
      local boardcells = testboard._graph:querynodes()
      assert.are.equal( testboard.width*testboard.height, #boardcells )

      for _, boardcell in ipairs( boardcells ) do
        local cellidx = boardcell:getlabel()
        local cellx, celly = testboard:_getcellpos( cellidx )

        local expectedouts = {}
        if cellx > 1 then
          expectedouts['-x'] = testboard:_getcellidx(cellx-1, celly)
        end if cellx < testboard.width then
          expectedouts['+x'] = testboard:_getcellidx(cellx+1, celly)
        end if celly > 1 then
          expectedouts['-y'] = testboard:_getcellidx(cellx, celly-1)
        end if celly < testboard.height then
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

  describe( 'piece manipulation functionality', function()
    local testpiece = nil

    before_each( function()
      testpiece = board_t.piece_t( testboard, {}, {} )
    end )

    it( 'adds pieces to the board at the proper cells', function()
      for cellidx = 1, testboard.width * testboard.height do
        testboard:addpiece( testpiece, cellidx )
        assert.are.equal( testpiece, testboard:getpiece(cellidx) )

        for ocellidx = 1, testboard.width * testboard.height do
          assert.are.equal(
            ocellidx <= cellidx and testpiece or false,
            testboard:getpiece(ocellidx)
          )
        end
      end
    end )

    it( 'removes pieces from the board at the designated cells, returning ' ..
        'the proper occupant pieces', function()
      local testpieces = {}
      for cellidx = 1, testboard.width * testboard.height do
        table.insert( testpieces, board_t.piece_t(testboard, {}, {}) )
        testboard:addpiece( testpieces[cellidx], cellidx )
      end

      for cellidx = 1, testboard.width * testboard.height do
        assert.are.equal( testpieces[cellidx], testboard:removepiece(cellidx) )

        for ocellidx = 1, testboard.width * testboard.height do
          assert.are.equal(
            ocellidx > cellidx and testpieces[ocellidx] or false,
            testboard:getpiece(ocellidx)
          )
        end
      end
    end )
  end )

  describe( 'movement calculation', function()
    local testcellidx = nil
    local testmoves = nil

    before_each( function()
      testcellidx = testboard:_getcellidx( 2, 2 )
      testmoves = {
        stationary = {},
        up = { {'+y'} },
        upleft = { {'+y', '-x'} },
        diags = { {'+x', '+y'}, {'+x', '-y'}, {'-x', '+y'}, {'-x', '-y'} },
      }
    end )

    it( 'properly calculates no moves for missing pieces', function()
      for cellidx = 1, testboard.width * testboard.height do
        assert.are.same( {}, testboard:getpiecemoves(cellidx) )
      end
    end )

    it( 'properly calculates no moves for trivial pieces', function()
      local testpiece = board_t.piece_t( testboard, testmoves.stationary, {} )
      testboard:addpiece( testpiece, testcellidx )

      assert.are.same( {}, testboard:getpiecemoves(testcellidx) )
    end )

    it( 'properly calculates moves for single substep steps', function()
      local testpiece = board_t.piece_t( testboard, testmoves.up, {2} )

      for testcellx = 1, testboard.width do
        for testcelly = 1, testboard.height do
          local testcellidx = testboard:_getcellidx( testcellx, testcelly )

          local expectedmoves = {}
          for dy = 1, 2 do
            local expcellx, expcelly = testcellx, testcelly+dy
            if testboard:_iscellvalid( expcellx, expcelly ) then
              local expectedidx = testboard:_getcellidx( expcellx, expcelly )
              expectedmoves[expectedidx] = true
            end
          end

          testboard:addpiece( testpiece, testcellidx )
          assert.are.same( expectedmoves, testboard:getpiecemoves(testcellidx) )
          testboard:removepiece( testcellidx )
        end
      end
    end )

    it( 'properly calculates moves for multiple substep steps', function()
      local testpiece = board_t.piece_t( testboard, testmoves.upleft, {2} )

      for testcellx = 1, testboard.width do
        for testcelly = 1, testboard.height do
          local testcellidx = testboard:_getcellidx( testcellx, testcelly )

          local expectedmoves = {}
          for dxy = 1, 2 do
            local expcellx, expcelly = testcellx-dxy, testcelly+dxy
            if testboard:_iscellvalid( expcellx, expcelly ) then
              local expectedidx = testboard:_getcellidx( expcellx, expcelly )
              expectedmoves[expectedidx] = true
            end
          end

          testboard:addpiece( testpiece, testcellidx )
          assert.are.same( expectedmoves, testboard:getpiecemoves(testcellidx) )
          testboard:removepiece( testcellidx )
        end
      end
    end )

    -- TODO(JRC): Improve this test case so there are different maxs for the
    -- different step sequences.
    it( 'properly calculates moves for steps with multiple options', function()
      local testpiece = board_t.piece_t( testboard, testmoves.diags, {1,1,1,1} )

      for testcellx = 1, testboard.width do
        for testcelly = 1, testboard.height do
          local testcellidx = testboard:_getcellidx( testcellx, testcelly )

          local expectedmoves = {}
          for dx = -1, 1, 2 do
            for dy = -1, 1, 2 do
              local expcellx, expcelly = testcellx+dx, testcelly+dy
              if testboard:_iscellvalid( expcellx, expcelly ) then
                local expectedidx = testboard:_getcellidx( expcellx, expcelly )
                expectedmoves[expectedidx] = true
              end
            end
          end

          testboard:addpiece( testpiece, testcellidx )
          assert.are.same( expectedmoves, testboard:getpiecemoves(testcellidx) )
          testboard:removepiece( testcellidx )
        end
      end
    end )
  end )

end )
