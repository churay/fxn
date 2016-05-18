local struct = require( 'fxn.struct' )
local dbg = require( 'debugger' )

describe( 'struct', function()
  --[[ Testing Constants ]]--

  local BASE_VAL = 1
  local OVER_VAL = 2

  local BASE_NAME = 'base'
  local OVER_NAME = 'over'

  --[[ Testing Variables ]]--

  local base_t = nil
  local over_t = nil
  local desc_t = nil

  local baseobj = nil
  local overobj = nil
  local descobj = nil

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
    base_t = struct( {val=BASE_VAL} )
    base_t.getval = function( self ) return self.val end
    base_t.getname = function( self ) return BASE_NAME end

    over_t = struct( {val=OVER_VAL}, base_t )
    over_t.getval = function( self ) return self.val end
    over_t.getname = function( self ) return OVER_NAME end

    desc_t = struct( nil, base_t )

    baseobj = base_t()
    overobj = over_t()
    descobj = desc_t()
  end )

  after_each( function()
    base_t = nil
    over_t = nil
    desc_t = nil

    baseobj = nil
    overobj = nil
    descobj = nil
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

  --[[
  it( 'distributes the function override from the nearest type', function()
    assert.are.equal( OVERRIDE_VALUE, overrideobject:getval() - 1 )
    assert.are.equal( OVERRIDE_NAME, overrideobject:tostr() )

    assert.are.equal( BASE_VALUE, inheritobject:getval() )
    assert.are.equal( BASE_NAME, inheritobject:tostr() )

    assert.are.equal( BASE_VALUE, descendentobject:getval() )
    assert.are.equal( DESCENDENT_NAME, descendentobject:tostr() )
  end )

  it( 'allows instance types to be determined through 'istype'', function()
    local obj2objtypes = _getobj2typetable()

    for obj, objtype in pairs( obj2objtypes ) do
      assert.is_true( obj:istype(objtype) )
      assert.is_true( objtype == BaseClass or not obj:istype(BaseClass) )
    end
  end )

  it( 'allows instance classes to be determined through 'isa'', function()
    local obj2objtypes = _getobj2typetable()

    for obj, objtype in pairs( obj2objtypes ) do
      assert.is_true( obj:isa(objtype) )
      assert.is_true( obj:isa(BaseClass) )
    end

    assert.is_false( inheritobject:isa(OverrideClass) )
    assert.is_false( overrideobject:isa(InheritClass) )
  end )
  ]]--

end )
