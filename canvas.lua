local PNG = require("pngencoder.lua")
local Base64 = require("base64.lua")

local Canvas = {}
Canvas.__index = Canvas

local sin = math.sin
local cos = math.cos
local rad = math.rad
local abs = math.abs
local floor = math.floor
local schar = string.char
local sformat = string.format
local random = math.random

local PPM_MIME = "image/x-portable-anymap"
local PNG_MIME = "image/png"

local function rgb(rgb: {number})
  local r,g,b,a = rgb[1], rgb[2], rgb[3], rgb[4]
  if r < 0 then r = 0 end
  if r > 255 then r = 255 end
  if g < 0 then g = 0 end
  if g > 255 then g = 255 end
  if b < 0 then b = 0 end
  if b > 255 then b = 255 end
  if a < 0 then a = 0 end
  if a > 255 then a = 255 end
  return {r,g,b,a}
end

local Color = {}
Color.__index = Color

function Color.new(r: number, g: number?, b: number?, a: number?)
  if g == nil then g = r end
  if b == nil then b = g end
  if a == nil then a = 255 end
  local self = setmetatable(rgb({ r, g, b, a }), Color)
  return self
end

function Color.hex(hex: string)
  hex = hex:gsub("#", "")
  return Color.new(tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)))
end

function Color.random()
  return Color.new(random(0, 255), random(0, 255), random(0, 255))
end

function Color:clone()
  local r, g, b = self[1], self[2], self[3], self[4]
  return Color.new(r, g, b, a)
end

function Color:brightness(factor: number)
  local r, g, b, a = self[1], self[2], self[3], self[4]
  if factor < 0 then
    factor = 1 + factor
    r *= factor
    g *= factor
    b *= factor
  else
    r = (255 - r) * factor + r
    g = (255 - g) * factor + g
    b = (255 - b) * factor + b
  end
  return Color.new(r, g, b, a)
end

function Color:lighter(factor: number?)
  factor = abs(factor or 0.25)
  return self:brightness(factor)
end

function Color:darker(factor: number?)
  factor = 0 - abs(factor or 0.25)
  return self:brightness(factor)
end

function Color:alpha(alpha: number?)
  if a == nil then a = 255 end
  if a < 0 then a = 0 end
  if a > 255 then a = 255 end
  local color = self:clone()
  color[4] = alpha
  return color
end

-- some from https://www.w3schools.com/cssref/css_colors.php
Color.Red = Color.new(255, 0, 0)
Color.Green = Color.new(0, 255, 0)
Color.DarkGreen = Color.hex("#006400")
Color.Blue = Color.new(0, 0, 255)
Color.Black = Color.new(0)
Color.White = Color.new(255)
Color.AliceBlue = Color.hex("#F0F8FF")
Color.CadetBlue = Color.hex("#5F9EA0")
Color.Cyan = Color.new(0, 255)
Color.Aqua = Color.Cyan
Color.DarkBlue = Color.new(0, 0, 138)
Color.DarkCyan = Color.hex("#008B8B")
Color.CornFlower = Color.hex("#6495ED")
Color.Crimson = Color.hex("#DC143C")
Color.DarkGray = Color.hex("#A9A9A9")
Color.DarkGrey = Color.DarkGray
Color.DarkGoldenRod = Color.hex("#B8860B")
Color.DarkMagenta = Color.hex("#8B008B")
Color.DarkOliveGreen = Color.hex("#556B2F")
Color.DarkOrange = Color.hex("#FF8C00")
Color.DarkOrchid = Color.hex("#9932CC")
Color.DarkRed = Color.hex("#8B0000")
Color.DarkSalmon = Color.hex("#E9967A")
Color.DarkSeaGreen = Color.hex("#8FBC8F")
Color.DarkSlateBlue = Color.hex("#483D8B")
Color.DarkSlateGray = Color.hex("#2F4F4F")
Color.DarkSlateGrey = Color.DarkSlateGray
Color.DarkViolet = Color.hex("#9400D3")
Color.DeepPink = Color.hex("#FF1493")
Color.DeepSkyBlue = Color.hex("#00BFFF")
Color.DimGray = Color.hex("#696969")
Color.DimGrey = Color.DimGray
Color.DodgerBlue = Color.hex("#1E90FF")
Color.ForestGreen = Color.hex("#228B22")
Color.GhostWhite = Color.hex("#F8F8FF")
Color.Gold = Color.hex("#FFD700")
Color.GoldenRod = Color.hex("#DAA520")
Color.Gray = Color.hex("#808080")
Color.Grey = Color.Gray
Color.Indigo = Color.hex("#4B0082")
Color.LightBlue = Color.hex("#ADD8E6")
Color.Yellow = Color.hex("#FFFF00")

function Canvas.new(width: number, height: number, background: {number}?, depth: number?)
  depth = depth or 3
  if depth < 3 then depth = 3 end
  if depth > 4 then depth = 4 end
  width = floor(width)
  height = floor(height)
  background = rgb(background or { 0, 0, 0, 0 })
  if width < 1 or height < 1 then return nil end
  local self = setmetatable({
    _width = width,
    _height = height,
    _pixels = table.create(width * height * depth, 0),
    _background = background,
    _depth = depth
  }, Canvas)
  self:clearRect(0, 0, width, height)
  return self
end

