local button = require "button"

local saveButton = button.newButton()

saveButton.text = "Save"
saveButton.color = { 0.8, 0.2, 0.8, 1 }
saveButton.x = 0
saveButton.y = 0
saveButton.width = 80
saveButton.height = 30
saveButton.isDown = false

function saveButton.setup(x, y)
  saveButton.x = x
  saveButton.y = y
end

function saveButton.down(mx, my)
  local r = saveButton.x + saveButton.width
  local b = saveButton.y + saveButton.height
  local flag = false

  if saveButton.isDown then
    return flag
  end

  if mx >= saveButton.x and mx < r and my >= saveButton.y and my < b then
    saveButton.isDown = true
    flag = true
  end

  return flag
end

function saveButton.up(mx, my)
  local r = saveButton.x + saveButton.width
  local b = saveButton.y + saveButton.height
  local flag = false

  if saveButton.isDown and mx >= saveButton.x and mx < r and my >= saveButton.y and my < b then
    saveButton.isDown = false
  end

  return flag
end

function saveButton.draw()
  love.graphics.setColor(unpack(saveButton.color))
  love.graphics.rectangle("fill", saveButton.x, saveButton.y, saveButton.width, saveButton.height)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.print(saveButton.text, saveButton.x + 20, saveButton.y + 5, 0, 1.3, 1.3)

  button.drawHighlights(saveButton)
end

return saveButton
