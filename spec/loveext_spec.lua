require( 'bustedext' )
local ldb = require( 'debugger' )

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
        assert.stub(lovestub.graphics[lgoverfxn]).was_called( 1 )
      end
    end )

    it( 'calls original library functions with proper parameters on override calls', function()
      local testparams = { 10, 20 }
      for _, lgoverfxn in ipairs( LG_OVERFXNS ) do
        love.graphics[lgoverfxn]()
        assert.stub(lovestub.graphics[lgoverfxn]).was_called_with()

        love.graphics[lgoverfxn]( table.unpack(testparams) )
        assert.stub(lovestub.graphics[lgoverfxn]).was_called_with( table.unpack(testparams) )
      end
    end )

    describe( 'transform tracking', function()
      it( 'returns an identity matrix from "love.graphics.getTransform" when no' ..
          'other "love.graphics" functions are called beforehand', function()
        assert.are.equallists(
          {1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0},
          love.graphics.getTransform()
        )
      end )

      it( 'returns an independent transform from "love.graphics.getTransform" ' ..
          'that cannot be manipulated to manipulate internal tracking values', function()
        pending( 'TODO(JRC)' )
      end )

      it( 'properly adjusts the transform when "love.graphics.rotate" is invoked', function()
        pending( 'TODO(JRC)' )
      end )

      it( 'properly adjusts the transform when "love.graphics.scale" is invoked', function()
        local scalex, scaley = 10, 20
        love.graphics.scale( scalex, scaley )

        assert.are.equallists(
          {scalex, 0.0, 0.0, 0.0, scaley, 0.0, 0.0, 0.0, 1.0},
          love.graphics.getTransform()
        )
      end )

      it( 'properly adjusts the transform when "love.graphics.shear" is invoked', function()
        pending( 'TODO(JRC)' )
      end )

      it( 'properly adjusts the transform when "love.graphics.translate" is invoked', function()
        pending( 'TODO(JRC)' )
      end )

      it( 'resets the transform when "love.graphics.origin" is called', function()
        pending( 'TODO(JRC)' )
      end )

      it( 'adjusts the transform following standard stack save/restore behavior when ' ..
          '"love.graphics.pop" and "love.graphics.push" are called', function()
        pending( 'TODO(JRC)' )
      end )
    end )
  end )
end )
