require( 'bustedext' )
local util = require( 'fxn.util' )
local dbg = require( 'debugger' )

describe( 'util', function()
  --[[ Testing Functions ]]--

  -- Mathematical Functions --

  describe( 'inrange', function()
    local stdmin, stdmax = nil, nil
    local strsmin, strsmax = nil, nil

    before_each( function()
      stdmin, stdmax = 0.0, 10.0
      strsmin, strsmax = -1.0e-6, 1.0e-6
    end )

    it( 'returns true for values inclusive to the range', function()
      assert.is_true( util.inrange((stdmax + stdmin) / 2.0, stdmin, stdmax) )
      assert.is_true( util.inrange((strsmax + strsmin) / 2.0, strsmin, strsmax) )
    end )

    it( 'returns the proper bool for values at the range minimum', function()
      assert.is_true( util.inrange(stdmin, stdmin, stdmax, false) )
      assert.is_not_true( util.inrange(stdmin, stdmin, stdmax, true) )

      assert.is_true( util.inrange(strsmin, strsmin, strsmax, false) )
      assert.is_not_true( util.inrange(strsmin, strsmin, strsmax, true) )
    end )

    it( 'returns the proper bool for values at the range maximum', function()
      assert.is_true( util.inrange(stdmax, stdmin, stdmax, false) )
      assert.is_not_true( util.inrange(stdmax, stdmin, stdmax, true) )

      assert.is_true( util.inrange(strsmax, strsmin, strsmax, false) )
      assert.is_not_true( util.inrange(strsmax, strsmin, strsmax, true) )
    end )
  end )

  describe( 'clamp', function()
    local stdmin, stdmax = nil, nil
    local strsmin, strsmax = nil, nil

    before_each( function()
      stdmin, stdmax = 0.0, 10.0
      strsmin, strsmax = -1.0e-6, 1.0e-6
    end )

    it( 'returns the same value for values inclusive to the range', function()
      assert.are.equal( 1.0, util.clamp(1.0, stdmin, stdmax) )
      assert.are.equal( 9.0, util.clamp(9.0, stdmin, stdmax) )

      assert.are.equal( -5.0e-7, util.clamp(-5.0e-7, strsmin, strsmax) )
      assert.are.equal( 5.0e-7, util.clamp(5.0e-7, strsmin, strsmax) )
    end )

    it( 'returns the range maximum for inputs above the maximum', function()
      assert.are.equal( stdmax, util.clamp(stdmax, stdmin, stdmax) )
      assert.are.equal( stdmax, util.clamp(stdmax + 1.0e-6, stdmin, stdmax) )
      assert.are.equal( stdmax, util.clamp(stdmax + 1.0e6, stdmin, stdmax) )

      assert.are.equal( strsmax, util.clamp(strsmax, strsmin, strsmax) )
      assert.are.equal( strsmax, util.clamp(strsmax + 1.0e-6, strsmin, strsmax) )
      assert.are.equal( strsmax, util.clamp(strsmax + 1.0e6, strsmin, strsmax) )
    end )

    it( 'returns the range minimum for inputs below the minimum', function()
      assert.are.equal( stdmin, util.clamp(stdmin, stdmin, stdmax) )
      assert.are.equal( stdmin, util.clamp(stdmin - 1.0e-6, stdmin, stdmax) )
      assert.are.equal( stdmin, util.clamp(stdmin - 1.0e6, stdmin, stdmax) )

      assert.are.equal( strsmin, util.clamp(strsmin, strsmin, strsmax) )
      assert.are.equal( strsmin, util.clamp(strsmin - 1.0e-6, strsmin, strsmax) )
      assert.are.equal( strsmin, util.clamp(strsmin - 1.0e6, strsmin, strsmax) )
    end )
  end )

  -- Lua Language Functions --

  describe( 'map', function()
    local emptylist = nil
    local shortlist = nil
    local longlist = nil
    local mfxn = nil

    before_each( function()
      emptylist = {}
      shortlist = { 1 }
      longlist = { 1, 2, 3 }
      mfxn = function( v ) return 2 * v end
    end )

    it( 'returns a list where each list value is xformed by the input function', function()
      assert.are.equallists( {}, util.map(emptylist, mfxn) )
      assert.are.equallists( { 2 }, util.map(shortlist, mfxn) )
      assert.are.equallists( { 2, 4, 6 }, util.map(longlist, mfxn) )
    end )

    it( 'returns without modifying the original input list', function()
      for _, tl in ipairs( {emptylist, shortlist, longlist} ) do util.map( tl, mfxn ) end

      assert.are.equallists( {}, emptylist )
      assert.are.equallists( { 1 }, shortlist )
      assert.are.equallists( { 1, 2, 3 }, longlist )
    end )
  end )

  describe( 'reduce', function()
    local emptylist = nil
    local shortlist = nil
    local longlist = nil
    local rfxn = nil

    before_each( function()
      emptylist = {}
      shortlist = { 1 }
      longlist = { 1, 2, 3 }
      rfxn = function( av, nv ) return av + nv end
    end )

    it( 'returns the reduced value achieved by accumulating all list values with ' ..
        'the input function', function()
      assert.are.equal( nil, util.reduce(emptylist, rfxn) )
      assert.are.equal( 1, util.reduce(shortlist, rfxn) )
      assert.are.equal( 6, util.reduce(longlist, rfxn) )
    end )

    it( 'returns the reduced value achieved by accumulating all list values with ' ..
        'the input function offset by the given initial value', function()
      local roff = 14
      assert.are.equal( roff, util.reduce(emptylist, rfxn, roff) )
      assert.are.equal( 1 + roff, util.reduce(shortlist, rfxn, roff) )
      assert.are.equal( 6 + roff, util.reduce(longlist, rfxn, roff) )
    end )

    it( 'returns without modifying the original input list', function()
      for _, tl in ipairs( {emptylist, shortlist, longlist} ) do util.reduce( tl, rfxn ) end

      assert.are.equallists( {}, emptylist )
      assert.are.equallists( { 1 }, shortlist )
      assert.are.equallists( { 1, 2, 3 }, longlist )
    end )
  end )

  describe( 'len', function()
    it( 'returns 0 for empty lists', function()
      assert.are.equal( 0, util.len({}) )
    end )

    it( 'returns the length for non-empty lists', function()
      assert.are.equal( 1, util.len({1}) )
      assert.are.equal( 1, util.len({one=1}) )
      assert.are.equal( 3, util.len({1, 2, 3}) )
      assert.are.equal( 3, util.len({one=1, two=2, three=3}) )
    end )
  end )

  describe( 'copy', function()
    it( 'can create independent copies of non-table types', function()
      local teststr = 'test'
      local copystr = util.copy( teststr )
      assert.are.equal( teststr, copystr )

      local testfxn = function() return 'test' end
      local copyfxn = util.copy( testfxn )
      assert.are.equal( testfxn, copyfxn )
    end )

    it( 'can create independent copies of shallow (depth 1) tables', function()
      local shallowtable = { 300, 'test', false, function() return 1.0 end }
      local copytable = util.copy( shallowtable )
      assert.are.same( shallowtable, copytable )
      assert.are_not.equal( shallowtable, copytable )
    end )

    it( 'can create independent copies of deep tables', function()
      local deeptable = { 'test', {300, false}, {true, {13.37, 'leet'}, 'more'} }
      local copytable = util.copy( deeptable )
      assert.are.same( deeptable, copytable )
      assert.are_not.equal( deeptable, copytable )
    end )

    it( 'can create independent copies of tables that have metatables', function()
      pending( 'TODO(JRC)' )
    end )

    it( 'can create independent copies of tables that have memory cycles', function()
      pending( 'TODO(JRC)' )
    end )
  end )
end )
