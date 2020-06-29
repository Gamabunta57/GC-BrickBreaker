Ball = {}
Ball.__index = Ball

function Ball.new(racket)
    local ball = {
        x = 0,
        y = 0,
        r = 4,
        glued = true,
        vx = 0,
        vy = 0,
        sprite = love.graphics.newQuad(75, 136, 8, 8, image:getWidth(), image:getHeight()),
        shadowBalls = {},
        racket = racket,
        sampleRate = 0.01,
        currentSampleTime = 0,
        currentIndex = 1,
        ghostDecreaseSpeed = 3
    }
    ball.currentSampleTime = ball.sampleRate
    setmetatable(ball, Ball)

    for i=1,100 do
        ball.shadowBalls[i] = {x=0, y=0, c=0}
    end

    return ball
end

function Ball:update(dt)
    self.currentSampleTime = self.currentSampleTime - dt 
    if(self.currentSampleTime <= 0) then
        self.currentSampleTime = self.currentSampleTime + self.sampleRate;
        self.shadowBalls[self.currentIndex].x = self.x
        self.shadowBalls[self.currentIndex].y = self.y
        if(not(self.glued)) then
            self.shadowBalls[self.currentIndex].c = 1
        else
            self.shadowBalls[self.currentIndex].c = 0
        end
        self.currentIndex = self.currentIndex + 1
        if(self.currentIndex > #self.shadowBalls) then
            self.currentIndex = 1
        end
    end

    for i = #(self.shadowBalls), 1, -1 do
        self.shadowBalls[i].c = self.shadowBalls[i].c - dt * self.ghostDecreaseSpeed
    end

    if(self.glued) then
        self.x = self.racket.x + self.racket.width / 2 - self.r
        return
    else
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
    end
    if(self.x + self.r >= window.width) then
        self.vx = -self.vx
        self.x = window.width - self.r
        love.event.push("ballHit")
    elseif(self.x - self.r <= 0) then
        self.vx = - self.vx
        self.x = self.r
        love.event.push("ballHit")
    end

    if  self.racket.y - self.r <= self.y and
        self.racket.x - self.r <= self.x and
        self.racket.x + self.racket.width + self.r > self.x
    then
        self.y = self.racket.y - self.r
        self.vy = -math.abs(self.vy)
        love.event.push("ballHit")
    end

    if(self.y + self.r >= window.height) then
        self:reset()
        self.x = self.racket.x + self.racket.width / 2
        love.event.push("ballHit")
    elseif(self.y - self.r <= 0) then
        self.vy = -self.vy
        self.y = self.r
        love.event.push("ballHit")
    end
end

function Ball:reset()
    self.x = window.width / 2 - self.r
    self.y = window.height - 16 - self.r * 2
    self.glued = true;
end

function Ball:draw()
    local color = {1,1,1,1}
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(image, self.sprite, self.x, self.y)
    for i=1, #(self.shadowBalls) do
        if(self.shadowBalls[i].c > 0) then
            color[4] = self.shadowBalls[i].c
            love.graphics.setColor(color)
            love.graphics.draw(image, self.sprite, self.shadowBalls[i].x, self.shadowBalls[i].y)
        end
    end
    love.graphics.setColor({1,1,1,1})
end

