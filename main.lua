local palette = require("palette")
local canvas = require("canvas")
local saveButton = require("saveButton")

TileSize = 16
RoomSize = 32

local tspath = ""
local datapath = ""

function love.load(args)
  tspath = args[1]
  datapath = args[2]

  if #args ~= 2 then
    error("Missing arguments in command incubus-mapper <path/to/tileset> <path/to/data>")
  end

  local tsinfo = love.filesystem.getInfo(tspath)
  if not tsinfo then
    error("Could not find file: " .. tspath)
  end

  print("loading palette...")
  palette.loadPalette(tspath, TileSize)
  print("setting up canvas...")
  canvas.setupCanvas()

  local _, h = love.graphics.getDimensions()
  saveButton.setup(8, h - 38)

  print("ready!")
end

function love.draw()
  love.graphics.reset()
  love.graphics.setBackgroundColor(0.8, 0.8, 0.8, 1)
  canvas.drawCanvas(palette.tiles)
  palette.drawPalette()
  saveButton.draw()
end

local pmx, pmy = 0, 0

function love.update()
  local mx, my = love.mouse.getPosition()

  local phovered = palette.setPaletteHover(mx, my)

  if not phovered then
    canvas.setCanvasHover(mx, my)
  end

  if love.mouse.isDown(1) then
    local paletteSelected = palette.setPaletteSelect(mx, my)
    local saveClicked = saveButton.down(mx, my)

    if saveClicked then
      saveButton.busy = true
      local data = canvas.serialize()
      if not data then
        error("Could not encode data")
      end
      local success, message = love.filesystem.write(datapath, data)
      if not success then
        error(message)
      end
    end

    if not paletteSelected and not saveClicked then
      local tindex = palette.selectY * palette.cols + palette.selectX
      canvas.insertCanvasTile(mx, my, tindex)
    end
  elseif love.mouse.isDown(2) then
    canvas.moveCanvas(mx - pmx, my - pmy)
  else
    saveButton.busy = false
    saveButton.up(mx, my)
  end

  pmx, pmy = mx, my
end
