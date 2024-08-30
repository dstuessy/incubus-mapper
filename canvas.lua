local canvas = {
  x = 0,
  y = 0,
  tileSize = 0,
  cols = 0,
  rows = 0,
  hoverX = 0,
  hoverY = 0,
  selectX = 0,
  selectY = 0,
  ---@type nil|number[]
  selectRectStart = nil,
  ---@type nil|number[]
  selectRectEnd = nil,
  showMeta = false,
  currentLayer = 1,
  ---Palette indexes
  ---@type integer[][]
  tiles = {
    {},
    {},
    {}
  }
}

function canvas.setupCanvas()
  local w, h = love.graphics.getDimensions()
  local size = RoomSize * TileSize

  canvas.tileSize = TileSize
  canvas.cols = RoomSize
  canvas.rows = RoomSize
  canvas.x = w / 2 - size / 2
  canvas.y = h / 2 - size / 2
end

function canvas.getCurrentLayer()
  return canvas.tiles[canvas.currentLayer]
end

---@param mx integer Mouse x position
---@param my integer Mouse y position
---@param tindex integer Tile index
function canvas.insertCanvasTile(mx, my, tindex)
  local x, y = mx - canvas.x, my - canvas.y
  local r = canvas.cols * canvas.tileSize
  local b = canvas.rows * canvas.tileSize

  local layer = canvas.getCurrentLayer()
  if not layer then
    return
  end

  if x >= 0 and x < r and y >= 0 and y < b then
    local tx, ty = math.floor(x / canvas.tileSize), math.floor(y / canvas.tileSize)
    local tp = ty * canvas.cols + tx
    layer[tp + 1] = tindex
    canvas.selectX, canvas.selectY = tx, ty
  end
end

---@param mx integer Mouse x position
---@param my integer Mouse y position
function canvas.setSelectRectStart(mx, my)
  local x, y = mx - canvas.x, my - canvas.y
  local r = canvas.cols * canvas.tileSize
  local b = canvas.rows * canvas.tileSize

  if x >= 0 and x < r and y >= 0 and y < b then
    local tx, ty = math.floor(x / canvas.tileSize), math.floor(y / canvas.tileSize)
    canvas.selectRectStart = {
      x = tx,
      y = ty
    }
  end
end

---@param mx integer Mouse x position
---@param my integer Mouse y position
function canvas.setSelectRectEnd(mx, my)
  local x, y = mx - canvas.x, my - canvas.y
  local r = canvas.cols * canvas.tileSize
  local b = canvas.rows * canvas.tileSize

  if x >= 0 and x < r and y >= 0 and y < b then
    local tx, ty = math.floor(x / canvas.tileSize), math.floor(y / canvas.tileSize)
    canvas.selectRectEnd = {
      x = tx,
      y = ty
    }
  end
end

---@param tindex integer Tile index
function canvas.fillSelectRect(tindex)
  local layer = canvas.getCurrentLayer()
  for i, _ in pairs(layer) do
    local pi = i - 1
    local x = (pi % canvas.cols)
    local y = ((pi - x) / canvas.cols)

    local minx = math.min(canvas.selectRectStart.x, canvas.selectRectEnd.x)
    local miny = math.min(canvas.selectRectStart.y, canvas.selectRectEnd.y)
    local maxx = math.max(canvas.selectRectStart.x, canvas.selectRectEnd.x)
    local maxy = math.max(canvas.selectRectStart.y, canvas.selectRectEnd.y)

    if x >= minx and x <= maxx and y >= miny and y <= maxy then
      layer[i] = tindex
    end
  end
end

function canvas.clearSelectRect()
  canvas.selectRectStart = nil
  canvas.selectRectEnd = nil
end

