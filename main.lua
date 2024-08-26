local palette = require("palette")
local canvas = require("canvas")

TileSize = 16
RoomSize = 32

function love.load()
  print("loading...")
  print("loading palette...")
  palette.loadPalette("design/terrain.png", TileSize)
  print("setting up canvas...")
  canvas.setupCanvas()
  print("ready!")
end

function love.draw()
  love.graphics.reset()
  love.graphics.setBackgroundColor(0.8, 0.8, 0.8, 1)
  canvas.drawCanvas(palette.tiles)
  palette.drawPalette()
end

local pmx, pmy = 0, 0

function love.update()
  local mx, my = love.mouse.getPosition()

  palette.setPaletteHover(mx, my)

  if love.mouse.isDown(1) then
    local paletteSelected = palette.setPaletteSelect(mx, my)

    if not paletteSelected then
      local tindex = palette.selectY * palette.cols + palette.selectX
      canvas.insertCanvasTile(mx, my, tindex)
    end
  elseif love.mouse.isDown(2) then
    canvas.moveCanvas(mx - pmx, my - pmy)
  end

  pmx, pmy = mx, my
end
