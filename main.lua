TileSize = 16
RoomSize = 32

local palette = {
  x = 0,
  y = 0,
  tileSize = 0,
  cols = 0,
  rows = 0,
  count = 0,
  hoverX = 0,
  hoverY = 0,
  selectX = 0,
  selectY = 0,
  ---@type (love.Image | nil)[]
  tiles = {}
}

---Load palette image data into a data object.
---@param path string Path to image file
---@param ts integer Tile size for palette
---@return nil
local function loadPalette(path, ts)
  ---@type (love.ImageData | nil)[]
  local data = {}
  local info = love.filesystem.getInfo(path)

  if info then
    local paletteImage = love.image.newImageData(path)
    local w = paletteImage:getWidth()
    local h = paletteImage:getHeight()
    local cw = w / ts

    for y = 0, h - 1 do
      for x = 0, w - 1 do
        local r, g, b, a = paletteImage:getPixel(x, y)
        local cx, cy = math.floor(x / ts), math.floor(y / ts)
        local px, py = x % ts, y % ts
        local cp = cw * cy + cx

        if data[cp] == nil then
          data[cp] = love.image.newImageData(ts, ts)
        end

        data[cp]:setPixel(px, py, r, g, b, a)
        palette.cols = cx + 1
        palette.rows = cy + 1
      end
    end
  else
    error("Could not find file info for " .. path)
  end

  for i, imgd in pairs(data) do
    palette.tiles[i] = love.graphics.newImage(imgd)
    palette.count = palette.count + 1
  end

  palette.tileSize = ts
end

local function drawPalette()
  -- draw palette bg
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("fill", palette.x, palette.y, palette.x + palette.cols * palette.tileSize,
    palette.y + palette.rows * palette.tileSize)

  -- draw palette tiles
  love.graphics.setColor(1, 1, 1, 1)
  for i, t in pairs(palette.tiles) do
    local tx = i % palette.cols
    local ty = math.floor(i / palette.cols)
    love.graphics.draw(t, palette.x + tx * palette.tileSize, palette.y + ty * palette.tileSize)
  end

  -- draw hover box
  love.graphics.setColor(1, 0, 1, 1)
  love.graphics.rectangle("line", palette.hoverX * palette.tileSize, palette.hoverY * palette.tileSize,
    palette.tileSize, palette.tileSize)

  -- draw select box
  love.graphics.setColor(1, 0, 1, 0.2)
  love.graphics.rectangle("fill", palette.selectX * palette.tileSize, palette.selectY * palette.tileSize,
    palette.tileSize, palette.tileSize)
  love.graphics.setColor(1, 0, 1, 1)
  love.graphics.rectangle("line", palette.selectX * palette.tileSize, palette.selectY * palette.tileSize,
    palette.tileSize, palette.tileSize)

  -- draw palette border
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("line", palette.x, palette.y, palette.x + palette.cols * palette.tileSize,
    palette.y + palette.rows * palette.tileSize)

  -- reset color
  love.graphics.setColor(1, 1, 1, 1)
end

---Sets the palette coordinates for mouse hover
---@param mx integer Mouse x position
---@param my integer Mouse Y position
local function setPaletteHover(mx, my)
  local r = palette.x + palette.cols * palette.tileSize
  local b = palette.y + palette.rows * palette.tileSize

  if mx >= palette.x and mx < r and my >= palette.y and my < b then
    palette.hoverX = math.floor(mx / palette.tileSize)
    palette.hoverY = math.floor(my / palette.tileSize)
  end
end

---Sets the palette coordinates for mouse select
---@param mx integer Mouse x position
---@param my integer Mouse y position
---@return boolean flag if palette was clicked
local function setPaletteSelect(mx, my)
  local flag = false
  local w = palette.cols * palette.tileSize
  local h = palette.rows * palette.tileSize

  if mx >= palette.x and mx < palette.x + w and my >= palette.y and my < palette.y + h then
    palette.selectX = math.floor(mx / palette.tileSize)
    palette.selectY = math.floor(my / palette.tileSize)
    flag = true
  end

  return flag
end

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

local function setupCanvas()
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
local function insertCanvasTile(mx, my, tindex)
  local x, y = mx - canvas.x, my - canvas.y
  local r = canvas.cols * canvas.tileSize
  local b = canvas.rows * canvas.tileSize

  if x >= 0 and x < r and y >= 0 and y < b then
    local tx, ty = math.floor(x / canvas.tileSize), math.floor(y / canvas.tileSize)
    local tp = ty * canvas.cols + tx
    canvas.tiles[tp] = tindex
  end
end

local function drawCanvas()
  -- draw canvas bg
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("fill", canvas.x, canvas.y, canvas.cols * canvas.tileSize,
    canvas.rows * canvas.tileSize)

  love.graphics.setColor(1, 1, 1, 1)
  for i, tindex in pairs(canvas.tiles) do
    if tindex ~= nil then
      local tile = palette.tiles[tindex]
      if tile ~= nil then
        local x = i % canvas.cols
        local y = (i - x) / canvas.cols
        love.graphics.draw(tile, canvas.x + x * canvas.tileSize, canvas.y + y * canvas.tileSize)
      end
    end
  end

  -- reset color
  love.graphics.setColor(1, 1, 1, 1)
end

function love.load()
  print("loading...")
  print("loading palette...")
  loadPalette("design/terrain.png", TileSize)
  print("setting up canvas...")
  setupCanvas()
  print("ready!")
end

function love.draw()
  love.graphics.reset()
  love.graphics.setBackgroundColor(0.8, 0.8, 0.8, 1)
  drawCanvas()
  drawPalette()
end

function love.update()
  local mx, my = love.mouse.getPosition()

  setPaletteHover(mx, my)

  if love.mouse.isDown(1) then
    local paletteSelected = setPaletteSelect(mx, my)

    if not paletteSelected then
      local tindex = palette.selectY * palette.cols + palette.selectX
      insertCanvasTile(mx, my, tindex)
    end
  end
end
