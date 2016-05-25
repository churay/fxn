local struct = require( 'struct' )
local util = require( 'util' )

--[[ Constructor ]]--

local graph_t = struct( {},
  '_nodes', {},
  '_edges', {labels={}, outgoing={}, incoming={}},
  '_nextnid', 1
)

--[[ Public Functions ]]--

function graph_t.addnode( self, nlabel )
  local nid = self:_getnextnid()
  local nlabel = nlabel == nil and true or nlabel

  self._nodes[nid] = nlabel
  self._edges.labels[nid] = {}
  self._edges.outgoing[nid] = {}
  self._edges.incoming[nid] = {}

  return graph_t.node_t( self, nid )
end

-- TODO(JRC): Add an option for adding bidirectional edges.
function graph_t.addedge( self, srcnode, dstnode, elabel )
  if self:findnode( srcnode ) and self:findnode( dstnode ) then
    if self:findedge( srcnode, dstnode ) then
      self:removeedge( srcnode, dstnode )
    end

    local srcnid, dstnid = srcnode._nid, dstnode._nid
    local elabel = elabel == nil and true or elabel
    self._edges.labels[srcnid][dstnid] = elabel
    self._edges.outgoing[srcnid][dstnid] = true
    self._edges.incoming[dstnid][srcnid] = true

    return graph_t.edge_t( self, srcnid, dstnid )
  end
end

function graph_t.removenode( self, node )
  local node = self:findnode( node )
  if node then
    for _, ie in ipairs( node:getinedges() ) do self:removeedge( ie ) end
    for _, oe in ipairs( node:getoutedges() ) do self:removeedge( oe ) end

    local nid = node._nid
    self._nodes[nid] = nil
    self._edges.labels[nid] = nil
    self._edges.outgoing[nid] = nil
    self._edges.incoming[nid] = nil
  end
end

function graph_t.removeedge( self, ... )
  local edge = self:findedge( ... )
  if edge then
    self._edges.labels[edge._srcnid][edge._dstnid] = nil
    self._edges.outgoing[edge._srcnid][edge._dstnid] = nil
    self._edges.incoming[edge._dstnid][edge._srcnid] = nil
  end
end

function graph_t.findnode( self, node )
  if self == node._graph and self._nodes[node._nid] ~= nil then
    return node
  end
end

function graph_t.findedge( self, ... )
  local edge = nil

  local arg = util.pack( ... )
  if arg.n == 1 then edge = arg[1]
  elseif arg.n == 2 then edge = graph_t.edge_t( self, arg[1]._nid, arg[2]._nid )
  else edge = nil end

  if edge and self == edge._graph and
      self._edges.outgoing[edge._srcnid] ~= nil and 
      self._edges.outgoing[edge._srcnid][edge._dstnid] ~= nil then
    return edge
  end
end

function graph_t.querynodes( self, queryfxn )
  local queriednodes = {}
  local queryfxn = queryfxn or function( v ) return true end

  for nid, nlabel in pairs( self._nodes ) do
    local node = graph_t.node_t( self, nid )
    if queryfxn( node ) then table.insert( queriednodes, node ) end
  end

  return queriednodes
end

function graph_t.queryedges( self, queryfxn )
  local queriededges = {}
  local queryfxn = queryfxn or function( e ) return true end

  for srcnid, srcverttoedges in pairs( self._edges.labels ) do
    for dstnid, elabel in pairs( srcverttoedges ) do
      local edge = graph_t.edge_t( self, srcnid, dstnid )
      if queryfxn( edge ) then table.insert( queriededges, edge ) end
    end
  end

  return queriededges
end

--[[ Private Functions ]]--

function graph_t._getnextnid( self )
  local nextnid = self._nextnid
  self._nextnid = self._nextnid + 1
  return nextnid
end

--[[ Private Classes ]]--

graph_t.node_t = struct( {}, '_graph', nil, '_nid', -1 )

function graph_t.node_t.__eq( self, other )
  return self._graph == other._graph and self._nid == other._nid
end

function graph_t.node_t.getlabel( self )
  return self._graph._nodes[self._nid] 
end

function graph_t.node_t.getoutedges( self )
  local outedges = {}

  for dstnid in pairs( self._graph._edges.outgoing[self._nid] ) do
    local dstnode = graph_t.node_t( self._graph, dstnid )
    table.insert( outedges, self._graph:findedge(self, dstnode) )
  end

  return outedges
end

function graph_t.node_t.getinedges( self )
  local inedges = {}

  for srcnid in pairs( self._graph._edges.incoming[self._nid] ) do
    local srcnode = graph_t.node_t( self._graph, srcnid )
    table.insert( inedges, self._graph:findedge(srcnode, self) )
  end

  return inedges
end

graph_t.edge_t = struct( {}, '_graph', nil, '_srcnid', -1, '_dstnid', -1 )

function graph_t.edge_t.__eq( self, other )
  return self._graph == other._graph and self._srcnid == other._srcnid and
    self._dstnid == other._dstnid
end

function graph_t.edge_t.getlabel( self )
  return self._graph._edges.labels[self._srcnid][self._dstnid]
end

function graph_t.edge_t.getsource( self )
  return self._graph:findnode( graph_t.node_t(self._graph, self._srcnid) )
end

function graph_t.edge_t.getdestination( self )
  return self._graph:findnode( graph_t.node_t(self._graph, self._dstnid) )
end

return graph_t
