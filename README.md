# webx-canvas

webx canvas is a way to draw anything you like on a image
using base64 encoding and data urls in webx v1.3.0

This project uses relative urls in require and unfortunately requires
my pr/repo as of currently writing this.

[repo](https://github.com/GStudiosX2/webx)

[pull request](https://github.com/face-hh/webx/pull/170)

# Formats

There are currently two supported formats:

ppm

png

PPM is a really simple format and is fast to encode 
(which makes it more optimal choice for 3D or games)

it's basically a header with the pixels in a specific order

PNG is slower to encode so you don't want to do it every how many frames
PPM is a better option for that but PNG might be great for static or once in a while update images

One downside of PPM is there's no alpha channel

# API

To include this API into your project add the files to your projects directory
and to the top of your main script file add these lines:

```lua
local Canvas = require("canvas.lua")
local Canvas, Color = Canvas.Canvas, Canvas.Color
```

## Colors

```lua
Color.Red
Color.Green
Color.DarkGreen
Color.Blue
Color.Black
Color.White
Color.AliceBlue
Color.CadetBlue
Color.Cyan
Color.Aqua = Color.Cyan
Color.DarkBlue
Color.DarkCyan
Color.CornFlower
Color.Crimson
Color.DarkGray
Color.DarkGrey = Color.DarkGray
Color.DarkGoldenRod
Color.DarkMagenta
Color.DarkOliveGreen
Color.DarkOrange
Color.DarkOrchid
Color.DarkRed
Color.DarkSalmon
Color.DarkSeaGreen
Color.DarkSlateBlue
Color.DarkSlateGray
Color.DarkSlateGrey
Color.DarkViolet
Color.DeepPink
Color.DeepSkyBlue
Color.DimGray
Color.DimGrey = Color.DimGray
Color.DodgerBlue
Color.ForestGreen
Color.GhostWhite
Color.Gold
Color.GoldenRod
Color.Gray
Color.Grey = Color.Gray
Color.Indigo
Color.LightBlue
Color.Yellow
```

Most of these are [css colors](https://www.w3schools.com/cssref/css_colors.php)

If you want to make your own colors you can use these functions

```lua
-- create a new color with red, green, blue channels
Color.new(r: number, g: number, b: number) -> Color

-- create a new color with red and green channels and blue is the same as green
Color.new(r: number, gb: number) -> Color

-- create a new color with all channels being the same value
Color.new(rgb: number) -> Color
```

If you want to use hex you can call:

```lua
-- ex: Color.hex("#f7f7f7")
Color.hex(hex: string) -> Color
```

You can customize the alpha channel of a color with:

```lua
-- ex: Color.Red:alpha(0.5)
-- not support with PPM format
Color:alpha(a: number) -> Color
```

You can also clone a color if you'd like but its mostly internal:

```lua
-- returns new color with same rgba values
Color:clone() -> Color
```

You can also change the brightness of a color it will return a new one

```lua
-- factor is a value between -1 and 1
-- -1 is black
-- 1 is white
Color:brightness(factor: number) -> Color

-- this is just brightness but the factor has a default of 0.25
-- and it always makes sure that it darkens it
Color:darker(factor: number?) -> Color

-- this is just brightness but the factor has a default of 0.25
-- and it always makes sure that it lightens it
Color:lighter(factor: number?) -> Color
```

## Canvas

This is the main guts of the API.
since this is lua all the x and y's etc.. is 1 indexed

You can create a new canvas with:

```lua
Canvas.new(width: number, height: number) -> Canvas

Canvas.new(width: number, height: number, background: Color) -> Canvas

-- available depths: 3, 4 by default its 3
-- depth specifies where it should have 3 or 4 color channels
-- depth is not supported on the PPM format
Canvas.new(width: number, height: number, background: Color, depth: number) -> Canvas
```

You can resize the canvas with the resize function
(you will need to rerender for changes to apply and the extra space wont respect background color)

```lua
Canvas:resize(width: number, height: number)
```

This function changes the background color clearRect uses

```lua
-- putting nil will make the background transaprent or black (PPM)
Canvas:setBackground(background: Color?)
```

This just sets a bunch of pixels to the background color

```lua
Canvas:clearRect(x: number, y: number, width: number, height: number)
```

If you want to get a pixel you will need to use a index which you can use:

```lua
Canvas:idx(x: number, y: number) -> number
```

### Getting a Pixel

```lua
-- you can get a idx with the idx function
Canvas:pixel(idx: number) -> Color
```

### Setting a Pixel

```lua
Canvas:plotPixel(x: number, y: number, color: Color)
```

### Drawing a Line

```lua
Canvas:drawLine(x1: number, y1: number, x2: number, y2: number, color: Color)
```

### Drawing a Rectangle

```lua
Canvas:drawRect(x: number, y: number, width: number, height: number, color: Color)
```

### Drawing a Circle

There are two circle functions one to draw filled and one to draw just the outline
x and y is the center of the circle

```lua
Canvas:drawCircleFilled(x: number, y: number, tadius: number, color: Color)
Canvas:drawCircle(x: number, y: number, tadius: number, color: Color)
```

### Finishing up everthing

Ok so now you've drawed whatever you want now you want to render it
well it's actually really simple.

We just call the render function!

The last argument is one of the formats we discussed [earlier](#formats)
by default it's "png"

```lua
Canvas:render(image: HTMLImageElement, format: Format?)
```

### Last few things

Ok so we basically done but there's still a little more
there is a point3D and point2D which has some functions on them that maybe be useful.

There is also a width and height function on Canvas.

```lua
-- get width of Canvas
Canvas:width() -> number

-- get height of Canvad
Canvas:height() -> number
```

You can also get the image as the PPM format with:

```lua
Canvas:to_ppm()
```

This is mainly internal so thing's can change use at your own risk.

Onto points!

## Points

You can require either Point2D or Point3D or both.

```lua
local Point2D = require("point2D.lua")
local Point3D = require("point3D.lua")
```

TODO

# Examples

[Rotating 3D Cube](examples/cube)
