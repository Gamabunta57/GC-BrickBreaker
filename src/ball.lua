Ball = {}
Ball.__index = Ball

function Ball.new()
    local ball = {
        x = 0,
        y = 0,
        r = 4,
        glued = true,
        vx = 0,
        vy = 0,
        sprite = love.graphics.newQuad(75, 136, 8, 8, image:getWidth(), image:getHeight())
    }
    setmetatable(ball, Ball)
    return ball
end

function Ball:reset()
    self.x = window.width / 2 - self.r
    self.y = window.height - 16 - self.r * 2
    self.glued = true;
end

function Ball:draw()
    love.graphics.draw(image, self.sprite, self.x, self.y)
end

