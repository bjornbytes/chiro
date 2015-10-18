local chiro = {}
chiro.__index = chiro

function chiro.create(config)
  local self = setmetatable(config, chiro)

  if self.dir then
    self.images = self.images or (self.dir .. '/images')
    self.json = self.json or (self.dir .. '/' .. self.dir:match('[^%/]+$') .. '.json')
  end

  self.skeletonJson = spine.SkeletonJson.new()
  self.skeletonJson.scale = self.scale or 1

  if type(self.json) == 'table' then
    self.skeletonData = self.skeletonJson:readSkeletonData(self.json)
  else
    self.skeletonData = self.skeletonJson:readSkeletonDataFile(self.json)
  end

  self.skeleton = spine.Skeleton.new(self.skeletonData)

  self.skeleton.createImage = function(_, attachment)
    return type(self.images) == 'string' and
      love.graphics.newImage(self.images .. '/' .. attachment.name .. '.png') or
      self.images[attachment.name]
  end

  self.animationStateData = spine.AnimationStateData.new(self.skeletonData)
  self.animationState = spine.AnimationState.new(self.animationStateData)

  self.skeleton:setToSetupPose()

  for name, state in pairs(self.states) do
    state.name = name
  end

  self.on = self.on or {}

  self.animationState.onStart = function(track)
    local name = self.animationState.tracks[track].animation.name
    local state = self.states[name]
    if state and self.on.start then
      self.on.start(self, state)
    end
  end

  self.animationState.onEvent = function(_, event)
    local name = event.data.name
    if self.on[name] then
      self.on[name](self, event)
    end
  end

  self.animationState.onEnd = function(track)
    local name = self.animationState.tracks[track].animation.name
    local state = self.states[name]
    if state then
      if self.on['end'] then
        self.on['end'](self, state)
      end
      state.active = false
      if state.next then
        self:set(state.next)
      end
    end
  end

  self.animationState.onComplete = function(track)
    local name = self.animationState.tracks[track].animation.name
    local state = self.states[name]
    if state and self.on.complete then
      self.on.complete(self, state)
    end
  end

  self:resetTo(self.default)

  return self
end

function chiro:draw(x, y)
  x = (x or self.x or 0) + (self.offset and self.offset.x or 0)
  y = (y or self.y or 0) + (self.offset and self.offset.y or 0)
  local skeleton = self.skeleton
  skeleton.x, skeleton.y = x, y
  skeleton.flipX = self.flip and (type(self.flip) == 'table' and self.flip.x or self.flip) or false
  skeleton.flipY = type(self.flip) == 'table' and self.flip.y or false
  skeleton:updateWorldTransform()
  skeleton:draw()
end

function chiro:update(delta)
  self.animationState.timeScale = self.speed or 1
  for i = 0, self.animationState.trackCount do
    local track = self.animationState.tracks[i]
    if track then
      local animation = track.animation
      local state = self.states[animation.name]
      if state.length then
        local speed = animation.duration / state.length
        self.animationState.tracks[i].timeScale = speed
      else
        self.animationState.tracks[i].timeScale = state.speed or 1
      end
    end
  end

  self.animationState:update(delta)
  self.animationState:apply(self.skeleton)
end

function chiro:resetTo(name)
  self:clear()
  self:set(name)
end

function chiro:set(name)
  if not name then return end
  local state = self.states[name]
  if state and not state.active then
    local track = state.track or 0
    local loop = state.loop
    state.active = true
    self.animationState:setAnimationByName(track, name, loop)
  end
end

function chiro:clear()
  self.animationState:clearTracks()
end

return chiro
