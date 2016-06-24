require( 'bustedext' )
local func_t = require( 'fxn.func' )

describe( 'func', function()
  --[[ Testing Variables ]]--

  local fident = nil
  local fmulti = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    fident = func_t( function(x) return x end )
    fmulti = func_t( function(x, f1, f2) return f1(x) + f2(x) end, fident, fident )
  end )

  --[[ Testing Functions ]]--

  it( 'supports evaluation via the call operator', function()
    for testval = 0, 3 do
      assert.are.equal( testval, fident(testval) )
      assert.are.equal( 2*testval, fmulti(testval) )
    end
  end )

  it( 'can be added with another function to create a new function', function()
    local fadd = fident + fident
    for testval = 0, 3 do assert.are.equal( 2*testval, fadd(testval) ) end
  end )

  it( 'can be subtracted from another function to create a new function', function()
    local fsub = fmulti - fident
    for testval = 0, 3 do assert.are.equal( testval, fsub(testval) ) end
  end )

  it( 'can be multiplied with another function to create a new function', function()
    local fmul = fident * fident
    for testval = 0, 3 do assert.are.equal( testval^2, fmul(testval) ) end
  end )
end )
