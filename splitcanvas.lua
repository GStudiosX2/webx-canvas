-- extends Canvas
local Canvas = require("canvas.lua")
local Canvas, Color = Canvas.Canvas, Canvas.Color

local sformat = string.format
local schar = string.char
local floor = math.floor
local ceil = math.ceil

local SplitCanvas = {}
SplitCanvas.__index = SplitCanvas
setmetatable(SplitCanvas, Canvas)

function SplitCanvas.new(width: number, height: number, sWidth: number, sHeight: number, background: {number}?, depth: number?)
  local canvas = Canvas.new(width, height, background, depth)
  setmetatable(canvas, SplitCanvas)

  local nsw = ceil(width / sWidth)
  local nsh = ceil(height / sHeight)

  canvas._sWidth = sWidth
  canvas._sHeight = sHeight
  canvas._dirty = table.create(nsw * nsh, true)
  canvas._frame = 0
  canvas._images_needed = nsw * nsh

  return canvas
end

function SplitCanvas:plotPixel(x: number, y: number, color: {number})
  if self:pixel(x, y) ~= color then
    self:plotPixel_0(x, y, color)
    local subX = x // self:sWidth()
    local subY = y // self:sHeight()
    local index = (subY - 1) * (self:width() // self:sWidth()) + subX
    self._dirty[index] = true
  end
end

function SplitCanvas:to_ppm()
  local index = self._frame
  local x, y = ((index - 1) % (self:width() / self:sWidth())) * self:width() + 1,
    ((index - 1) // (self:width() / self:sWidth())) * self:sHeight() + 1
  local buffer = {}
  local width, height = self:sWidth(), self:sHeight()
  table.insert(buffer, sformat("P6\n%d %d\n255\n", width, height))
  for y2 = 1, height do
    for x2 = 1, width do
      local idx = self:idx(x + x2, y + y2)
      local pix = self:pixel(idx)
      table.insert(buffer, schar(floor(pix[1] or 0)))
      table.insert(buffer, schar(floor(pix[2] or 0)))
      table.insert(buffer, schar(floor(pix[3] or 0)))
    end
  end
  return table.concat(buffer)
end

function SplitCanvas:to_png()
  error("Not Implemented")
  return nil
end

function SplitCanvas:render(images, format: string?)
  format = format or "png"
  if #images < self._images_needed then 
    error("not enough images")
    return 
  end
  for i, image in ipairs(images) do
    if self._dirty[i] == true then
      self._frame = i
      self:render_0(image, format)
      self._dirty[i] = false
    end
  end
end

function SplitCanvas:sWidth() return self._sWidth end
function SplitCanvas:sHeight() return self._sHeight end

return {
  Canvas = SplitCanvas,
  Color = Color
}
