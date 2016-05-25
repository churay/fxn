local struct = require( 'fxn.struct' )

describe( 'struct', function()
  --[[ Testing Constants ]]--

  local BASE_VAL = 1
  local OVER_VAL = 2

  local BASE_NAME = 'base'
  local OVER_NAME = 'over'

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
    base_t = struct( {}, 'val', BASE_VAL )
    base_t.getval = function( self ) return self.val end
    base_t.getname = function( self ) return BASE_NAME end

    over_t = struct( {base_t}, 'val', OVER_VAL )
    over_t.getval = function( self ) return self.val end
    over_t.getname = function( self ) return OVER_NAME end

    baseobj = base_t()
    overobj = over_t()
  end )

  --[[ Testing Functions ]]--

  it( 'distributes all default fields to structs', function()
    assert.is.truthy( base_t['val'] )
    assert.are.equal( BASE_VAL, base_t['val'] )
  end )

  it( 'distributes all fields to struct instances', function()
    for _, field in ipairs( getfields(base_t) ) do
      assert.is.truthy( baseobj[field] )
    end
  end )

  it( 'distributes the same fields to all struct instances', function()
    local baseobj2 = base_t()
    for _, field in ipairs( getfields(base_t) ) do
      assert.are.equal( base_t[field], baseobj[field] )
      assert.are.equal( base_t[field], baseobj2[field] )
    end
  end )

  it( 'allows instances to use their structs fields', function()
    assert.are.equal( BASE_VAL, baseobj:getval() )
    assert.are.equal( BASE_NAME, baseobj:getname() )
  end )

  it( 'disallows accesses to undefined fields in the struct', function()
    assert.is.equal( nil, baseobj['undefined'] )
  end )

  it( 'distributes all nonoverridden fields to derived structs', function()
    desc_t = struct( {base_t} )

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
