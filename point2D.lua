local sqrt = math.sqrt
local Point2D = {}
Point2D.__index = Point2D
Point2D.__add = function(self, other)
  if tonumber(other) == other then
    self.x += other
    self.y += other
  else
    self.x += other.x
    self.y += other.y
  end
  return self
end
Point2D.__sub = function(self, other)
  if tonumber(other) == other then
    self.x -= other
    self.y -= other
  else
    self.x -= other.x
    self.y -= other.y
  end
  return self
end
Point2D.__mul = function(self, other)
  if tonumber(other) == other then
    self.x *= other
    self.y *= other
  else
    self.x *= other.x
    self.y *= other.y
  end
  return self
end
Point2D.__div = function(self, other)
  if tonumber(other) == other then
    self.x /= other
    self.y /= other
  else
    self.x /= other.x
    self.y /= other.y
  end
  return self
end
Point2D.__unm = function()
  self.x = 0 - self.x
  self.y = 0 - self.y
  return self
end
Point2D.__eq = function(self, other)
  if self.x == other.x and self.y == other.y then
    return true
  else
    return false
  end
end

function Point2D.new(x: number?, y: number?)
  if x == nil then x = 0 end
  if x ~= nil and y == nil then y = x end
  local self = setmetatable({
    x = x,
    y = y
  }, Point2D)
  return self
end

function Point2D:set(x: number, y: number)
  self.x = x
  self.y = y
end

function Point2D:set_x(x: number)
  self.x = x
end

function Point2D:set_y(y: number)
  self.y = y
end

function Point2D:x()
  return self.x
end

function Point2D:y()
  return self.y
end

function Point2D:length()
  return sqrt(self.x * self.x + self.y * self.y)
end

return Point2D
