local struct = require( 'struct' )
local table_t = require( 'table_t' )
local util = require( 'util' )

--[[ Constructor ]]--

local graph_t = struct( {},
  '_nlabelsunique', false,
  '_elabelsunique', false,
  '_nodes', {},
  '_edges', {labels={}, outgoing={}, incoming={}},
  '_nlabels', table_t({}),
  '_elabels', table_t({}),
  '_nextnid', 1
)

--[[ Operators ]]--

function graph_t.__tostring( self )
  local graphstr = {}

  local headerstr = { 'Graph {', '', '|', '', '} [', '', '|', '', ']:' }
  headerstr[2] = self._nlabelsunique and 'U' or 'D'
  headerstr[4] = self._elabelsunique and 'U' or 'D'
  headerstr[6] = tostring( #self:querynodes() )
  headerstr[8] = tostring( #self:queryedges() )
  table.insert( graphstr, table.concat(headerstr, '') )

  for nid, nlabel in pairs( self._nodes ) do
    local nodestr = { '  ', nlabel, ' [', nid, ']' }
    local edgestr = {}
    for did, elabel in pairs( self._edges.labels[nid] ) do
      local nodestr = self._nodes[did] .. ' [' .. did .. ']'
      table.insert( edgestr, '( ' .. elabel .. ', ' .. nodestr .. ')' )
    end

    nodestr, edgestr = table.concat( nodestr, '' ), table.concat( edgestr, ', ' )
    table.insert( graphstr, table.concat({nodestr, ' : { ', edgestr, ' }'}) )
  end

  return table.concat( graphstr, '\n' )
end

--[[ Public Functions ]]--

function graph_t.addnode( self, nlabel )
  if self._nlabelsunique and #self._nlabels[nlabel] ~= 0 then
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

function graph_t.addedge( self, srcnode, dstnode, elabel, bielabel )
  if bielabel ~= nil then self:addedge( dstnode, srcnode, bielabel ) end

  local srcnode, dstnode = self:findnode( srcnode ), self:findnode( dstnode )
  if srcnode and dstnode then
    self:removeedge( srcnode, dstnode )
    if self._elabelsunique and #self._elabels[elabel] ~= 0 then
      self:removeedge( elabel )
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

function graph_t.removenode( self, node )
  local node = self:findnode( node )
  if node then
    local inedges, outedges = node:getinedges(), node:getoutedges()
    for _, ie in ipairs( inedges ) do
      self:removeedge( ie )
    end
    for _, oe in ipairs( outedges ) do
      self:removeedge( oe )
    end

    util.lsub( self._nlabels[node:getlabel()], node._nid )
    self._nodes[node._nid] = nil
    self._edges.labels[node._nid] = nil
    self._edges.outgoing[node._nid] = nil
    self._edges.incoming[node._nid] = nil
  end
end

function graph_t.removeedge( self, ... )
  local edge = self:findedge( ... )
  if edge then
    util.lsub( self._elabels[edge:getlabel()], edge._srcnid .. '-' .. edge._dstnid )
    self._edges.labels[edge._srcnid][edge._dstnid] = nil
    self._edges.outgoing[edge._srcnid][edge._dstnid] = nil
    self._edges.incoming[edge._dstnid][edge._srcnid] = nil
  end
end

function graph_t.findnode( self, node )
  local nodeid = string.match( tostring(node), '^@(%d+)$' )

  -- node_t argument --
  if getmetatable( node ) == graph_t.node_t then
    if node._graph == self and self._nodes[node._nid] ~= nil then return node end
  -- id argument --
  elseif nodeid ~= nil then
    local nodeid = tonumber( nodeid )
    if self._nodes[nodeid] ~= nil then return graph_t.node_t( self, nodeid ) end
  -- label argument --
  else
    local nodeids = self._nlabels[node]
    if #nodeids ~= 0 then return graph_t.node_t( self, nodeids[1] ) end
  end
end

function graph_t.findedge( self, ... )
  function edgeexists( srcnid, dstnid )
    return self._edges.outgoing[srcnid] ~= nil and
      self._edges.outgoing[srcnid][dstnid] ~= nil
  end

  local args = { ... }
  if #args == 1 then
    -- edge_t argument --
    if getmetatable( args[1] ) == graph_t.edge_t then
      local srcnid, dstnid = args[1]._srcnid, args[1]._dstnid
      if args[1]._graph == self and edgeexists( srcnid, dstnid ) then
        return args[1]
      end
    -- label argument --
    else
      local edgeids = self._elabels[args[1]]
      if #edgeids ~= 0 then
        local srcnid, dstnid = string.match( edgeids[1], '^(%d+)-(%d+)$' )
        return graph_t.edge_t( self, tonumber(srcnid), tonumber(dstnid) )
      end
    end
  -- nodes argument --
  elseif #args == 2 then
    local srcnode, dstnode = self:findnode( args[1] ), self:findnode( args[2] )
    if srcnode and dstnode and edgeexists( srcnode._nid, dstnode._nid) then
      return graph_t.edge_t( self, srcnode._nid, dstnode._nid )
    end
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

function graph_t.node_t.getid( self )
  return table.concat( {'@', tostring(self._nid)} )
end

function graph_t.node_t.getlabel( self )
  return self._graph._nodes[self._nid] 
end

function graph_t.node_t.getoutedges( self )
  local outedges = {}
  for dstnid in pairs( self._graph._edges.outgoing[self._nid] ) do
    table.insert( outedges, graph_t.edge_t(self._graph, self._nid, dstnid) )
  end
  return outedges
end

function graph_t.node_t.getinedges( self )
  local inedges = {}
  for srcnid in pairs( self._graph._edges.incoming[self._nid] ) do
    table.insert( inedges, graph_t.edge_t(self._graph, srcnid, self._nid) )
  end
  return inedges
end

graph_t.edge_t = struct( {}, '_graph', false, '_srcnid', false, '_dstnid', false )

function graph_t.edge_t.__eq( self, other )
  return self._graph == other._graph and self._srcnid == other._srcnid and
    self._dstnid == other._dstnid
end

function graph_t.edge_t.getid( self )
  return table.concat( {'@', tostring(self._srcnid), '-', tostring(self._dstnid)} )
end

function graph_t.edge_t.getlabel( self )
  return self._graph._edges.labels[self._srcnid][self._dstnid]
end

function graph_t.edge_t.getsrc( self )
  return graph_t.node_t( self._graph, self._srcnid )
end

function graph_t.edge_t.getdst( self )
  return graph_t.node_t( self._graph, self._dstnid )
end

return graph_t
