-- Import modules

-- The Love2d Framework
_G.love  = require("love")

-- github.com/Ulydev/push (for scaling the window and fullscreen mode)
_G.push  = require("lib/push")

-- github.com/a327ex/windfield (for interacting with Box2D)
_G.wf = require("lib/windfield")

-- github.com/kikito/anim8 (for sprite sheet animation)
_G.anim8 = require("lib/anim8")

-- Our Text module
_G.text = require("src/text")

-- Our Sound module
_G.sound = require("src/sound")

-- Our Render module
-- _G.render = require("src/render")

-- Our Game module
_G.level = require("src/level")

-- Our Utils module
_G.utils = require("src/utils")

function love.load()
    -- Drawing constants
    _G.blockSize = 18

    _G.jumpForce = 37
    _G.screenWidth = 22 * blockSize
    _G.screenHeight = 16 * blockSize


    -- Graphics options
    -- love.graphics.setDefaultFilter("linear", "linear")
    love.graphics.setDefaultFilter("nearest", "nearest")

    text.loadFont("basic", "assets/font/rishgulartry.ttf")

    -- set up push for window scaling
    local windowWidth, windowHeight = love.graphics.getDimensions()
    windowWidth, windowHeight = windowWidth*.75, windowHeight*.75
    push:setupScreen(screenWidth, screenHeight, windowWidth, windowHeight, {
        fullscreen = false,
        resizable = true,
        highdpi = true,
        canvas = false,
    })

    _G.lvl = level.LoadFromFile("assets/data/level/test.json", blockSize)

    _G.world = wf.newWorld(0, 300)
    _G.showWorldGeomentry = utils.Toggle()

    _G.player = {}

    player.speed = 33
    player.maxHorizontalSpeed = 100
    player.maxVerticalSpeed = 300
    player.size = 17
    player.facing = "right"
    player.isMoveing = false
    player.moveStartTimer = utils.Timer(0.1)

    -- player.spriteSheet = love.graphics.newImage("assets/img/sprite.png")
    player.spriteSheet = love.graphics.newImage("assets/img/rabbit_sprite.png")
    player.grid = anim8.newGrid(17, 17, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {}
    player.animations.right = anim8.newAnimation(player.grid("1-4", 1), 0.1)
    player.animations.left = player.animations.right:clone():flipH()
    player.anim = player.animations.right

    player.collider = world:newRectangleCollider(80, 90, player.size - 2.5, player.size)
    -- player.collider = world:newBSGRectangleCollider(80, 90, player.size - 2.5, player.size, 2)


    player.collider:setFixedRotation(true)

    player.collider:setMass(0.198)
    -- player.collider:setDensity(10)

    player.collider:setFriction(0.33)

    lvl:buildWorldMap(world)

    sound.BGM:loadTrack("assets/bgm/" .. lvl.bgm)
    sound.BGM:play()
end

-- handle ESC and the F-keys separately (called by Löve on key pressed event)
function love.keypressed(key)
    -- ESC exits from the game
     if key == "escape" then
        love.event.quit()
     end

    -- F1 toggles fullscreen
     if key == "f1" then
        push:switchFullscreen()
     end

     -- F2 toggles the background music
     if key == "f2" then
        sound.BGM:togglePause()
     end

     -- F3 toggles the sound effects
     if key == "f3" then
        sound.FX:togglePause()
     end

     -- F4 toggles the sound effects
     if key == "f4" then
        showWorldGeomentry:toggle()
     end

     if key == "up" then
        player.collider:applyLinearImpulse(0, -jumpForce)
     end
end

function love.update(dt)
    sound.BGM:update()

    local directionPressed = false
    if love.keyboard.isDown("left") then
        directionPressed = true
        player.facing = "left"
        player.anim = player.animations.left
        player.collider:applyForce(-player.speed, 0)
    elseif love.keyboard.isDown("right") then
        directionPressed = true
        player.facing = "right"
        player.anim = player.animations.right
        player.collider:applyForce(player.speed, 0)
    end
    local px, py = player.collider:getLinearVelocity()
    local newPx, newPy = px, py
    if math.abs(px) > player.maxHorizontalSpeed then
        if px > 0 then
            newPx = player.maxHorizontalSpeed
        else
            newPx = -player.maxHorizontalSpeed
        end
    end
    if math.abs(py) > player.maxVerticalSpeed then
        if py > 0 then
            newPy = player.maxVerticalSpeed
        else
            newPy = -player.maxVerticalSpeed
        end
    end
    player.collider:setLinearVelocity(newPx, newPy)

    if directionPressed then
        player.moveStartTimer:update(dt)
        if not player.moveStartTimer.triggered then
            player.anim:gotoFrame(2)
        else
            player.anim:update(dt)
        end
    else
        player.moveStartTimer:reset()
        player.anim:gotoFrame(1)
    end

    world:update(dt)
end

-- when the window is resized we pass the new dimensions to push so it knows how to scale
-- called by Löve on window resized event
function love.resize(w, h)
    push:resize(w, h)
end

function love.draw()
    -- start the auto-scaler
    push:apply("start")

    lvl:draw()

    if showWorldGeomentry.on then
        world:draw()
    end

    -- text.print("Electronic fun", 45, 77, model.Color(255, 0, 0), "basicLG")
    -- text.print("For everyone!", 97, 117, model.Color(255, 0, 0), "basic")
    local px, py = player.collider:getPosition()

    
    love.graphics.setColor(1, 1, 1)
    player.anim:draw(player.spriteSheet, px - player.size / 2, py + 1 - player.size / 2)
    
    -- love.graphics.setColor(1,1,1)
    -- love.graphics.circle("fill", px, py, 1)
    -- love.graphics:draw(player.spriteSheet, 10 , 10)

    -- stop the auto-scaler
    push:apply("end")
end
