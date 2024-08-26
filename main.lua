local tileSize = 8
local tiles = {}
local palette = {
  x = 0,
  y = 0,
  tileSize = tileSize,
  cols = 0,
  rows = 0,
  count = 0,
  hoverX = 0,
  hoverY = 0,
  ---@type (love.Image | nil)[]
  tiles = {}
}

---@return nil
local function loadPalette()
  local palettePath = "design/terrain.png"
  local info = love.filesystem.getInfo(palettePath)
  ---@type (love.ImageData | nil)[]
  local data = {}

  if info then
    local paletteImage = love.image.newImageData(palettePath)
    local w = paletteImage:getWidth()
    local h = paletteImage:getHeight()
    local cw = w / tileSize

    for y = 0, h - 1 do
      for x = 0, w - 1 do
        local r, g, b, a = paletteImage:getPixel(x, y)
        local cx, cy = math.floor(x / tileSize), math.floor(y / tileSize)
        local px, py = x % tileSize, y % tileSize
        local cp = cw * cy + cx

        if data[cp] == nil then
          data[cp] = love.image.newImageData(tileSize, tileSize)
        end

        data[cp]:setPixel(px, py, r, g, b, a)
        palette.cols = cx + 1
        palette.rows = cy + 1
      end
    end
  else
    error("Could not find file info for " .. palettePath)
  end

  for i, imgd in pairs(data) do
    palette.tiles[i] = love.graphics.newImage(imgd)
    palette.count = palette.count + 1
  end
end

local function drawPalette()
  for i, t in pairs(palette.tiles) do
    local tx = i % palette.cols
    local ty = math.floor(i / palette.cols)
    love.graphics.draw(t, palette.x + tx * palette.tileSize, palette.y + ty * palette.tileSize)
  end
  if palette.hoverX >= 0 and palette.hoverX < palette.cols and palette.hoverY >= 0 and palette.hoverY < palette.rows then
    love.graphics.setColor(1, 0, 1, 1)
    love.graphics.rectangle("line", palette.hoverX * palette.tileSize, palette.hoverY * palette.tileSize,
      palette.tileSize, palette.tileSize)
    love.graphics.setColor(1, 1, 1, 1)
  end
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("line", palette.x, palette.y, palette.cols * palette.tileSize, palette.rows * palette.tileSize)
  love.graphics.setColor(1, 1, 1, 1)
end

---Sets the palette coordinates for mouse hover
---@param mx number Mouse x position
---@param my number Mouse Y position
local function setPaletteHover(mx, my)
  palette.hoverX = math.floor(mx / palette.tileSize)
  palette.hoverY = math.floor(my / palette.tileSize)
end

function love.load()
  print("loading...")
  print("loading palette...")
  loadPalette()
  print("ready!")
end

function love.draw()
  love.graphics.setBackgroundColor(0.8, 0.8, 0.8, 1)
  drawPalette()
end

function love.update()
  local mx, my = love.mouse.getPosition()
  setPaletteHover(mx, my)
end
