local struct = require( 'struct' )
local graph_t = require( 'graph_t' )
local colors = require( 'colors' )
local util = require( 'util' )

-- TODO(JRC): This code could be extended in to make more general types of
-- boards possible by abstracting out the concepts of tiles and directions.
-- - Tile: A space on the board that's inhabitable by a piece.  The shape of
--   this tile will be determined first by its default number of connections
--   (e.g. 4 connections implies a square) and second by overriding factors.
-- - Direction: An abstract relationship between tiles that indicates how a
--   piece may traverse from one tile to another.  These could be interpretted
--   as directions or more abstractly as enumerations with defined relationships.

--[[ Constructor ]]--

local board_t = struct( {}, '_graph', graph_t(), '_cells', {}, 'width', 0, 'height', 0 )

function board_t._init( self, width, height )
  self._graph = graph_t( true, false )
  self._cells = {}
  self.width, self.height = width, height

  -- insert all cells into the graph --
  for celly = 1, self.height do
    for cellx = 1, self.width do
      local cellidx = self:_getcellidx( cellx, celly )
      self._graph:addnode( cellidx )
      self._cells[cellidx] = false
    end
  end

  -- add connections between 'adjacent' cells --
  local function genlabel( cellf, cellt )
    local cellfx, cellfy = self:_getcellpos( cellf )
    local celltx, cellty = self:_getcellpos( cellt )

    local label = ''
    if celltx - cellfx > 0 then label = label .. '+x'
    elseif celltx - cellfx < 0 then label = label .. '-x' end
    if cellty - cellfy > 0 then label = label .. '+y'
    elseif cellty - cellfy < 0 then label = label .. '-y' end

    return label
  end

  for celly = 1, self.height do
    for cellx = 1, self.width do
      local cellidx = self:_getcellidx( cellx, celly )

      for celldv = -1, 1, 2 do
        for celldir = 1, 2, 1 do
          local celldx, celldy = 0, 0
          if celldir == 1 then celldy = celldv else celldx = celldv end
          local adjx, adjy = cellx + celldx, celly + celldy

          if self:_iscellvalid( adjx, adjy ) then
            local adjcellidx = self:_getcellidx( adjx, adjy )
            self._graph:addedge( cellidx, adjcellidx,
              genlabel(cellidx, adjcellidx) )
          end
        end
      end
    end
  end
end

--[[ Public Data Functions ]]--

function board_t.addpiece( self, piece, cellidx )
  self._cells[cellidx] = piece
end

function board_t.removepiece( self, cellidx )
  local piece = self._cells[cellidx]
  self._cells[cellidx] = false
  return piece
end

function board_t.getpiece( self, cellidx )
  return self._cells[cellidx]
end

function board_t.movepiece( self, srccellidx, dstcellidx )
  local piecemoves = self:getpiecemoves( srccellidx )

  if piecemoves[dstcellidx] then
    self._cells[dstcellidx] = self._cells[srccellidx]
    self._cells[srccellidx] = false
  end

  return piecemoves[dstcellidx]
end

