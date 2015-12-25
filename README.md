Chiro
===

A library that makes it easier to work with spine animations in LÖVE games.

Example
---

If your project looks like this:

```
├── main.lua
├── chiro.lua
├── spine-love
├── spine-lua
└── spineboy
    ├── spineboy.json
    └── images
        ├── head.png
        ├── neck.png
        ├── ...
        └── etc.
```

Then you can get up and running quickly by doing this in `main.lua`:

```lua
require 'spine-love/spine'

chiro = require 'chiro'

animation = chiro.create({
  dir = 'spineboy',
  states = {
    walk = {
      loop = true
    }
  },
  default = 'walk'
})

function love.update(delta)
  animation:update(delta)
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  animation:draw(400, 550)
end
```

Advanced
---

To create a chiro animation, call `chiro.create(options)`.  Chiro needs to know where the JSON
file and images folder are, which can be specified in one of two ways:

- Pass a `dir` option with the name of a folder that has an `images` subdirectory and a JSON file
  with the same name as the directory.
- Pass the two options separately: a path to the folder containing the images (`images`) and a path
  to the JSON file (`json`).

Here are the other optional options that can be customized:

```lua
local animation = chiro.create({
  scale = 1, -- base scale of animation
  flip = false, -- flip animation along the x axis
  flip = { -- can also flip both x and y
    x = false,
    y = false
  },
  x = 0, -- x value to draw at
  y = 0, -- y value to draw at
  offset = {
    x = 0, -- offset x values by this amount
    y = 0 -- offset y values by this amount
  },
  speed = 1, -- global speed of animation
  states = {
    <animationName> = {
      loop = false, -- whether or not to repeat the animation
      track = 0, -- the track to play the animation on
      speed = 1, -- the speed at which to play the animation
      length = 1 -- alternatively, specify how long the animation should take to complete
      next = <animationName> -- specify an animation to transition to on completion
    }
  },
  on = {
    <eventName> = function(animation, event) end,
    start       = function(animation, state) end,
    complete    = function(animation, state) end,
    ['end']     = function(animation, state) end
  },
  default = <animationName> -- immediately start playing this animation
})
```

An animation should be updated to play through the tracks and set the bones in the right position.
To do this, call the `update` function on the chiro animation:

```lua
function love.update(dt)
  animation:update(dt)
end
```

`dt` is the number of seconds elapsed since the last call to `update`.

To draw the animation to the screen, call `draw`:

```lua
function love.draw()
  animation:draw(x, y)
end
```

`x` and `y` are optional.  They can also be set on the animation directly:

```lua
animation.x = 100
animation.y = 100
```

Use `set` to play a specific animation:

```lua
animation:set('walk') -- Play the walk animation
```

The animation will play using the settings defined in the `states` part of the config for that
animation.  This can be used to control speed, looping, tracks, and can also be used to transition
to another animation after the current one is finished playing.

To reset things, call `clear` on the animation to clear all animation tracks, or `resetTo(name)`
to clear all tracks and begin playing an animation.

To hook into events for the animation, specify functions for keys in the `on` section of the config.
`start`, `complete`, and `end` will be passed the animation object and the state object as
arguments.

Chiro also exposes most of the underlying Spine objects as properties on the animation object:

- `skeletonJson`
- `skeletonData`
- `skeleton`
- `animationStateData`
- `animationState`

License
---

MIT, see [`LICENSE`](LICENSE) for details.
