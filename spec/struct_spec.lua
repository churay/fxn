local struct = require( 'fxn.struct' )

describe( 'struct', function()
  --[[ Testing Constants ]]--

  local BASE_VAL = 1
  local OVER_VAL = 2

  local BASE_NAME = 'base'
  local OVER_NAME = 'over'

  local BASE_TABLE = { BASE_VAL, BASE_NAME }
  local OVER_TABLE = { OVER_VAL, OVER_NAME }

  --[[ Testing Variables ]]--

  local base_t = nil
  local over_t = nil

  local baseobj = nil
  local overobj = nil

  --[[ Testing Helper Functions ]]--

  -- NOTE(JRC): Retrieves all fields in an object that aren't metafunctions.
  local function getfields( t )
    local fields = {}
    for field, _ in pairs( t ) do
      if not string.match( field, '^__.*$' ) then table.insert( fields, field ) end
    end
    return fields
  end

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    base_t = struct( {}, 'val', BASE_VAL, 'tbl', BASE_TABLE )
    base_t.getval = function( self ) return self.val end
    base_t.getname = function( self ) return BASE_NAME end
    base_t.lcltbl = { BASE_VAL, BASE_NAME }

    over_t = struct( {base_t}, 'val', OVER_VAL, 'tbl', OVER_TABLE )
    over_t.getval = function( self ) return self.val end
    over_t.getname = function( self ) return OVER_NAME end
    over_t.lcltbl = { OVER_VAL, OVER_NAME }

    baseobj = base_t()
    overobj = over_t()
  end )

  --[[ Testing Functions ]]--

  it( 'distributes all default struct fields to struct objects', function()
    assert.is.truthy( baseobj.val )
    assert.is.truthy( baseobj.tbl )
    assert.are.equal( BASE_VAL, baseobj.val )
    assert.are.equal( BASE_TABLE, baseobj.tbl )
  end )

  it( 'distributes all extra struct fields to struct objects', function()
    assert.is.truthy( baseobj.getval )
    assert.is.truthy( baseobj.getname )
    assert.is.truthy( baseobj.lcltbl )
  end )

  it( 'distributes the same fields (default/extra) to all struct objects', function()
    local baseobj2 = base_t()
    for _, field in ipairs( getfields(base_t) ) do
      assert.are.equal( base_t[field], baseobj[field] )
      assert.are.equal( base_t[field], baseobj2[field] )
    end
  end )

  it( 'supports local default field overrides that do not impact other objects', function()
    local baseobj2 = base_t()

    baseobj.val = OVER_VAL
    assert.are_not.equal( base_t.val, baseobj.val )
    assert.are.equal( base_t.val, baseobj2.val )

    baseobj.tbl[1] = OVER_VAL
    assert.are_not.same( base_t.tbl, baseobj.tbl )
    assert.are.same( base_t.tbl, baseobj2.tbl )
  end )

  it( 'supports local extra field overrides that do not impact other objects', function()
    local baseobj2 = base_t()

    baseobj.getval = function( self ) return self.val + 1 end
    assert.are_not.equal( base_t.getval, baseobj.getval )
    assert.are.equal( base_t.getval, baseobj2.getval )

    baseobj.lcltbl[2] = BASE_NAME .. BASE_NAME
    assert.are_not.same( base_t.lcltbl, baseobj.lcltbl )
    assert.are.same( base_t.lcltbl, baseobj2.lcltbl )
  end )

  it( 'supports default field overrides in struct objects w/ overrides occuring ' ..
      'in field specification order', function()
    local OVER_BASE_VAL, OVER_OVER_VAL = 10, 20
    local defs_t = struct( {}, 'base', BASE_VAL, 'over', OVER_VAL )
    local defsobj = defs_t( OVER_BASE_VAL, OVER_OVER_VAL )

    assert.are.equal( BASE_VAL, defs_t.base )
    assert.are.equal( OVER_VAL, defs_t.over )

    assert.are.equal( OVER_BASE_VAL, defsobj.base )
    assert.are.equal( OVER_OVER_VAL, defsobj.over )
  end )

  it( 'supports granular default initialization specification through the ' ..
      'definition of the "_init" function', function()
    local OVER_BASE_VAL, OVER_OVER_VAL = 10, 20
    local defs_t = struct( {}, 'base', BASE_VAL, 'over', OVER_VAL )
    defs_t._init = function( self, overval, baseval )
      self.base, self.over = baseval, overval
    end
    local defsobj = defs_t( OVER_OVER_VAL, OVER_BASE_VAL )

    assert.are.equal( BASE_VAL, defs_t.base )
    assert.are.equal( OVER_VAL, defs_t.over )

    assert.are.equal( OVER_BASE_VAL, defsobj.base )
    assert.are.equal( OVER_OVER_VAL, defsobj.over )
  end )

  it( 'distributes all nonoverridden fields to derived structs', function()
    local desc_t = struct( {base_t} )
    for _, field in ipairs( getfields(desc_t) ) do
      assert.are.equal( base_t[field], desc_t[field] )
    end
  end )

  it( 'supports field overriding in derived structs', function()
    for _, field in ipairs( getfields(over_t) ) do
      assert.are_not.equal( base_t[field], over_t[field] )
    end

    assert.are.equal( OVER_VAL, overobj:getval() )
    assert.are.equal( OVER_NAME, overobj:getname() )
  end )

  it( 'supports field distribution from multiple specified base structs', function()
    local orth_t = struct( {}, 'data', OVER_VAL )
    orth_t.gettype = function( self ) return 'orth_t' end
    local multi_t = struct( {base_t, orth_t} )

    for _, field in ipairs( getfields(base_t) ) do
      assert.are.equal( base_t[field], multi_t[field] )
    end
    for _, field in ipairs( getfields(orth_t) ) do
      assert.are.equal( orth_t[field], multi_t[field] )
    end
  end )

  it( 'distributes fields to derived structs with field priority being ' ..
      'taken in struct specification order', function()
    local basealt_t = struct( {}, 'val', OVER_VAL )
    basealt_t.gettype = function( self ) return 'basealt_t' end
    basealt_t.getname = function( self ) return OVER_NAME end
    local complex_t = struct( {base_t, basealt_t} )

    for _, field in ipairs( getfields(base_t) ) do
      assert.are.equal( base_t[field], complex_t[field] )
    end
    for _, field in ipairs( getfields(basealt_t) ) do
      if not base_t[field] then
        assert.are.equal( basealt_t[field], complex_t[field] )
      else
        assert.are_not.equal( basealt_t[field], complex_t[field] )
      end
    end
  end )
end )
