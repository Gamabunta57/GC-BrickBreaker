Brick = {
    sprites = {},
    width = 32,
    height = 16
}
Brick.__index = Brick;

function Brick.new(x, y, life)
    local brick = {
        x = x or 0,
        y = y or 0,
        life = life or 1
    }
    setmetatable(brick, Brick)
    return brick
end

function Brick:draw()
    love.graphics.draw(image, self.sprites[self.life], self.x, self.y)
end

function Brick.init()
    Brick.sprites = {
        love.graphics.newQuad(8, 8, Brick.width, Brick.height, image:getWidth(), image:getHeight()),
        love.graphics.newQuad(48, 8, Brick.width, Brick.height, image:getWidth(), image:getHeight()),
        love.graphics.newQuad(8, 28, Brick.width, Brick.height, image:getWidth(), image:getHeight())
    }
end