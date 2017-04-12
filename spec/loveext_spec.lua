require( 'bustedext' )
local util = require( 'util' )

describe( 'love.ext', function()
  --[[ Testing Constants ]]--

  local LG_OVERFXNS = { 'origin', 'pop', 'push', 'rotate', 'scale', 'shear', 'translate' }

  --[[ Testing Variables ]]--

  local love = { graphics={}, ext={} }
  local lovestub = {}

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    for ext in pairs( love ) do love[ext], lovestub[ext] = {}, {} end

    for _, lgoverfxn in ipairs( LG_OVERFXNS ) do
      stub( lovestub.graphics, lgoverfxn )
      love.graphics[lgoverfxn] = lovestub.graphics[lgoverfxn]
    end

    _G['love'] = love
    love.ext = require( 'loveext' )
    love, _G['love'] = _G['love'], nil
  end )

  after_each( function()
    package.loaded['loveext'] = nil
  end )

  --[[ Testing Functions ]]--

  describe( 'love.graphics extension', function()
    it( 'overrides all proper library calls without deleting them', function()
      for _, lgoverfxn in ipairs( LG_OVERFXNS ) do
        assert.is.truthy( love.graphics[lgoverfxn] )
      end
    end )

    it( 'always calls original library functions on calls to overrides', function()
      for _, lgoverfxn in ipairs( LG_OVERFXNS ) do
        love.graphics[lgoverfxn]()
        assert.stub( lovestub.graphics[lgoverfxn] ).was_called( 1 )
      end
    end )

    it( 'calls original library functions with proper parameters on ' ..
        'override calls', function()
      local testparams = { 10, 20 }
      for _, lgoverfxn in ipairs( LG_OVERFXNS ) do
        love.graphics[lgoverfxn]()
        assert.stub( lovestub.graphics[lgoverfxn] ).was_called_with()

        love.graphics[lgoverfxn]( util.unpack(testparams) )
        assert.stub( lovestub.graphics[lgoverfxn] ).was_called_with(
          util.unpack(testparams) )
      end
    end )

    describe( 'transform tracking', function()
      it( 'returns an identity matrix from "love.graphics.getTransform" when ' ..
          'no other "love.graphics" functions are called beforehand', function()
        assert.are.equallists(
          {1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0},
          love.graphics.getTransform(),
          util.fequal
        )
      end )

      it( 'returns an independent transform from "love.graphics.getTransform" ' ..
          'that cannot be changed to alter internal tracking values', function()
        local lgxform = love.graphics.getTransform()
        for eidx in ipairs( lgxform ) do lgxform[eidx] = 0.0 end

        assert.are.equallists(
          {1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0},
          love.graphics.getTransform(),
          util.fequal
        )
      end )

      it( 'properly adjusts the transform when "love.graphics.rotate" ' ..
          'is invoked', function()
        love.graphics.rotate( math.pi / 2.0 )
        assert.are.equallists(
          {0.0, -1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0},
          love.graphics.getTransform(),
          util.fequal
        )

        love.graphics.rotate( math.pi / 2.0 )
        assert.are.equallists(
          {-1.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 1.0},
          love.graphics.getTransform(),
          util.fequal
        )
      end )

      it( 'properly adjusts the transform when "love.graphics.scale" ' ..
          'is invoked', function()
        local scalex, scaley = 10, 20
        love.graphics.scale( scalex, scaley )

        assert.are.equallists(
          {scalex, 0.0, 0.0, 0.0, scaley, 0.0, 0.0, 0.0, 1.0},
          love.graphics.getTransform(),
          util.fequal
        )
      end )

      it( 'properly adjusts the transform when "love.graphics.shear" ' ..
          'is invoked', function()
        local shearx, sheary = 10, 20
        love.graphics.shear( shearx, sheary )

        assert.are.equallists(
          {1.0, shearx, 0.0, sheary, 1.0, 0.0, 0.0, 0.0, 1.0},
          love.graphics.getTransform(),
          util.fequal
        )
      end )

      it( 'properly adjusts the transform when "love.graphics.translate" ' ..
          'is invoked', function()
        local transx, transy = 10, 20
        love.graphics.translate( transx, transy )

        assert.are.equallists(
          {1.0, 0.0, transx, 0.0, 1.0, transy, 0.0, 0.0, 1.0},
          love.graphics.getTransform(),
          util.fequal
        )
      end )

      it( 'properly applies the transform to the position given to ' ..
          '"love.graphics.transform"', function()
        local posx, posy = 14, 28
        local transx, transy = 10, 20

        love.graphics.translate( transx, transy )
        local xformx, xformy = love.graphics.transform( posx, posy )
        assert.are.equallists(
          {posx + transx, posy + transy},
          {xformx, xformy},
          util.fequal
        )
      end )

      it( 'properly applies the inverse transform to the position given ' ..
          'to "love.graphics.itransform"', function()
        local posx, posy = 14, 28
        local transx, transy = 10, 20

        love.graphics.translate( transx, transy )
        local xformx, xformy = love.graphics.itransform( posx, posy )
        assert.are.equallists(
          {posx - transx, posy - transy},
          {xformx, xformy},
          util.fequal
        )
      end )

      it( 'resets the transform when "love.graphics.origin" is called', function()
        love.graphics.translate( 10, 20 )
        assert.are_not.equallists(
          {1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0},
          love.graphics.getTransform(),
          util.fequal
        )

        love.graphics.origin()
        assert.are.equallists(
          {1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0},
          love.graphics.getTransform(),
          util.fequal
        )
      end )

      it( 'adjusts the transform following standard stack save/restore ' ..
          'behavior when "love.graphics.pop" and "love.graphics.push" ' ..
          'are called', function()
        for transamt = 1, 10, 1 do
          love.graphics.translate( 1 )
          love.graphics.push()

          assert.are.equallists(
            {1.0, 0.0, transamt, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0},
            love.graphics.getTransform(),
            util.fequal
          )
        end

        for transamt = 10, 1, -1 do
          love.graphics.translate( 2 * transamt )
          love.graphics.pop()

          assert.are.equallists(
            {1.0, 0.0, transamt, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0},
            love.graphics.getTransform(),
            util.fequal
          )
        end
      end )
    end )
  end )
end )
