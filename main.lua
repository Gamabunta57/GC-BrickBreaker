require("src/racket")
require("src/ball")
require("src/brick")

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    print("debug on")
    require("lldebugger").start()
    io.stdout:setvbuf('no')
end

window = {
    width = 0,
    height = 0
}
racket = nil
ball = nil
bricks = {}
image = nil

levels = {
    {
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0},
        {0, 0, 0, 0, 0, 0, 1, 1, 2, 3, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 1, 1, 2, 3, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0},
        {0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    },
    {
        {0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0},
        {0, 2, 0, 1, 1, 0, 1, 1, 2, 3, 2, 1, 1, 0, 0, 1, 1, 0, 2, 0},
        {0, 2, 0, 1, 1, 0, 1, 1, 2, 3, 2, 1, 1, 0, 0, 1, 1, 0, 2, 0},
        {0, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    },
    {
        {0, 2, 2, 2, 3, 3, 3, 2, 1, 1, 1, 2, 3, 3, 3, 2, 2, 2, 2, 0},
        {0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0},
        {0, 3, 2, 1, 2, 3, 1, 1, 2, 3, 2, 1, 1, 3, 2, 1, 1, 2, 3, 0},
        {0, 3, 2, 1, 2, 3, 1, 1, 2, 3, 2, 1, 1, 3, 2, 1, 1, 2, 3, 0},
        {0, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0},
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    },
    currentLevel = 1
}

function love.load()
    window.width, window.height = love.graphics:getDimensions()
    image = love.graphics.newImage("assets/images/breakout_pieces_1.png")
    Brick.init()
    initSounds()
    racket = Racket.new()
    ball = Ball.new(racket)
    reset()
    love.event.push("gameStart")
end

function love.update(dt)
    racket.x = love.mouse.getX() - racket.width / 2
    if(racket.x > window.width - racket.width) then
        racket.x = window.width - racket.width
    elseif (racket.x < 0) then
        racket.x = 0
    end 

    ball:update(dt)
    if(not(ball.glued)) then
        checkCollisionWithBrick()
    end
end

function love.mousepressed(x, y, button)
    if(button == 1 and ball.glued) then
        ball.glued = false
        ball.vx = 200
        ball.vy = - 250
    end
end

function love.draw()
    racket:draw()
    ball:draw()
    for j = 1, #bricks do
        for i=1, #(bricks[j]) do
            if(bricks[j][i].life > 0) then
                bricks[j][i]:draw()
            end
        end
    end
end

function reset()
    ball:reset()
    racket:reset()
    bricks = {}

    local level = levels[levels.currentLevel]
    local rowCount = #level
    local brickPerRowCount = #(level[1])

    for j = 1, rowCount do
        local brickRow = {}
        for i = 1, brickPerRowCount do
            local brick = Brick.new((i - 1) * Brick.width, (j - 1) * Brick.height, level[j][i])
            table.insert(brickRow, brick)
        end
        table.insert(bricks, brickRow)
    end
end

function checkCollisionWithBrick()
    local ballCol = math.floor(ball.x / Brick.width);
    local ballRow = math.floor(ball.y / Brick.height);

    if  bricks[ballRow + 1] ~= nil and
        bricks[ballRow + 1][ballCol + 1] ~= nil and
        bricks[ballRow + 1][ballCol + 1].life > 0
    then
        ball.vy = -ball.vy
        bricks[ballRow + 1][ballCol + 1].life = bricks[ballRow + 1][ballCol + 1].life - 1
        if(bricks[ballRow + 1][ballCol + 1].life > 0) then
            love.event.push("ballHit")
        else
            love.event.push("brickBreak")
        end
    end
end


sounds = nil
function initSounds()
    sounds = {
        music = love.audio.newSource("assets/musics/Just_a_Joke.mp3", "stream"),
        ballHit = love.audio.newSource("assets/sounds/DM-CGS-21.wav", "static"),
        brickBreak = love.audio.newSource("assets/sounds/DM-CGS-39.wav", "static")
    }
end

love.handlers.gameStart = function()
    local sound = sounds.music
    sound:setLooping(true)
    sound:play()
end

love.handlers.ballHit = function()
    sounds.ballHit:stop()
    sounds.ballHit:play()
end

love.handlers.brickBreak = function ()
    sounds.brickBreak:stop()
    sounds.brickBreak:play()
end