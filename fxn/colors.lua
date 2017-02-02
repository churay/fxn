local colors = {}

--[[ Color Values ]]--

colors.table = {}

colors.table.red     = { 255,   0,   0 }
colors.table.green   = {   0, 255,   0 }
colors.table.blue    = {   0,   0, 255 }
colors.table.yellow  = { 255, 255,   0 }
colors.table.magenta = { 255,   0, 255 }
colors.table.white   = { 255, 255, 255 }
colors.table.black   = {   0,   0,   0 }

colors.table.lgray   = { 177, 177, 177 }
colors.table.dgray   = {  77,  77,  77 }

--[[ Color Functions ]]--

function colors.tuple( name, alpha )
  local color = colors.table[name]
  return color[1], color[2], color[3], alpha
end

return colors
