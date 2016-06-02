require( 'bustedext' )
local graph_t = require( 'fxn.graph' )

describe( 'graph', function()
  --[[ Testing Variables ]]--

  local testgraph = nil
  local testnodes = nil
  local testedges = nil
  local testaltgraph = nil

  --[[ Set Up / Tear Down Functions ]]--

  before_each( function()
    -- Test Graph Diagram:
    --   +---->3-----+
    --   |     |     |
    --   |     |     v
    --   2     |     5    1
    --   |     |     ^
    --   |     v     |
    --   +---->4-----+
    testgraph = graph_t()

    testnodes = {}
    for nodeidx = 1, 5, 1 do
      local node = testgraph:addnode( tostring(nodeidx) )
      table.insert( testnodes, node )
    end

    testedges = {}
    local edgepairs = { {2, 3}, {2, 4}, {3, 5}, {4, 5}, {3, 4} }
    for _, ep in ipairs( edgepairs ) do
      local edge = testgraph:addedge( testnodes[ep[1]], testnodes[ep[2]],
        tostring(ep[1]) .. '>' .. tostring(ep[2])  )
      table.insert( testedges, edge )
    end

    -- Test AltGraph Diagram:
    --
    --   1---------->2
    --
    testaltgraph = graph_t()
    testaltgraph:addedge( testaltgraph:addnode('1'),
      testaltgraph:addnode('2'), '1>2' )
  end )

  --[[ Testing Functions ]]--

  it( 'constructs instances that are initially empty', function()
    local emptygraph = graph_t()

    assert.are.equallists( {}, emptygraph:querynodes() )
    assert.are.equallists( {}, emptygraph:queryedges() )
  end )

  it( 'properly adds nodes to the data structure', function()
    assert.are.equallists( testnodes, testgraph:querynodes() )

    for nodeidx, node in ipairs( testnodes ) do
      assert.are.equal( tostring(nodeidx), node:getlabel() )
    end
  end )

  it( 'properly adds new edges to the data structure', function()
    assert.are.equallists( testedges, testgraph:queryedges() )

    for edgeidx, edge in ipairs( testedges ) do
      assert.are.equal(
        edge:getsource():getlabel() .. '>' .. edge:getdestination():getlabel(),
        edge:getlabel()
      )
    end
  end )

  it( 'supports adding new bidirectional edges to the data structure', function()
    pending( 'TODO(JRC)' )
    --[[
      Change the Test Graph to Use Bidirectional Insertion
      Test the Integrity of the Bidirectional Edge Here
    --]]
  end )

  it( 'does not allow adding edges with invalid start/end nodes', function()
    local remotenodes = testaltgraph:querynodes()
    assert.falsy( testgraph:addedge(testnodes[1], remotenodes[2]) )
    assert.falsy( testgraph:addedge(remotenodes[1], testnodes[2]) )

    assert.are.equallists( testedges, testgraph:queryedges() )
  end )

  it( 'overwrites existing edges on edge readd', function()
    local overwriteedge = testgraph:queryedges()[1]
    local overwritesrc = overwriteedge:getsource()
    local overwritedst = overwriteedge:getdestination()

    local newelabel = '-' .. overwriteedge:getlabel() .. '-'
    local newedge = testgraph:addedge( overwritesrc, overwritedst, newelabel )

    assert.are.equal( newelabel, newedge:getlabel() )
    assert.are.equal( overwritesrc, newedge:getsource() )
    assert.are.equal( overwritedst, newedge:getdestination() )
  end )

  it( 'properly removes nodes from the data structure', function()
    for testnodeidx = #testnodes, 1, -1 do 
      local testnode = testnodes[testnodeidx]

      table.remove( testnodes, testnodeidx )
      testgraph:removenode( testnode )

      assert.are.equallists( testnodes, testgraph:querynodes() )
    end
  end )

  it( 'removes all edges attached to a node upon its removal', function()
    local edgegraph = graph_t()

    local centralnode = edgegraph:addnode( 'c' )
    local outernodes = {}
    for vidx = 1, 6, 1 do
      local outernode = edgegraph:addnode( tostring(vidx) )
      table.insert( outernodes, outernode )

      if vidx % 2 == 0 then edgegraph:addedge( centralnode, outernode )
      else edgegraph:addedge( outernode, centralnode ) end
    end

    assert.are.equal( #outernodes, #edgegraph:queryedges() )
    edgegraph:removenode( centralnode )
    assert.are.equal( 0, #edgegraph:queryedges() )
  end )

  it( 'properly removes edges from the data structure', function()
    for testedgeidx = #testedges, 1, -1 do 
      local testedge = testedges[testedgeidx]

      table.remove( testedges, testedgeidx )
      testgraph:removeedge( testedge )

      assert.are.equallists( testedges, testgraph:queryedges() )
    end
  end )

  it( 'returns only existing nodes queried via "findnode"', function()
    for _, node in ipairs( testnodes ) do
      assert.are.equal( node, testgraph:findnode(node) )
    end

    local remotenode = testaltgraph:querynodes()[1]
    assert.falsy( testgraph:findnode(remotenode) )
  end )

  it( 'returns only existing edges queried via "findedge"', function()
    for _, edge in ipairs( testedges ) do
      assert.are.equal( edge, testgraph:findedge(edge) )
    end

    local remoteedge = testaltgraph:queryedges()[1]
    assert.falsy( testgraph:findedge(remoteedge) )
  end )

  it( 'supports "findedge" edge queries using endpoint nodes', function()
    for _, edge in ipairs( testedges ) do
      local edgesrc = edge:getsource()
      local edgedst = edge:getdestination()
      assert.are.equal( edge, testgraph:findedge(edgesrc, edgedst) )
    end

    local remotenodes = testaltgraph:querynodes()
    assert.falsy( testgraph:findedge(testnodes[1], testnodes[2]) )
    assert.falsy( testgraph:findedge(testnodes[1], remotenodes[2]) )
    assert.falsy( testgraph:findedge(remotenodes[1], remotenodes[2]) )
  end )

  it( 'facilitates arbitrary node queries with "querynodes"', function()
    local queriednodes = testgraph:querynodes( function(v)
      return tonumber( v:getlabel() ) >= 3
    end )

    assert.are.equal( 3, #queriednodes )
    assert.are.equallists(
      { testnodes[3], testnodes[4], testnodes[5] },
      queriednodes
    )
  end )

  it( 'facilitates arbitrary edge queries with "queryedges"', function()
    local queriededges = testgraph:queryedges( function(e)
      return e:getdestination() == testnodes[5] or e:getsource() == testnodes[5]
    end )

    assert.are.equal( 2, #queriededges )
    assert.are.equallists( {testedges[3], testedges[4]}, queriededges )
  end )
end )
