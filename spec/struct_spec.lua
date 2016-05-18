local struct = require( "fxn.struct" )

describe( "struct", function()
  --[[ Testing Constants ]]--

  local BASE_VAL = 1
  local OVER_VAL = 2
  local NONDEF_VAL = 3

  local BASE_NAME = "base"
  local OVER_NAME = "over"

  --[[ Testing Variables ]]--

  local base_t = nil
  local over_t = nil
  local desc_t = nil

  local baseobj = nil
  local overobj = nil
  local descobj = nil
  local nondefobj = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    base_t = struct( {val=BASE_VAL} )
    base_t.getval = function( self ) return self.val end
    base_t.getname = function( self ) return BASE_NAME end

    over_t = struct( {val=OVER_VAL}, base_t )
    over_t.getname = function( self ) return OVER_NAME end

    desc_t = struct( nil, base_t )

    baseobj = base_t()
    overobj = over_t()
    descobj = desc_t()
    nondefobj = desc_t( {val=NONDEF_VAL} )
  end )

  after_each( function()
    base_t = nil
    over_t = nil
    desc_t = nil

    baseobj = nil
    overobj = nil
    descobj = nil
    nondefobj = nil
  end )

  --[[ Testing Functions ]]--

  it( "distributes all functions to type instances", function()
    for field, _ in pairs( base_t ) do
      assert.is.truthy( baseobj[field] )
    end
  end )

  it( "distributes the same functions to all type instances", function()
    local baseobj2 = base_t()

    for field, _ in pairs( base_t ) do
      assert.are.equal( base_t[field], baseobj[field] )
      assert.are.equal( base_t[field], baseobj2[field] )
    end
  end )

  --[[
  it( "allows instances to use their type's functions", function()
    assert.are.equal( BASE_VALUE, baseobject:getval() )
    assert.are.equal( BASE_NAME, baseobject:tostr() )
  end )

  it( "throws errors when undefined type functions are invoked", function()
    -- TODO(JRC): This test should be changed to use `assert.has_error`.
    assert.is.equal( nil, baseobject["undefinedfxn"] )
  end )

  it( "properly sets the 'super' field to the type's parent type", function()
    assert.is.truthy( BaseClass._super )
    assert.are.equal( BaseClass, OverrideClass._super )
    assert.are.equal( BaseClass, InheritClass._super )
    assert.are.equal( InheritClass, DescendentClass._super )
  end )

  it( "distributes all nonoverridden functions to child types", function()
    for _, fxn in pairs( CLASS_FUNCTIONS ) do
      assert.are.equal( BaseClass[fxn], InheritClass[fxn] )
    end

    assert.are.equal( InheritClass._init, DescendentClass._init )
    assert.are.equal( InheritClass.getval, DescendentClass.getval )
  end )

  it( "supports function overriding in child classes", function()
    for _, fxn in pairs( CLASS_FUNCTIONS ) do
      assert.are_not.equal( BaseClass[fxn], OverrideClass[fxn] )
    end

    assert.are_not.equal( InheritClass.tostr, DescendentClass.tostr )
  end )

  it( "distributes the function override from the nearest type", function()
    assert.are.equal( OVERRIDE_VALUE, overrideobject:getval() - 1 )
    assert.are.equal( OVERRIDE_NAME, overrideobject:tostr() )

    assert.are.equal( BASE_VALUE, inheritobject:getval() )
    assert.are.equal( BASE_NAME, inheritobject:tostr() )

    assert.are.equal( BASE_VALUE, descendentobject:getval() )
    assert.are.equal( DESCENDENT_NAME, descendentobject:tostr() )
  end )

  it( "allows instance types to be determined through 'istype'", function()
    local obj2objtypes = _getobj2typetable()

    for obj, objtype in pairs( obj2objtypes ) do
      assert.is_true( obj:istype(objtype) )
      assert.is_true( objtype == BaseClass or not obj:istype(BaseClass) )
    end
  end )

  it( "allows instance classes to be determined through 'isa'", function()
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
