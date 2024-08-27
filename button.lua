local B = {}

---@class Button
---@field text string
---@field color (number[]|nil) Table of r, g, b, a number color values
---@field x number
---@field y number
---@field width number
---@field height number
---@field isDown boolean
---@field setup fun(x: number, y: number)
---@field down fun(mx: number, my: number): boolean
---@field up fun(mx: number, my: number): boolean
---@field draw fun()
local button = {}

---@return Button
function B.newButton()
  ---@type Button
  local b = {
    text = "",
    color = nil,
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    isDown = false,
    setup = function() end,
    down = function() return false end,
    up = function() return false end,
    draw = function() end,
  }

  return b
end

---@param btn Button
function B.drawHighlights(btn)
  local c = btn.color
  local hlghtT = { 1, 1, 1, 0.4 }
  local hlghtL = { 1, 1, 1, 0.2 }
  local hlghtR = { 0, 0, 0, 0.2 }
  local hlghtB = { 0, 0, 0, 0.4 }

  if btn.isDown then
    local tmp = { unpack(hlghtT) }
    hlghtT = hlghtB
    hlghtB = tmp

    tmp = { unpack(hlghtL) }
    hlghtL = hlghtR
    hlghtR = tmp
  end

  if c ~= nil then
    local w = 4
    love.graphics.setColor(unpack(hlghtT))
    love.graphics.rectangle("fill", btn.x, btn.y, btn.width, w)
    love.graphics.setColor(unpack(hlghtL))
    love.graphics.rectangle("fill", btn.x, btn.y, w, btn.height)
    love.graphics.setColor(unpack(hlghtR))
    love.graphics.rectangle("fill", btn.x + btn.width - w, btn.y, w, btn.height)
    love.graphics.setColor(unpack(hlghtB))
    love.graphics.rectangle("fill", btn.x, btn.y + btn.height - w, btn.width, w)
  end
end

return B
