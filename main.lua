TileSize = 16
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
  ---@type number[]
  tiles = {}
}
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
---@param ts number Tile size for palette
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
  -- draw palette tiles
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
---@param mx number Mouse x position
---@param my number Mouse Y position
local function setPaletteHover(mx, my)
  local r = palette.x + palette.cols * palette.tileSize
  local b = palette.y + palette.rows * palette.tileSize

  if mx >= palette.x and mx < r and my >= palette.y and my < b then
    palette.hoverX = math.floor(mx / palette.tileSize)
    palette.hoverY = math.floor(my / palette.tileSize)
  end
end

---Sets the palette coordinates for mouse select
---@param mx number Mouse x position
---@param my number Mouse y position
local function setPaletteSelect(mx, my)
  local w = palette.cols * palette.tileSize
  local h = palette.rows * palette.tileSize
  if mx >= palette.x and my < palette.x + w and my >= palette.y and my < palette.y + h then
    palette.selectX = math.floor(mx / palette.tileSize)
    palette.selectY = math.floor(my / palette.tileSize)
  end
end

function love.load()
  print("loading...")
  print("loading palette...")
  loadPalette("design/terrain.png", TileSize)
  print("ready!")
end

function love.draw()
  love.graphics.setBackgroundColor(0.8, 0.8, 0.8, 1)
  drawPalette()
end

function love.update()
  local mx, my = love.mouse.getPosition()

  setPaletteHover(mx, my)

  if love.mouse.isDown(1) then
    setPaletteSelect(mx, my)
  end
end
