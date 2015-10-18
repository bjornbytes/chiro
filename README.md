Chiro
===

A library that makes it easier to work with spine animations in LÖVE games.

Usage
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

Documentation coming soon, but here is a table containing all the options you can set:

```lua
chiro.create({
  dir = 'path/to/animation', -- must contain 'animation.json' and an 'images' directory
  images = 'path/to/images', -- images directory, if not using dir option
  json = 'path/to/json.json', -- json file, if not using dir option
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
    <eventName> = function(animation, event)

    end,
    start = function(animation, state)

    end,
    complete = function(animation, state)

    end,
    ['end'] = function(animation, state)

    end
  },
  default = <animationName> -- immediately start playing this animation
})
```

License
---

MIT, see [`LICENSE`](LICENSE) for details.
