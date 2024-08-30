local palette = require("palette")
local canvas = require("canvas")
local saveButton = require("saveButton")

TileSize = 16
RoomSize = 32
Layers = 3

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

  local datainfo = love.filesystem.getInfo(datapath)

  if datainfo and datainfo.type == "file" then
    local data, err = love.filesystem.read("data", datapath)
    if not data then
      error(err)
    end
    canvas.load(data)
  end

  local _, h = love.graphics.getDimensions()
  saveButton.setup(8, h - 38)

  print("ready!")
  love.graphics.setBackgroundColor(0.8, 0.8, 0.8, 1)
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
      local data = canvas.serialize()
      if not data then
        error("Could not encode data")
      end
      local success, message = love.filesystem.write(datapath, data)
      if not success then
        error(message)
      end
      print("saved!")
    end

    if not paletteSelected and not saveClicked then
      local tindex = palette.selectY * palette.cols + palette.selectX

      if love.keyboard.isDown("lalt") then
        canvas.fillCanvas(tindex)
      elseif love.keyboard.isDown("lshift") then
        if not canvas.selectRectStart then
          canvas.setSelectRectStart(mx, my)
        else
          canvas.setSelectRectEnd(mx, my)
        end
      else
        canvas.insertCanvasTile(mx, my, tindex)
      end
    end
  elseif love.mouse.isDown(2) then
    canvas.moveCanvas(mx - pmx, my - pmy)
  else
    saveButton.up(mx, my)

    if love.keyboard.isDown("lshift") and canvas.selectRectStart and canvas.selectRectEnd then
      local tindex = palette.selectY * palette.cols + palette.selectX
      canvas.fillSelectRect(tindex)
      canvas.clearSelectRect()
    end

    if love.keyboard.isDown("tab") then
      canvas.showMeta = true
    else
      canvas.showMeta = false
    end
  end

  pmx, pmy = mx, my
end