function Canvas:resize(width: number, height: number)
  width = floor(width)
  height = floor(height)
  if width < 1 or height < 1 or self._width == width or self._height == height then return end
  self._width = width
  self._height = height
  local pixels = table.create(width * height * self._depth, 0)
  table.move(self._pixels, 1, #self._pixels, 1, pixels)
  self._pixels = pixels
end

function Canvas:setBackground(background: {number}?)
  self._background = rgb(background or { 0, 0, 0, 0 })  
end

function Canvas:idx(x: number, y: number)
  local idx = ((y - 1) * self._width + (x - 1)) * self._depth + 1
  return idx
end

function Canvas:plotPixel(x: number, y: number, color: {number})
  if x < 1 or y < 1 or x > self._width or y > self._height then return end
  local idx = self:idx(x, y)
  self._pixels[idx] = color[1]
  self._pixels[idx + 1] = color[2]
  self._pixels[idx + 2] = color[3]
  if self._depth == 4 then
    self._pixels[idx + 3] = color[4]
  end
end

function Canvas:drawLine(x: number, y: number, x2: number, y2: number, color: {number})
  -- stolen from https://gist.github.com/Validark/946fdad15d496a553a0ad4fdfd2f6937
  local steep = abs(y2 - y) > abs(x2 - x)

  if steep then
    x, y = y, x
    x2, y2 = y2, x2
  end

  if x > x2 then
    x, x2 = x2, x
    y, y2 = y2, y
  end

  local dx = x2 - x
  local dy = y2 - y
  local gradient = dy / dx

  if dx == 0 then
    gradient = 1.0
  end

  local xend = floor(x + 0.5)
  local yend = y + gradient * (xend - x)
  local xgap = 1 - (x + 0.5) % 1
  local xpxl1 = xend
  local ypxl1 = floor(yend)

  if steep then
    self:plotPixel(ypxl1, xpxl1, color)
    self:plotPixel(ypxl1 + 1, xpxl1, color)
  else
    self:plotPixel(xpxl1, ypxl1, color)
    self:plotPixel(xpxl1, ypxl1 + 1, color)
  end

  local intery = yend + gradient

  xend = floor(x2 + 0.5)
  yend = y2 + gradient * (xend - x2)
  xgap = (x2 + 0.5) % 1
  local xpxl2 = xend
  local ypxl2 = floor(yend)

  if steep then
    self:plotPixel(ypxl2 , xpxl2, color)
    self:plotPixel(ypxl2 + 1, xpxl2, color)
  else
    self:plotPixel(xpxl2, ypxl2, color)
    self:plotPixel(xpxl2, ypxl2 + 1, color)
  end

  if steep then
    for x = xpxl1 + 1, xpxl2 - 1 do
      self:plotPixel(floor(intery) , x, color)
      self:plotPixel(floor(intery) + 1, x, color)
      intery = intery + gradient
    end
  else
    for x = xpxl1 + 1, xpxl2 - 1 do
      self:plotPixel(x, floor(intery), color)
      self:plotPixel(x, floor(intery) + 1, color)
      intery = intery + gradient
    end
  end
end

function Canvas:drawRect(x: number, y: number, width: number, height: number, color: {number})
  for x2=1,width do
    for y2=1,height do
      self:plotPixel(x + x2, y + y2, color)
    end
  end
end

function Canvas:drawCircle(x: number, y: number, radius: number, color: {number})
  for angle=0,360 do
    local x2 = floor(radius * sin(rad(angle)) + x + 0.5)
    local y2 = floor(radius * cos(rad(angle)) + y + 0.5)
    self:plotPixel(x2, y2, color)
  end
end

function Canvas:drawCircleFilled(x: number, y: number, radius: number, color: {number})
  for angle=0,360 do
    local x2 = floor(radius * sin(rad(angle)) + x + 0.5)
    local y2 = floor(radius * cos(rad(angle)) + y + 0.5)
    self:drawLine(x, y, x2, y2, color)
  end
end

function Canvas:clearRect(x: number, y: number, width: number, height: number)
  self:drawRect(x, y, width, height, self._background)
end

function Canvas:to_ppm()
    local buffer = {}
    local width, height = self:width(), self:height()
    local pixels = self._pixels
    table.insert(buffer, sformat("P6\n%d %d\n255\n", width, height))
    for y = 1, height do
        for x = 1, width do
            local idx = self:idx(x, y)
            table.insert(buffer, schar(floor(pixels[idx])))
            table.insert(buffer, schar(floor(pixels[idx + 1])))
            table.insert(buffer, schar(floor(pixels[idx + 2])))
        end
    end
    return table.concat(buffer)
end

function Canvas:render(image, format: string?)
  format = format or "png"
  if image ~= nil and image.set_source ~= nil then
    if format == "png" then
      local png = PNG(self._width, self._height, self._depth == 3 and "rgb" or "rgba")
      png:write(self._pixels)
      if not png.done then
        error("png not ready")
        return
      end
      image.set_source("data:" .. PNG_MIME .. ";base64," ..
        buffer.tostring(Base64.encode(
        buffer.fromstring(table.concat(png.output)))))
    elseif format == "ppm" then
      image.set_source("data:" .. PPM_MIME .. ";base64," ..
        buffer.tostring(Base64.encode(
        buffer.fromstring(self:to_ppm()))))
    end
  end
end

function Canvas:width() return self._width end
function Canvas:height() return self._height end

return {
  Canvas = Canvas,
  Color = Color
}
