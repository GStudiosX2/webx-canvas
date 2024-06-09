local set_interval = require("../../interval.lua")
local Canvas = require("../../canvas.lua")
local Canvas, Color = Canvas.Canvas, Canvas.Color
local Point2D = require("../../point2D.lua")

local image = get("image")
local canvas = Canvas.new(200, 300, Color.Aqua)

local birdpos = Point2D.new(30, 85)
local jumpbtn = get("jumpbtn")
local restartbtn = get("restartbtn")
local buffered_jump = false
local stopped = false
local last_time = os.clock()
local tmp_fps, fps, count = 0, 0, 0
local fps_counter = get("fps")
local pipes = {}
local gravity = 0
local score = 0
local highscore = 0
local paralax = 0

restartbtn.on_click(function()
  pipes = {}
  gravity = 0
  birdpos = Point2D.new(30, 85)
  score = 0
  buffered_jump = false
  stopped = false
end)

jumpbtn.on_click(function()
  if not stopped then
    buffered_jump = true
  end
end)

function drawBuilding(x: number, width: number, height: number, color: {number})
  canvas:drawRect(x + paralax, canvas:height() - height - 2, width + 2, height, Color.Black)
  canvas:drawRect(x + paralax, canvas:height() - height, width, height, color)
end

set_interval(function()
  local current_time = os.clock()
  local delta = (current_time - last_time)

  canvas:clearRect(0, 0, canvas:width(), canvas:height())

  if birdpos.y > 300 - 30 or birdpos.y < -5 then
    stopped = true
  end

  if stopped then
    restartbtn.set_visible(true)
  else
    if score > highscore then
      highscore = score
    end
    restartbtn.set_visible(false)
  end

  drawBuilding(0, 20, 125, Color.Green:darker())
  drawBuilding(140, 70, 135, Color.Gold)
  drawBuilding(85, 60, 220, Color.Red)
  drawBuilding(20, 40, 185, Color.Blue)
  drawBuilding(60, 60, 175, Color.Yellow:darker())

  drawBuilding(200, 20, 125, Color.Green:darker())
  drawBuilding(200 + 140, 70, 135, Color.Gold)
  drawBuilding(200 + 85, 60, 220, Color.Red)
  drawBuilding(200 + 20, 40, 185, Color.Blue)
  drawBuilding(200 + 60, 60, 175, Color.Yellow:darker())
  canvas:drawRect(0, canvas:height() - 32, canvas:width(), 2, Color.Black)
  canvas:drawRect(0, canvas:height() - 30, canvas:width(), 30, Color.Green:lighter())

  canvas:drawCircleFilled(birdpos.x + 25, birdpos.y + 13, 5, Color.Yellow:darker())
  canvas:drawCircle(birdpos.x + 25, birdpos.y + 13, 5, Color.Black)
  canvas:drawCircleFilled(birdpos.x + 10, birdpos.y + 10, 15, Color.Yellow)
  canvas:drawCircleFilled(birdpos.x + 12, birdpos.y + 8, 4, Color.Black)
  canvas:drawCircleFilled(birdpos.x + 12, birdpos.y + 8, 2, Color.White)
  canvas:drawCircle(birdpos.x + 10, birdpos.y + 10, 15, Color.Black)

  for i, pipeo in ipairs(pipes) do
    local pipe = pipeo.pos
    if pipe.x < -30 then
      pipes[i] = nil
    else
      canvas:drawCircle(pipe.x - (38 / 2), pipe.y, 6, pipeo.collected and Color.Red or Color.White)
      canvas:drawRect(
        pipe.x - 40, pipe.y - 300 - 35,
        42, 300, Color.Black)
      canvas:drawRect(
        pipe.x - 38, pipe.y - 300 - 35,
        38, 300, Color.Green:darker())
      canvas:drawRect(
        pipe.x - 40, pipe.y + 35,
        42, 300, Color.Black)
      canvas:drawRect(
        pipe.x - 38, pipe.y + 35,
        38, 300, Color.Green:darker())

      if (birdpos.x >= pipe.x - (38 - 10) and birdpos.x <= pipe.x + (38 - 10)) then
        if (birdpos.y > pipe.y + 35 or birdpos.y < pipe.y - 35) then
          stopped = true
        elseif not pipeo.collected then
          pipeo.collected = true
          score += 1
        end
      end
    end
  end

  canvas:render(image, "ppm")
  last_time = current_time

  paralax -= 5
  if paralax < -200 then
    paralax = 0
  end

  if not stopped then
    gravity -= 1.5 * delta
    gravity = math.max(gravity, -10)
    birdpos -= Point2D.new(0, gravity)
    if buffered_jump then
      gravity = math.min(math.abs(gravity) + 2, 5)
      buffered_jump = false
    end

    if #pipes <= 2 then
      if (#pipes > 1 and pipes[1].x < 50) or #pipes == 0 then
        table.insert(pipes, {
          pos = Point2D.new(300, math.random(80, 220)),
          collected = false
        })
      end
    end

    for i, pipe in ipairs(pipes) do
      pipe.pos.x -= 7
    end
  end

  if count < 1 then
    count += delta
    tmp_fps += 1
  else
    fps = tmp_fps
    tmp_fps = 0
    count = 0
  end

  fps_counter.set_content("FPS: " .. fps .. ", Score: " .. score .. ", High: " .. highscore)
end, 16)