function board_t.getpiecemoves( self, cellidx )
  local function getmoves( currcell, activesteps, activemaxs, moveiter )
    local moves = {}
    if not self:_iscellvalid( cellidx ) or #activesteps == 0 then return moves end

    local currnode = self._graph:findnode( currcell )
    for _, celledge in ipairs( currnode:getoutedges() ) do
      local nextcell = celledge:getdst():getlabel()
      local tonextlabel = celledge:getlabel()

      local nextsteps, nextmaxs = {}, {}
      for stepidx = 1, #activesteps do
        local currstep, currmax = activesteps[stepidx], activemaxs[stepidx]

        local currstepidx = ( moveiter % #currstep ) + 1
        local currstepcount = math.floor( moveiter / #currstep )

        if moveiter >= #currstep and currstepidx == 1 then
          moves[currcell] = true
        end

        if string.match( tonextlabel, currstep[currstepidx] ) and
            currstepcount < currmax then
          table.insert( nextsteps, currstep )
          table.insert( nextmaxs, currmax )
        end
      end

      local edgemoves = getmoves( nextcell, nextsteps, nextmaxs, moveiter+1 )
      for cell in pairs( edgemoves ) do moves[cell] = true end
    end

    return moves
  end

  local cellsteps = self._cells[cellidx] and self._cells[cellidx]._steps or {}
  local cellstepmaxs = self._cells[cellidx] and self._cells[cellidx]._maxs or {}

  return getmoves( cellidx, cellsteps, cellstepmaxs, 0 )
end

--[[ Public Render Functions ]]--

-- TODO(JRC): Update this function based on the decisions made for the rendering
-- function interface.
function board_t.render( self )
  -- TODO(JRC): The ordering here is a bit hacky and should be removed in the
  -- general 'board_t' version.  These labels should be replaced by incremental
  -- numbers instead with the lowest-lest edge is 0 and increments of 1 CCW.
  local celldirorder = { '-y', '+x', '+y', '-x' }
  local gfxdirtypes = { [0]='impassable', [1]='passable' }

  local gfxcellw, gfxcellh = 1.0 / self.width, 1.0 / self.height
  local gfxedgelen, gfxgridlen = 5e-2, 5e-3

  for celly = 1, self.height do
    for cellx = 1, self.width do
      local cellidx = self:_getcellidx( cellx, celly )
      local celloutedges = self._graph:findnode( cellidx ):getoutedges()

      local celldirbag = {}
      for _, celldir in ipairs( celldirorder ) do celldirbag[celldir] = 1 end

      -- celldirtypes: { direction label => cell direction type } for each direction
      local celldirtypes = {}
      for _, celloutedge in ipairs( celloutedges ) do
        local edgedir = celloutedge:getlabel()
        celldirtypes[edgedir] = 1
        celldirbag[edgedir] = nil
      end

      for noedgedir in pairs( celldirbag ) do celldirtypes[noedgedir] = 0 end

      local gfxcellx, gfxcelly = (cellx - 1) * gfxcellw, (celly - 1) * gfxcellw
      local gfxcornerrads = ( 2 * math.pi ) / util.len( celldirtypes )

      love.graphics.push()
      love.graphics.translate( gfxcellx, gfxcelly )
      love.graphics.scale( gfxcellw, gfxcellh )

      for _, celldir in ipairs( celldirorder ) do
        local dircolor = util.copy( colors.black )
        table.insert( dircolor, celldirtypes[celldir] == 0 and 255 or 64 )

        love.graphics.setColor( util.unpack(dircolor) )
        love.graphics.polygon( 'fill', 0.0, 0.0, 1.0, 0.0,
          1.0 - gfxedgelen, gfxedgelen, gfxedgelen, gfxedgelen )
        love.graphics.setColor( util.unpack(colors.red) )
        love.graphics.polygon( 'fill', 0.0, 0.0, 1.0, 0.0,
          1.0, gfxgridlen, 0.0, gfxgridlen )

        love.graphics.translate( 1.0, 0.0 )
        love.graphics.rotate( gfxcornerrads )
      end

      love.graphics.pop()
    end
  end
end

--[[ Private Functions ]]--

function board_t._getcellidx( self, cellx, celly )
  return self.width * ( celly - 1 ) + cellx
end

function board_t._getcellpos( self, cellidx )
  return ( (cellidx - 1) % self.width ) + 1,
    math.floor( (cellidx - 1) / self.width ) + 1
end

function board_t._iscellvalid( self, cellx, celly )
  if celly == nil then cellx, celly = self:_getcellpos( cellx ) end
  return util.inrange( cellx, 1, self.width ) and
    util.inrange( celly, 1, self.height )
end

--[[ Private Classes ]]--

board_t.piece_t = struct( {}, '_board', false, '_steps', {}, '_maxs', {} )

return board_t
