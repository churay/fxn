local struct = require( 'struct' )
local graph_t = require( 'graph_t' )
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

local board_t = struct( {}, '_graph', graph_t(), '_nodes', {}, '_width', 0, '_height', 0 )

function board_t._init( self, width, height )
  self._graph = graph_t()
  self._nodes = {}
  self._width, self._height = width, height

  -- insert all cells into the graph --
  for celly = 1, self._height do
    for cellx = 1, self._width do
      local cellidx = self:_getcellidx( cellx, celly )
      local cellnode = self._graph:addnode( cellidx )
      table.insert( self._nodes, cellnode )
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

  for celly = 1, self._height do
    for cellx = 1, self._width do
      local cellidx = self:_getcellidx( cellx, celly )

      for celldv = -1, 1, 2 do
        for celldir = 1, 2, 1 do
          local celldx, celldy = 0, 0
          if celldir == 1 then celldy = celldv else celldx = celldv end
          local adjx, adjy = cellx + celldx, celly + celldy

          if self:_iscellvalid( adjx, adjy ) and util.inrange( adjx, 1, self._width ) then
            local adjcellidx = self:_getcellidx( adjx, adjy )
            self._graph:addedge(
              self:_getcellnode( cellidx ),
              self:_getcellnode( adjcellidx ),
              genlabel( cellidx, adjcellidx )
            )
          end
        end
      end
    end
  end
end

--[[ Public Functions ]]--



--[[ Private Functions ]]--

function board_t._getcellnode( self, cellx, celly )
  local cellidx = celly == nil and cellx or self:_getcellidx( cellx, celly )
  return self._nodes[cellidx]
end

function board_t._getcellidx( self, cellx, celly )
  return self._width * ( celly - 1 ) + cellx
end

function board_t._getcellpos( self, cellidx )
  return ( (cellidx - 1) % self._width ) + 1,
    math.floor( (cellidx - 1) / self._width ) + 1
end

function board_t._iscellvalid( self, cellx, celly )
  return util.inrange( self:_getcellidx(cellx, celly), 1, self._width * self._height )
end

return board_t
