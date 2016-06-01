local struct = require( 'fxn.struct' )

describe( 'struct', function()
  --[[ Testing Constants ]]--

  local BASE_VAL = 1
  local BASE_NAME = 'base'
  local BASE_OTABLE = { BASE_VAL, BASE_NAME }
  local BASE_GETVAL = function( self ) return self.val end
  local BASE_GETNAME = function( self ) return BASE_NAME end
  local BASE_STABLE = { BASE_VAL, BASE_NAME }

  --[[ Testing Variables ]]--

  local base_t = nil

  --[[ Testing Helper Functions ]]--

  local function getobjfields( struct_t )
    local fields = {}
    for field, _ in pairs( struct_t.__fields ) do table.insert( fields, field ) end
    return fields
  end

  local function getshrfields( struct_t )
    local fields = {}
    for field, _ in pairs( struct_t ) do
      if not string.match( field, '^__.*$' ) then table.insert( fields, field ) end
    end
    return fields
  end

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    base_t = struct( {}, 'val', BASE_VAL, 'otable', BASE_OTABLE )
    base_t.getval = BASE_GETVAL
    base_t.getname = BASE_GETNAME
    base_t.stable = BASE_STABLE
  end )

  --[[ Testing Functions ]]--

  describe( 'struct object creation and field distribution functionality', function()
    local obj1, obj2 = nil, nil

    before_each( function()
      obj1, obj2 = base_t(), base_t()
    end )

    it( 'distributes all struct object fields to struct objects', function()
      for _, ofield in ipairs( getobjfields(base_t) ) do
        assert.is.truthy( obj1[ofield] )
        assert.is.truthy( obj2[ofield] )
      end
    end )

    it( 'distributes all struct shared fields to struct objects', function()
      for _, sfield in ipairs( getshrfields(base_t) ) do
        assert.is.truthy( obj1[sfield] )
        assert.is.truthy( obj2[sfield] )
      end
    end )

    it( 'distributes different object fields to all struct objects', function()
      for _, ofield in ipairs( getobjfields(base_t) ) do
        if type( obj1[ofield] ) == 'table' then
          assert.are_not.equal( obj1[ofield], obj2[ofield] )
          assert.are.same( obj1[ofield], obj2[ofield] )
        else
          assert.are.equal( obj1[ofield], obj2[ofield] )
        end
      end
    end )

    it( 'distributes the same shared fields to all struct objects', function()
      for _, sfield in ipairs( getshrfields(base_t) ) do
        assert.are.equal( base_t[sfield], obj1[sfield] )
        assert.are.equal( base_t[sfield], obj2[sfield] )
      end
    end )

    it( 'supports object field overrides that do not impact other objects', function()
      local BASEOBJ_OVER_VAL = 10
      for _, ofield in ipairs( getobjfields(base_t) ) do
        obj1[ofield] = BASEOBJ_OVER_VAL
        assert.are_not.same( base_t.__fields[ofield], obj1[ofield] )
        assert.are.same( base_t.__fields[ofield], obj2[ofield] )
      end
    end )

    it( 'supports shared field overrides that do not impact other objects', function()
      local BASEOBJ_OVER_VAL = 10
      for _, sfield in ipairs( getshrfields(base_t) ) do
        obj1[sfield] = BASEOBJ_OVER_VAL
        assert.are_not.equal( base_t[sfield], obj1[sfield] )
        assert.are.equal( base_t[sfield], obj2[sfield] )
      end
    end )
  end )

  describe( 'struct object set up and initialization functionality', function()
    local OVER_VAL = BASE_VAL + 10
    local OVER_NAME = BASE_NAME .. BASE_NAME
    local OVER_OTABLE = { OVER_VAL, OVER_NAME }

    it( 'supports default object value initialization to values specified in ' ..
        'original struct value specification', function()
      local defaultobj = base_t()
      for _, ofield in ipairs( getobjfields(base_t) ) do
        assert.are.same( base_t.__fields[ofield], defaultobj[ofield] )
      end
    end )

    it( 'supports object field overrides by giving values in struct call function ' ..
        '(w/ overrides occuring in struct field specification order)', function()
      base_t._init = nil
      local overobj = base_t( OVER_VAL, OVER_OTABLE )

      assert.are.equal( BASE_VAL, base_t.__fields.val )
      assert.are.equal( BASE_OTABLE, base_t.__fields.otable )

      assert.are.equal( OVER_VAL, overobj.val )
      assert.are.equal( OVER_OTABLE, overobj.otable )
    end )

    it( 'supports granular object field overrides and object initialization ' ..
        'through the definition of the "_init" function', function()
      base_t._init = function( self, overotable, overval )
        self.val, self.otable = overval, overotable
      end
      local overobj = base_t( OVER_OTABLE, OVER_VAL )

      assert.are.equal( BASE_VAL, base_t.__fields.val )
      assert.are.equal( BASE_OTABLE, base_t.__fields.otable )

      assert.are.equal( OVER_VAL, overobj.val )
      assert.are.equal( OVER_OTABLE, overobj.otable )
    end )
  end )

  describe( 'struct field inheritance and overriding functionality', function()
    local OVER_VAL = 2
    local OVER_GETVAL = function( self ) return self.val end
    local OVER_STABLE = { OVER_VAL, OVER_NAME }

    local over_t = nil
    local baseobj, overobj = nil, nil

    before_each( function()
      over_t = struct( {base_t}, 'val', OVER_VAL )
      over_t.getval = OVER_GETVAL
      over_t.stable = OVER_STABLE

      baseobj = base_t()
      overobj = over_t()
    end )

    it( 'distributes all nonoverridden object fields to derived structs', function()
      for _, ofield in ipairs( getobjfields(base_t) ) do
        local isoverridden = false
        for _, overofield in ipairs( getobjfields(over_t) ) do
          isoverridden = isoverridden or ofield == overofield
        end

        if not isoverridden then
          assert.are.same( base_t.__fields[ofield], overobj[ofield] )
        end
      end
    end )

    it( 'distributes all nonoverridden shared fields to derived structs', function()
      for _, sfield in ipairs( getshrfields(base_t) ) do
        local isoverridden = false
        for _, oversfield in ipairs( getshrfields(over_t) ) do
          isoverridden = isoverridden or sfield == oversfield
        end

        if not isoverridden then
          assert.are.equal( base_t[sfield], overobj[sfield] )
        end
      end
    end )

    it( 'supports object field overriding in derived structs', function()
      for _, ofield in ipairs( getobjfields(over_t) ) do
        assert.are.same( over_t.__fields[ofield], overobj[ofield] )
      end
    end )

    it( 'supports shared field overriding in derived structs', function()
      for _, sfield in ipairs( getshrfields(over_t) ) do
        assert.are.equal( over_t[sfield], overobj[sfield] )
      end
    end )

    it( 'supports field distribution from multiple specified base structs', function()
      pending( 'TODO(JRC)' )
      --[[
      local orth_t = struct( {}, 'data', OVER_VAL )
      orth_t.gettype = function( self ) return 'orth_t' end
      local multi_t = struct( {base_t, orth_t} )

      for _, field in ipairs( getfields(base_t) ) do
        assert.are.equal( base_t[field], multi_t[field] )
      end
      for _, field in ipairs( getfields(orth_t) ) do
        assert.are.equal( orth_t[field], multi_t[field] )
      end
      --]]
    end )

    it( 'distributes fields to derived structs with field priority being ' ..
        'taken in struct specification order', function()
      pending( 'TODO(JRC)' )
      --[[
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
      --]]
    end )
  end )
end )
