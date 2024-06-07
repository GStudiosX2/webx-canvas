local sqrt = math.sqrt
local PI = math.pi
local Point3D = {}
Point3D.__index = Point3D
Point3D.__add = function(self, other)
  self.x += other.x
  self.y += other.y
  self.z += other.z
  return self
end
Point3D.__sub = function(self, other)
  self.x -= other.x
  self.y -= other.y
  self.z -= other.z
  return self
end
Point3D.__mul = function(self, other)
  self.x *= other.x
  self.y *= other.y
  self.z *= other.z
  return self
end
Point3D.__div = function(self, other)
  self.x /= other.x
  self.y /= other.y
  self.z /= other.z
  return self
end
Point3D.__unm = function(self)
  self.x = 0 - self.x
  self.y = 0 - self.y
  self.z = 0 - self.z
  return self
end
Point3D.__eq = function(self, other)
  if self.x == other.x and self.y == other.y and self.z == other.z then
    return true
  else
    return false
  end
end

function Point3D.new(x: number?, y: number?, z: number?)
  if x == nil then x = 0 end
  if x ~= nil and y == nil then y = x end
  if y ~= nil and z == nil then z = y end
  local self = setmetatable({
    x = x,
    y = y,
    z = z
  }, Point3D)
  return self
end

function Point3D.normal(p1: Point3D, p2: Point3D, p3: Point3D)
  local U = p3 - p2
  local V = p1 - p2
  local normal = Point3D.new(
    U.y * V.z - U.z * V.y, 
    U.z * V.x - U.x * V.z,
    U.x * V.y - U.y * V.x
  )
  return normal
end

function Point3D:set(x: number, y: number, z: number)
  self.x = x
  self.y = y
  self.z = z
end

function Point3D:set_x(x: number)
  self.x = x
end

function Point3D:set_y(y: number)
  self.y = y
end

function Point3D:set_z(z: number)
  self.z = z
end

function Point3D:x()
  return self.x
end

function Point3D:y()
  return self.y
end

function Point3D:z()
  return self.z
end

function Point3D:length()
  return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

return Point3D
