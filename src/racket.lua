Racket = {}
Racket.__index = Racket

function Racket.new()
    local r = {
        x = 0,
        y = 0,
        width = 64,
        height = 16,
        sprite = love.graphics.newQuad(116, 72, 64, 16, image:getWidth(), image:getHeight())
    }
    setmetatable(r, Racket)
    return r
end

function Racket:draw()
    love.graphics.draw(image, self.sprite, self.x, self.y)
end

function Racket:reset()
    self.y = window.height - self.height;
    self.x = (window.width - self.width) / 2 
end