---@class Palette
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
  showMeta = false,
  ---@type (love.Image | nil)[]
  tiles = {}
}

---Load palette image data into a data object.
---@param path string Path to image file
---@param ts integer Tile size for palette
---@return nil
function palette.loadPalette(path, ts)
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

function palette.drawPalette()
  -- draw palette border
  local borderSize = 4
  love.graphics.setColor(0.8, 0.8, 0.8, 1)
  love.graphics.rectangle("fill", palette.x - borderSize, palette.y - borderSize,
    palette.x + palette.cols * palette.tileSize + borderSize * 2,
    palette.y + palette.rows * palette.tileSize + borderSize * 2)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("line", palette.x - borderSize, palette.y - borderSize,
    palette.x + palette.cols * palette.tileSize + borderSize * 2,
    palette.y + palette.rows * palette.tileSize + borderSize * 2)
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

  -- show meta tooltip
  if palette.showMeta then
    love.graphics.setColor(1, 0, 1, 1)
    local tidx = palette.hoverY * palette.cols + palette.hoverX
    local x = palette.x + palette.hoverX * palette.tileSize
    local y = palette.y + palette.hoverY * palette.tileSize
    love.graphics.print(tidx .. " : " .. palette.hoverX .. ", " .. palette.hoverY, x, y + palette.tileSize)
  end

  -- reset color
  love.graphics.setColor(1, 1, 1, 1)
end

---@return integer[][]
function palette.getSelectedTiles()
  return {
    {
      palette.selectY * palette.cols + palette.selectX,
      (palette.selectY) * palette.cols + palette.selectX + 1,
    },
    {
      (palette.selectY + 1) * palette.cols + palette.selectX,
      (palette.selectY + 1) * palette.cols + palette.selectX + 1,
    }
  }
end

---Sets the palette coordinates for mouse hover
---@param mx integer Mouse x position
---@param my integer Mouse Y position
---@return boolean flag if the palette was hovered
function palette.setPaletteHover(mx, my)
  local r = palette.x + palette.cols * palette.tileSize
  local b = palette.y + palette.rows * palette.tileSize
  local flag = false

  if mx >= palette.x and mx < r and my >= palette.y and my < b then
    palette.hoverX = math.floor(mx / palette.tileSize)
    palette.hoverY = math.floor(my / palette.tileSize)
    flag = true
  end

  return flag
end

---Sets the palette coordinates for mouse select
---@param mx integer Mouse x position
---@param my integer Mouse y position
---@return boolean flag if palette was clicked
function palette.setPaletteSelect(mx, my)
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

return palette
