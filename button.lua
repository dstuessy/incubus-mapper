local B = {}

---@class Button
---@field text string
---@field color (number[]|nil) Table of r, g, b, a number color values
---@field x number
---@field y number
---@field width number
---@field height number
---@field isDown boolean
---@field busy boolean
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
    busy = false,
    setup = function() end,
    down = function() return false end,
    up = function() return false end,
    draw = function() end,
  }

  return b
end

return B
