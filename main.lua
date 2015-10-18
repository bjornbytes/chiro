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
	animation:draw(400, 600)
end
