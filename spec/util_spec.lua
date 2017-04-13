require( 'bustedext' )
local util = require( 'util' )

describe( 'util', function()
  --[[ Testing Functions ]]--

  describe( 'pretty', function()
    before_each( function()
      
    end )

    it( '', function()
      pending( 'TODO(JRC)' )
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

  describe( 'iterstring', function()
    local function iterstringtable( ... )
      local ittable = {}
      for cidx, comp in util.iterstring( ... ) do
        table.insert( ittable, {cidx, comp} )
      end
      return ittable
    end

    it( 'returns the source string if the separator is not found', function()
      local teststrs = { 'abcde', '12345', 'hello', 'world' }
      for _, teststr in ipairs( teststrs ) do
        assert.are.same( {{1, teststr}}, iterstringtable(teststr, '@') )
      end
    end )

    it( 'returns subsequent segments of the string separated by the specified ' ..
        'separator when its in the source string and not duplicated', function()
      local teststr = 'one two three'

      assert.are.same( {{1, 'one'}, {2, 'two'}, {3, 'three'}},
        iterstringtable(teststr, ' ') )
      assert.are.same( {{1, 'one'}, {2, 'three'}},
        iterstringtable(teststr, ' two ') )
    end )

    it( 'returns empty entries when instances of the given separator are ' ..
        'adjacent in the source string', function()
      local testsep = 't'
      for sepreps = 1, 3 do
        local teststr = string.format( 'T%sT', string.rep(testsep, sepreps) )

        local expectediter = {{1, 'T'}, {sepreps + 1, 'T'}}
        for sepidx = 1, sepreps - 1 do
          table.insert( expectediter, sepidx + 1, {sepidx + 1, ''} )
        end

        assert.are.same( expectediter, iterstringtable(teststr, testsep) )
      end
    end )
  end )

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
      assert.are.equallists( {2}, util.map(shortlist, mfxn) )
      assert.are.equallists( {2, 4, 6}, util.map(longlist, mfxn) )
    end )

    it( 'returns without modifying the original input list', function()
      for _, tl in ipairs( {emptylist, shortlist, longlist} ) do util.map( tl, mfxn ) end

      assert.are.equallists( {}, emptylist )
      assert.are.equallists( {1}, shortlist )
      assert.are.equallists( {1, 2, 3}, longlist )
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
      assert.are.equallists( {1}, shortlist )
      assert.are.equallists( {1, 2, 3}, longlist )
    end )
  end )

  describe( 'lconcat', function()
    local list1 = nil
    local list2 = nil

    before_each( function()
      list1 = { 1, 2, 3 }
      list2 = { 4, 5 }
    end )

    it( 'returns the concatenation of the two lists when one or more ' ..
        'lists is empty', function()
      for ipmode = 1, 2 do
        local ip = ipmode == 1

        assert.are.equallists( {}, util.lconcat({}, {}, ip) )

        assert.are.equallists( {1, 2, 3}, util.lconcat(list1, {}, ip) )
        assert.are.equallists( {4, 5}, util.lconcat(list2, {}, ip) )

        assert.are.equallists( {1, 2, 3}, util.lconcat({}, list1, ip) )
        assert.are.equallists( {4, 5}, util.lconcat({}, list2, ip) )
      end
    end )

    it( 'returns the concatenation of the two lists when both are ' ..
        'non-empty', function()
      assert.are.equallists( {1, 2, 3, 4, 5}, util.lconcat(list1, list2) )
      assert.are.equallists( {4, 5, 1, 2, 3}, util.lconcat(list2, list1) )

      assert.are.equallists( {1, 2, 3, 4, 5}, util.lconcat(list1, list2, true) )
      assert.are.equallists( {4, 5, 1, 2, 3, 4, 5}, util.lconcat(list2, list1, true) )
    end )

    it( 'returns a new list when not running in-place (default)', function()
      local listconcat = util.lconcat( list1, list2 )
      assert.are_not.equal( list1, listconcat )
      assert.are_not.equal( list2, listconcat )
    end )

    it( 'modifies and returns the first list when running in-place', function()
      assert.are.equal( list1, util.lconcat(list1, list2, true) )
      assert.are.equal( list2, util.lconcat(list2, list1, true) )
    end )
  end )

  describe( 'lmatches', function()
    local testlist = nil

    before_each( function()
      testlist = { 1, 2, 5, 3, 1, 4, 5, 1 }
    end )

    it( 'returns the false if there are no matches', function()
      assert.are.equal( false, util.lmatches(testlist, 0) )
      assert.are.equal( false, util.lmatches(testlist, 6) )
      assert.are.equal( false, util.lmatches(testlist, '1') )
    end )

    it( 'returns the correct number of matches if there are one or more', function()
      assert.are.equal( 3, util.lmatches(testlist, 1) )
      assert.are.equal( 2, util.lmatches(testlist, 5) )
      for _, v in ipairs( {2, 3, 4} ) do
        assert.are.equal( 1, util.lmatches(testlist, v) )
      end
    end )
  end )

  describe( 'lsub', function()
    local testlist = nil

    before_each( function()
      testlist = { 1, 2, 5, 3, 1, 4, 5, 1 }
    end )

    it( 'does not modify tables that do not contain the remove value', function()
      local testlistorig = { 1, 2, 5, 3, 1, 4, 5, 1 }

      util.lsub( testlist, 6 )
      assert.are.equallists( testlistorig, testlist )

      util.lsub( testlist, '1' )
      assert.are.equallists( testlistorig, testlist )
    end )

    it( 'removes the last instance matching the value from the list when the remove ' ..
        'all option is disabled', function()
      util.lsub( testlist, 1 )
      assert.are.equallists( {1, 2, 5, 3, 1, 4, 5}, testlist )
      util.lsub( testlist, 1, false )
      assert.are.equallists( {1, 2, 5, 3, 4, 5}, testlist )

      util.lsub( testlist, 5 )
      assert.are.equallists( {1, 2, 5, 3, 4}, testlist )
      util.lsub( testlist, 5, false )
      assert.are.equallists( {1, 2, 3, 4}, testlist )
    end )

    it( 'removes each instance matching the value from the list when the remove ' ..
        'all option is enabled', function()
      util.lsub( testlist, 1, true )
      assert.are.equallists( {2, 5, 3, 4, 5}, testlist )

      util.lsub( testlist, 5, true )
      assert.are.equallists( {2, 3, 4}, testlist )
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

  describe( 'libload', function()
    local LUA_OVERFXNS = { 'require', 'io.popen', 'os.execute' }

    local testlib, testlibitems = false, false
    local testsrcfxns, testoverfxns = false, false

    -- TODO(JRC): This stubbing code will need to change in the future if/when
    -- the implementation of 'util.libload' changes.
    before_each( function()
      testlib = {}
      testlibitems = { ['a']=true, ['b']=true, ['m']=false }
      testsrcfxns, testoverfxns = {}, {}

      -- require: works like normal unless a library item is loaded,
      -- which causes a default value to be returned
      local luarequire = _G.require
      testoverfxns['require'] = function( modname )
        if testlibitems[modname] ~= nil then return modname
        else return luarequire( modname ) end
      end
      -- spy.on( testoverfxns, 'require' )

      -- io.popen: return a table that has a lines/close methods
      testoverfxns['io.popen'] = function()
        local libpaths = { ['.']=true, ['..']=true }
        for itemname, itemtype in pairs( testlibitems ) do
          local itempath = string.format( '%s%s', itemname,
            itemtype and '.lua' or '' )
          libpaths[itempath] = true
        end

        return {
          lines=function() return next, libpaths, nil end,
          close=function() end
        }
      end

      -- os.execute: return a 0/1 based on type of library item
      testoverfxns['os.execute'] = function( cmd )
        local itemname = string.match( cmd, ' ([^ ]*)$' )
        return testlibitems[itemname] and 1 or 0
      end

      for _, overfxn in ipairs( LUA_OVERFXNS ) do
        local fxnnameidx = string.find( overfxn, '%.[^%.]*$' )
        local fxnpath, fxnname = '', overfxn
        if fxnnameidx ~= nil then
          fxnpath = string.sub( overfxn, 1, fxnnameidx )
          fxnname = string.sub( overfxn, fxnnameidx + 1 )
        end

        local fxnenv = _G
        for _, fxncomp in util.iterstring( fxnpath, '%.' ) do
          fxnenv = fxnenv[fxncomp]
        end

        testsrcfxns[overfxn] = fxnenv[fxnname]
        fxnenv[fxnname] = testoverfxns[overfxn]
      end
    end )

    after_each( function()
      for _, overfxn in ipairs( LUA_OVERFXNS ) do
        local fxnnameidx = string.find( overfxn, '%.[^%.]*$' )
        local fxnpath, fxnname = '', overfxn
        if fxnnameidx ~= nil then
          fxnpath = string.sub( overfxn, 1, fxnnameidx )
          fxnname = string.sub( overfxn, fxnnameidx + 1 )
        end

        local fxnenv = _G
        for _, fxncomp in util.iterstring( fxnpath, '%.' ) do
          fxnenv = fxnenv[fxncomp]
        end

        fxnenv[fxnname] = testsrcfxns[overfxn]
      end
    end )

    it( 'returns a module table with no content loaded initially', function()
      testlib = util.libload( 'test' )
      for testlibitem in pairs( testlibitems ) do
        assert.are.equal( nil, rawget(testlib, testlibitem) )
      end
    end )

    it( 'loads modules on demand when they are accessed from the ' ..
        'base library module', function()
      pending( 'TODO(JRC)' )

      testlib = util.libload( 'test' )
      for testlibitem in pairs( testlibitems ) do
        local testlibmod = testlib[testlibitem]
        assert.stub( testoverfxns['require'] ).was.called_with( testlibitem )
      end

      local testnonlibitems = { 'x', 'y' }
      for testnonlibitem in pairs( nontestlibitem ) do
        local testlibmod = testlib[testlibitem]
        assert.stub( testoverfxns['require'] ).was_not.called_with( testnonlibitem )
      end
    end )

    it( 'properly resolves and loads modules on demand for nested ' ..
        'accesses (e.g. lib.x.y.z)', function()
      pending( 'TODO(JRC)' )
    end )
  end )
end )
