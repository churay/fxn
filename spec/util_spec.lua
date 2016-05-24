local util = require( 'fxn.util' )

describe( 'util', function()
  --[[ Testing Functions ]]--

  -- Mathematical Functions --

  describe( 'inrange', function()
    local min_std, max_std = nil, nil
    local min_stress, max_stress = nil, nil

    before_each( function()
      min_std, max_std = 0.0, 10.0
      min_stress, max_stress = -1.0e-6, 1.0e-6
    end )

    it( 'returns true for values inclusive to the range', function()
      assert.is_true( util.inrange((max_std + min_std) / 2.0, min_std, max_std) )
      assert.is_true( util.inrange((max_stress + min_stress) / 2.0, min_stress, max_stress) )
    end )

    it( 'returns the proper bool for values at the range minimum', function()
      assert.is_true( util.inrange(min_std, min_std, max_std, false) )
      assert.is_not_true( util.inrange(min_std, min_std, max_std, true) )

      assert.is_true( util.inrange(min_stress, min_stress, max_stress, false) )
      assert.is_not_true( util.inrange(min_stress, min_stress, max_stress, true) )
    end )

    it( 'returns the proper bool for values at the range maximum', function()
      assert.is_true( util.inrange(max_std, min_std, max_std, false) )
      assert.is_not_true( util.inrange(max_std, min_std, max_std, true) )

      assert.is_true( util.inrange(max_stress, min_stress, max_stress, false) )
      assert.is_not_true( util.inrange(max_stress, min_stress, max_stress, true) )
    end )
  end )

  describe( 'clamp', function()
    local min_std, max_std = nil, nil
    local min_stress, max_stress = nil, nil

    before_each( function()
      min_std, max_std = 0.0, 10.0
      min_stress, max_stress = -1.0e-6, 1.0e-6
    end )

    it( 'returns the same value for values inclusive to the range', function()
      assert.are.same( 1.0, util.clamp(1.0, min_std, max_std) )
      assert.are.same( 9.0, util.clamp(9.0, min_std, max_std) )

      assert.are.same( -5.0e-7, util.clamp(-5.0e-7, min_stress, max_stress) )
      assert.are.same( 5.0e-7, util.clamp(5.0e-7, min_stress, max_stress) )
    end )

    it( 'returns the range maximum for inputs above the maximum', function()
      assert.are.same( max_std, util.clamp(max_std, min_std, max_std) )
      assert.are.same( max_std, util.clamp(max_std + 1.0e-6, min_std, max_std) )
      assert.are.same( max_std, util.clamp(max_std + 1.0e6, min_std, max_std) )

      assert.are.same( max_stress, util.clamp(max_stress, min_stress, max_stress) )
      assert.are.same( max_stress, util.clamp(max_stress + 1.0e-6, min_stress, max_stress) )
      assert.are.same( max_stress, util.clamp(max_stress + 1.0e6, min_stress, max_stress) )
    end )

    it( 'returns the range minimum for inputs below the minimum', function()
      assert.are.same( min_std, util.clamp(min_std, min_std, max_std) )
      assert.are.same( min_std, util.clamp(min_std - 1.0e-6, min_std, max_std) )
      assert.are.same( min_std, util.clamp(min_std - 1.0e6, min_std, max_std) )

      assert.are.same( min_stress, util.clamp(min_stress, min_stress, max_stress) )
      assert.are.same( min_stress, util.clamp(min_stress - 1.0e-6, min_stress, max_stress) )
      assert.are.same( min_stress, util.clamp(min_stress - 1.0e6, min_stress, max_stress) )
    end )
  end )

  -- Lua Language Functions --

  -- TODO(JRC): Write the implementations for these tests.

end )
