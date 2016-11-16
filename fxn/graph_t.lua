local struct = require( 'struct' )
local table_t = require( 'table_t' )
local util = require( 'util' )

--[[ Constructor ]]--

local graph_t = struct( {},
  '_unique', false,
  '_nodes', {},
  '_edges', {labels={}, outgoing={}, incoming={}},
  '_nlabels', table_t({}),
  '_elabels', table_t({}),
  '_nextnid', 1
)

--[[ Operators ]]--

function graph_t.__tostring( self )
  local graphstr = { 'Graph {' .. self._unique and 'U' or 'D' .. '} ' ..
    '[' .. util.len(self._nodes) .. ']:' }
  for nid, nlabel in pairs( self._nodes ) do
    local nodestr = '  ' .. nlabel .. ' [' .. nid .. ']'
    local edgestr = {}
    for did, elabel in pairs( self._edges.labels[nid] ) do
      local nodestr = self._nodes[did] .. ' [' .. did .. ']'
      table.insert( edgestr, '( ' .. elabel .. ', ' .. nodestr .. ')' )
    end

    table.insert( graphstr, nodestr .. ' : { ' .. table.concat(edgestr, ', ') ..  ' } ' )
  end

  return table.concat( graphstr, '\n' )
end

--[[ Public Functions ]]--

function graph_t.addnode( self, nlabel )
  if self._unique and #self._nlabels[nlabel] ~= 0 then
    self:removenode( nlabel, 'label' )
  end

  local nid = self:_getnextnid()
  local nlabel = nlabel == nil and true or nlabel
  self._nodes[nid] = nlabel
  self._edges.labels[nid] = {}
  self._edges.outgoing[nid] = {}
  self._edges.incoming[nid] = {}
  table.insert( self._nlabels[nlabel], nid )

  return graph_t.node_t( self, nid )
end

function graph_t.addedge( self, elabel, srcid, dstid, idtype )
  if self:findnode( srcid, idtype ) and self:findnode( dstid, idtype ) then
    if self:findedge( srcnode, dstnode ) then
      self:removeedge( srcnode, dstnode )
    end
    if self._unique and #self._elabels[elabel] ~= 0 then
      self:removeedge( elabel, 'label' )
    end

    local srcnid, dstnid = srcnode._nid, dstnode._nid
    local elabel = elabel == nil and true or elabel
    self._edges.labels[srcnid][dstnid] = elabel
    self._edges.outgoing[srcnid][dstnid] = true
    self._edges.incoming[dstnid][srcnid] = true
    table.insert( self._elabels[elabel], srcnid .. '-' .. dstnid )

    return graph_t.edge_t( self, srcnid, dstnid )
  end
end

function graph_t.removenode( self, nid, idtype )
  local node = self:findnode( nid, idtype )
  if node then
    for _, ie in ipairs( node:getinedges() ) do self:removeedge( ie ) end
    for _, oe in ipairs( node:getoutedges() ) do self:removeedge( oe ) end

    util.lsub( self._nlabels[node:getlabel()], node._nid )
    self._nodes[node._nid] = nil
    self._edges.labels[node._nid] = nil
    self._edges.outgoing[node._nid] = nil
    self._edges.incoming[node._nid] = nil
  end
end

function graph_t.removeedge( self, eid, idtype )
  local edge = self:findedge( eid, idtype )
  if edge then
    local srcnid, dstnid = edge._srcnid, edge._dstnid
    util.lsub( self._elabels[edge:getlabel()], srcnid .. '-' .. dstnid )
    self._edges.labels[srcnid][dstnid] = nil
    self._edges.outgoing[srcnid][dstnid] = nil
    self._edges.incoming[dstnid][srcnid] = nil
  end
end

function graph_t.findnode( self, nid, idtype )
  local idtype = idtype or 'label'

  if idtype == 'label' then
    local labelids = self._nlabels[nid]
    if #labelids ~= 0 then return graph_t.node_t( self, labelids[1] ) end
  elseif idtype == 'id' then
    if self._nodes[nid] ~= nil then return graph_t.node_t( self, nid ) end
  elseif idtype == 'type' then
    if nid._graph == self and self._nodes[nid._nid] then return nid end
  end
end

function graph_t.findedge( self, eid, idtype )
  local idtype = idtype or 'nodes'
  local nidtype = string.match( idtype, '^nodes\-(%a*)$' )

  local function edgeexists( srcnid, dstnid )
    return self._edges.outgoing[srcnid] ~= nil and
      self._edge.outgoing[srcnid][dstnid] ~= nil
  end

  if idtype == 'label' then
    local labelids = self._elabels[eid]
    if #labelids ~= 0 then
      return graph_t.edge_t( self, string.match(labelids[1], "(%d+)\-(%d+)") )
    end
  elseif string.match( idtype, '^nodes.*$' ) then
    local srcnode = self:findnode( eid[1], nidtype )
    local dstnode = self:findnode( eid[2], nidtype )
    if srcnode and dstnode and edgeexists( srcnode._nid, dstnode._nid ) then
      return graph_t.edge_t( self, srcnode._nid, dstnode._nid )
    end
  elseif idtype == 'type' then
    if eid._graph == self and edgeexists( eid._srcnid, eid._dstnid ) then return eid end
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

graph_t.node_t = struct( {}, '_graph', false, '_nid', false )

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

graph_t.edge_t = struct( {}, '_graph', false, '_srcnid', false, '_dstnid', false )

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
