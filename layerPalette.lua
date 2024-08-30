local layerPalette = {
  x = 0,
  y = 0,
  hoverLayer = 1,
  tileSize = 32
}

function layerPalette.setup()
  layerPalette.x = love.graphics.getWidth() - layerPalette.tileSize * Layers
  layerPalette.y = love.graphics.getHeight() - layerPalette.tileSize
end

---@param currentLayer integer
function layerPalette.draw(currentLayer)
  local w = layerPalette.tileSize
  local h = layerPalette.tileSize
  local y = love.graphics.getHeight() - h

  for l = 0, Layers - 1 do
    local x = layerPalette.x + l * layerPalette.tileSize
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("" .. l + 1, x + 12, y + 8)
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("line", x, y, w, h)
  end

  local activeLayerX = love.graphics.getWidth() - w * (Layers - currentLayer + 1)
  love.graphics.setColor(1, 0, 1, 0.1)
  love.graphics.rectangle("fill", activeLayerX, y, w, h)
  love.graphics.setColor(1, 0, 1, 1)
  love.graphics.rectangle("line", activeLayerX, y, w, h)

  local hoverLayerX = layerPalette.x + (layerPalette.hoverLayer - 1) * w
  love.graphics.setColor(1, 0, 1, 1)
  love.graphics.rectangle("line", hoverLayerX, y, w, h)
end

---Sets the hover coordinates for the layer palette
---@param mx integer Mouse x position
---@param my integer Mouse Y position
---@return boolean flag if the palette was hovered
function layerPalette.setHover(mx, my)
  local r = love.graphics.getWidth()
  local b = love.graphics.getHeight()
  local flag = false

  if mx >= layerPalette.x and mx < r and my >= layerPalette.y and my < b then
    layerPalette.hoverLayer = math.floor((mx - layerPalette.x) / layerPalette.tileSize) + 1
    flag = true
  end

  return flag
end

---Checks if mouse click happened within
---layer palette and returns selected layer.
---@param mx integer Mouse x position
---@param my integer Mouse Y position
---@return integer selected
function layerPalette.select(mx, my)
  local r = love.graphics.getWidth()
  local b = love.graphics.getHeight()
  local selected = 0

  if mx >= layerPalette.x and mx < r and my >= layerPalette.y and my < b then
    selected = layerPalette.hoverLayer
  end

  return selected
end

return layerPalette
