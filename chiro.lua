local chiro = {}
chiro.__index = chiro

function chiro.create(config)
  local self = setmetatable(config, chiro)

  local name = self.dir:match('[^%/]+$')

  if self.dir then
    self.json = self.json or (self.dir .. '/' .. name .. '.json')
  end

  local loader = function (path) return love.graphics.newImage(self.dir .. '/' .. path) end
  local atlas = spine.TextureAtlas.new(spine.utils.readFile(self.dir .. '/' .. name .. ".atlas"), loader)

  self.skeletonJson = spine.SkeletonJson.new(spine.AtlasAttachmentLoader.new(atlas))
  self.skeletonJson.scale = self.scale or 1

  if type(self.json) == 'table' then
    self.skeletonData = self.skeletonJson:readSkeletonData(self.json)
  else
    self.skeletonData = self.skeletonJson:readSkeletonDataFile(self.json)
  end

  self.skeleton = spine.Skeleton.new(self.skeletonData)

  self.animationStateData = spine.AnimationStateData.new(self.skeletonData)
  self.animationState = spine.AnimationState.new(self.animationStateData)

  self.skeleton:setToSetupPose()

  for name, state in pairs(self.states) do
    state.name = name
  end

  self.on = self.on or {}

  self.animationState.onStart = function(entry)
    local name = entry.animation.name
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

  self.animationState.onEnd = function(entry)
    local name = entry.animation.name
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

  self.animationState.onComplete = function(entry)
    local name = entry.animation.name
    local state = self.states[name]
    if state and self.on.complete then
      self.on.complete(self, state)
    end
  end

  self:resetTo(self.default)

  self.skeletonRenderer = spine.SkeletonRenderer.new(true)

  return self
end

function chiro:draw(x, y)
  x = (x or self.x or 0) + (self.offset and self.offset.x or 0)
  y = (y or self.y or 0) + (self.offset and self.offset.y or 0)
  local skeleton = self.skeleton
  skeleton.x, skeleton.y = x, y
  if type(self.flip) == 'table' then
    skeleton.flipX = self.flip.x
    skeleton.flipY = not self.flip.y
  else
    skeleton.flipX = self.flip
    skeleton.flipY = true
  end
  skeleton:updateWorldTransform()
  self.skeletonRenderer:draw(skeleton)
end

function chiro:update(delta)
  self.animationState.timeScale = self.speed or 1
  for _, track in ipairs(self.animationState.tracks) do
    if track then
      local animation = track.animation
      local state = self.states[animation.name]
      if state.length then
        local speed = animation.duration / state.length
        track.timeScale = speed
      else
        track.timeScale = state.speed or 1
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
