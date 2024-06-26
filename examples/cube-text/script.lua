local set_interval = require("../../interval.lua")
local Canvas = require("../../canvas.lua")
local Point3D = require("../../point3D.lua")
local Canvas, Color = Canvas.Canvas, Canvas.Color
local size = 64
local canvas = Canvas.new(size, size, Color.Black)

function project_test(point, fov, distance)
  local factor = fov / (distance + point.z)
  local x = point.x * factor + canvas:width() / 2
  local y = point.y * factor + canvas:height() / 2
  return Point3D.new(x, y, point.z)
end

function rotate_test(point, angle)
  local rad = angle * math.pi / 180
  local cosa = math.cos(rad)
  local sina = math.sin(rad)
  local z = point.z * cosa - point.x * sina
  local x = point.z * sina + point.x * cosa
  return Point3D.new(x, point.y, z)
end

local vertices = {
  Point3D.new(-1.0,  1.0, -1.0),
  Point3D.new( 1.0,  1.0, -1.0),
  Point3D.new( 1.0, -1.0, -1.0),
  Point3D.new(-1.0, -1.0, -1.0),
  Point3D.new(-1.0,  1.0,  1.0),
  Point3D.new( 1.0,  1.0,  1.0),
  Point3D.new( 1.0, -1.0,  1.0),
  Point3D.new(-1.0, -1.0,  1.0)
}
local faces = {
  {1, 2, 3, 4},
  {2, 6, 7, 3},
  {6, 5, 8, 7},
  {5, 1, 4, 8},
  {1, 5, 6, 2},
  {4, 3, 7, 8}
}
local textureCoords = {
    {{0, 0}, {1, 0}, {1, 1}, {0, 1}},
    {{0, 0}, {1, 0}, {1, 1}, {0, 1}},
    {{0, 0}, {1, 0}, {1, 1}, {0, 1}},
    {{0, 0}, {1, 0}, {1, 1}, {0, 1}},
    {{0, 0}, {1, 0}, {1, 1}, {0, 1}},
    {{0, 0}, {1, 0}, {1, 1}, {0, 1}},
}

local texture = Canvas.new(16, 16)

for x=1,texture:width() do
  for y=1,texture:height() do
    texture:plotPixel(x, y, Color.random())
  end
end

local angle = 0
local last_time = os.time()
local rotations_per_frame = get("rotation_input")
local rpf = tonumber(rotations_per_frame.get_content())

rotations_per_frame.on_submit(function()
  local n = tonumber(rotations_per_frame.get_content())
  if n == nil then n = 4 end
  if n < 1 then n = 1 end
  if n > 90 then n = 90 end
  rpf = n
end)

function draw(delta)
  canvas:clearRect(0, 0, canvas:width(), canvas:height())
  local points = {}
  for i, vertex in ipairs(vertices) do
    local new = project_test(
      rotate_test(vertex, angle), 128, 7)
    table.insert(points, new)
  end
  for j, face in ipairs(faces) do
    canvas:drawLine(
      points[face[1]].x, 
      points[face[1]].y, 
      points[face[2]].x, 
      points[face[2]].y,
      Color.Green)
    canvas:drawLine(
      points[face[2]].x, 
      points[face[2]].y, 
      points[face[3]].x, 
      points[face[3]].y,
      Color.Green)
    canvas:drawLine(
      points[face[3]].x, 
      points[face[3]].y,
      points[face[4]].x,
      points[face[4]].y,
      Color.Green)
    canvas:drawLine(
      points[face[1]].x, 
      points[face[1]].y, 
      points[face[3]].x, 
      points[face[3]].y,
      Color.Green)
  end
  angle += rpf
end

local count = 0
local fps = 0
local tmp = 0

local image = get("image")
local text = get("text")
set_interval(function()
  current_time = os.time()
  delta = (current_time - last_time)
  draw(delta)
  canvas:render(image, "text")
  last_time = current_time
  if count <= 0 then
    count += delta
    tmp += 1
  else
    fps = tmp
    tmp = 0
    count = 0
  end
  text.set_content("FPS: "..fps)
end, 16)
