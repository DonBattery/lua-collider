_G.love  = require("love")

_G.text  = require("src.text")

_G.level  = require("src.level")

_G.screenWidth = 1400
_G.screenHeight = 1000

_G.mapWidth = 22
_G.mapHeight = 16

function love.load()
    -- Graphics options
    -- love.graphics.setDefaultFilter("linear", "linear")
    love.graphics.setDefaultFilter("nearest", "nearest")

    _G.currentLevel = level.NewLevel(mapWidth, mapHeight, screenWidth, screenHeight)

    text.loadFont("basic", "assets/font/open-sans.ttf")
end

function love.keypressed(key)
    currentLevel:keyDown(key)
end

function love.update(dt)
    currentLevel:update(dt)
end

function love.mousepressed(x, y, button)
    currentLevel:mouseDown(x, y, button)
end

function love.mousereleased(x, y, button)
    currentLevel:mouseUp(x, y, button)
end

function love.draw()
    currentLevel:draw()
end