---@param ptiles (love.Image | nil)[] Palette tiles
function canvas.drawCanvas(ptiles)
  -- draw canvas bg
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("fill", canvas.x, canvas.y, canvas.cols * canvas.tileSize,
    canvas.rows * canvas.tileSize)

  for li, layer in pairs(canvas.tiles) do
    if li <= canvas.currentLayer then
      for i, tindex in pairs(layer) do
        if tindex ~= nil then
          local tile = ptiles[tindex]
          if tile ~= nil then
            local pi = i - 1
            local x = pi % canvas.cols
            local y = (pi - x) / canvas.cols
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(tile, canvas.x + x * canvas.tileSize, canvas.y + y * canvas.tileSize)
          end
        end
      end
    end
  end

  -- draw hover box
  love.graphics.setColor(1, 0, 1, 1)
  love.graphics.rectangle("line", canvas.x + canvas.hoverX * canvas.tileSize, canvas.y + canvas.hoverY * canvas.tileSize,
    canvas.tileSize, canvas.tileSize)
  -- show tile index
  if canvas.showMeta then
    local x = canvas.x + canvas.hoverX * canvas.tileSize
    local y = canvas.y + (canvas.hoverY - 1) * canvas.tileSize
    love.graphics.print(canvas.hoverX .. ", " .. canvas.hoverY, x, y)
  end

  -- draw select rect
  if canvas.selectRectStart and canvas.selectRectEnd then
    local minx = math.min(canvas.selectRectEnd.x, canvas.selectRectStart.x)
    local maxx = math.max(canvas.selectRectEnd.x, canvas.selectRectStart.x)

    local miny = math.min(canvas.selectRectEnd.y, canvas.selectRectStart.y)
    local maxy = math.max(canvas.selectRectEnd.y, canvas.selectRectStart.y)

    love.graphics.setColor(1, 0, 1, 0.1)
    love.graphics.rectangle("fill", canvas.x + minx * canvas.tileSize,
      canvas.y + miny * canvas.tileSize,
      (maxx - minx + 1) * canvas.tileSize,
      (maxy - miny + 1) * canvas.tileSize)
    love.graphics.setColor(1, 0, 1, 1)
    love.graphics.rectangle("line", canvas.x + minx * canvas.tileSize,
      canvas.y + miny * canvas.tileSize,
      (maxx - minx + 1) * canvas.tileSize,
      (maxy - miny + 1) * canvas.tileSize)
  end

  -- reset color
  love.graphics.setColor(1, 1, 1, 1)
end

---Sets the canvas coordinates for mouse hover
---@param mx integer Mouse x position
---@param my integer Mouse Y position
---@return boolean flag if the canvas was hovered
function canvas.setCanvasHover(mx, my)
  local x, y = mx - canvas.x, my - canvas.y
  local r = canvas.cols * canvas.tileSize
  local b = canvas.rows * canvas.tileSize
  local flag = false

  if x >= 0 and x < r and y >= 0 and y < b then
    canvas.hoverX = math.floor(x / canvas.tileSize)
    canvas.hoverY = math.floor(y / canvas.tileSize)
    flag = true
  end

  return flag
end

function canvas.moveCanvas(dx, dy)
  canvas.x = canvas.x + dx
  canvas.y = canvas.y + dy
end

---Fill the entire canvas with
---the given tile index.
---@param tindex number
function canvas.fillCanvas(tindex)
  local layer = canvas.getCurrentLayer()
  local maxidx = canvas.cols * canvas.rows

  for i = 1, maxidx do
    layer[i] = tindex
  end
end

---@return nil|love.Data
function canvas.serialize()
  ---@type integer[]
  local d = {}
  local fmt = ""

  for li = 0, Layers - 1 do
    for y = 0, canvas.rows - 1 do
      for x = 0, canvas.cols - 1 do
        local i = y * canvas.cols + x
        local tindex = canvas.tiles[li + 1][i + 1]
        if not tindex or tindex == nil then
          table.insert(d, 0)
        else
          table.insert(d, tindex)
        end
        fmt = fmt .. "<I1"
      end
    end
  end

  local data = love.data.pack("data", fmt, unpack(d))

  if type(data) == "string" then
    return nil
  end

  return data
end

---@param data string|love.Data
function canvas.load(data)
  local fmt = ""

  for _ = 1, canvas.rows * Layers do
    for _ = 1, canvas.cols do
      fmt = fmt .. "<I1"
    end
  end

  ---@type integer[][]
  local tiles = {
    {},
    {},
    {}
  }

  local d = { love.data.unpack(fmt, data) }

  -- avoid the last two entries from unpack
  -- because they are the first index and
  -- the size of the data, not data itself
  for i = 1, #d - 2 do
    local t = d[i]
    if type(t) == "number" then
      local l = math.floor(math.floor(i / canvas.cols) / canvas.rows)
      local li = i - (l * canvas.rows) * canvas.cols
      tiles[l + 1][li] = math.floor(t)
    end
  end

  canvas.tiles = tiles
end

return canvas
