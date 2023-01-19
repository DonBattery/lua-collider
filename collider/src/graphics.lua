-- local utils = require("utils")

-- github.com/kikito/anim8 (for sprite sheet animation)
local anim8 = require("../lib/anim8")

local rabbitSpriteSheet = love.graphics.newImage("assets/img/rabbit_sprite.png")

function CharacterAnimation(spriteSheet)
    if not spriteSheet then
        spriteSheet = rabbitSpriteSheet
    end

    local characterAnimation = {}

    characterAnimation.spriteSheet = spriteSheet
    characterAnimation.grid = anim8.newGrid(17, 17, characterAnimation.spriteSheet:getWidth(), characterAnimation.spriteSheet:getHeight())
    characterAnimation.animations = {}
    characterAnimation.animations.walkRight = anim8.newAnimation(characterAnimation.grid("1-4", 1), 0.1)
    characterAnimation.animations.walkLeft = characterAnimation.animations.walkRight:clone():flipH()
    characterAnimation.anim = nil

    characterAnimation.setAnim = function(self, anim)
        self.anim = self.animations[anim]
    end

    characterAnimation.setFrame = function(self, frame)
        self.anim:gotoFrame(frame)
    end

    characterAnimation.update = function(self, dt)
        self.anim:update(dt)
    end

    characterAnimation.draw = function(self, x, y)
        self.anim:draw(self.spriteSheet, x, y)
    end

    return characterAnimation
end

return {
    CharacterAnimation = CharacterAnimation
}
