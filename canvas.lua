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
    canvas.tiles[tp] = tindex
  end
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
  love.graphics.rectangle("line", canvas.hoverX * canvas.tileSize, canvas.hoverY * canvas.tileSize,
    canvas.tileSize, canvas.tileSize)

  -- reset color
  love.graphics.setColor(1, 1, 1, 1)
end

---Sets the canvas coordinates for mouse hover
---@param mx integer Mouse x position
---@param my integer Mouse Y position
---@return boolean flag if the canvas was hovered
function canvas.setCanvasHover(mx, my)
  local r = canvas.x + canvas.cols * canvas.tileSize
  local b = canvas.y + canvas.rows * canvas.tileSize
  local flag = false

  if mx >= canvas.x and mx < r and my >= canvas.y and my < b then
    canvas.hoverX = math.floor(mx / canvas.tileSize)
    canvas.hoverY = math.floor(my / canvas.tileSize)
    flag = true
  end

  return flag
end

function canvas.moveCanvas(dx, dy)
  canvas.x = canvas.x + dx
  canvas.y = canvas.y + dy
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
