require( 'bustedext' )

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

    love.ext = loadfile( 'loveext', 't', {love=love} )
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
  end )
end )
