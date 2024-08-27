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
  ---Palette indexes
  ---@type integer[]
  tiles = {}
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

---@param mx integer Mouse x position
---@param my integer Mouse y position
---@param tindex integer Tile index
function canvas.insertCanvasTile(mx, my, tindex)
  local x, y = mx - canvas.x, my - canvas.y
  local r = canvas.cols * canvas.tileSize
  local b = canvas.rows * canvas.tileSize

  if x >= 0 and x < r and y >= 0 and y < b then
    local tx, ty = math.floor(x / canvas.tileSize), math.floor(y / canvas.tileSize)
    local tp = ty * canvas.cols + tx
    canvas.tiles[tp + 1] = tindex
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
  for i, _ in pairs(canvas.tiles) do
    local pi = i - 1
    local x = (pi % canvas.cols) + 1
    local y = ((pi - x) / canvas.cols) + 1
    if x > canvas.selectRectStart.x and x <= canvas.selectRectEnd.x and y > canvas.selectRectStart.y and y <= canvas.selectRectEnd.y then
      canvas.tiles[i] = tindex
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

  love.graphics.setColor(1, 1, 1, 1)
  for i, tindex in pairs(canvas.tiles) do
    if tindex ~= nil then
      local tile = ptiles[tindex]
      if tile ~= nil then
        local pi = i - 1
        local x = pi % canvas.cols
        local y = (pi - x) / canvas.cols
        love.graphics.draw(tile, canvas.x + x * canvas.tileSize, canvas.y + y * canvas.tileSize)
      end
    end
  end

  -- draw hover box
  love.graphics.setColor(1, 0, 1, 1)
  love.graphics.rectangle("line", canvas.x + canvas.hoverX * canvas.tileSize, canvas.y + canvas.hoverY * canvas.tileSize,
    canvas.tileSize, canvas.tileSize)

  -- draw select rect
  if canvas.selectRectStart and canvas.selectRectEnd then
    love.graphics.setColor(1, 0, 1, 0.1)
    love.graphics.rectangle("fill", canvas.x + canvas.selectRectStart.x * canvas.tileSize,
      canvas.y + canvas.selectRectStart.y * canvas.tileSize,
      (canvas.selectRectEnd.x - canvas.selectRectStart.x) * canvas.tileSize,
      (canvas.selectRectEnd.y - canvas.selectRectStart.y) * canvas.tileSize)
    love.graphics.setColor(1, 0, 1, 1)
    love.graphics.rectangle("line", canvas.x + canvas.selectRectStart.x * canvas.tileSize,
      canvas.y + canvas.selectRectStart.y * canvas.tileSize,
      (canvas.selectRectEnd.x - canvas.selectRectStart.x) * canvas.tileSize,
      (canvas.selectRectEnd.y - canvas.selectRectStart.y) * canvas.tileSize)
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
  for i, _ in pairs(canvas.tiles) do
    if i <= canvas.cols * canvas.rows then
      canvas.tiles[i] = tindex
    end
  end
end

---@return nil|love.Data
function canvas.serialize()
  local d = {}
  local fmt = ""

  for y = 0, canvas.rows - 1 do
    for x = 0, canvas.cols - 1 do
      local i = y * canvas.cols + x
      local tindex = canvas.tiles[i + 1]
      if not tindex or tindex == nil then
        d[i + 1] = 0
      else
        d[i + 1] = tindex
      end
      fmt = fmt .. "<I"
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

  for _ = 1, canvas.rows do
    for _ = 1, canvas.cols do
      fmt = fmt .. "<I"
    end
  end

  local tiles = { love.data.unpack(fmt, data) }
  canvas.tiles = tiles
end

return canvas
