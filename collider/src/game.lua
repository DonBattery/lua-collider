local gra = require("src/graphics")
-- local utils = require("utils")

function _G.Color(red, green, blue)
    return {
        red / 255,
        green / 255,
        blue / 255,
    }
end

_G.Colors = {
    -- 1 "black",
    Color(0, 0, 0),

    -- 2 "red",
    Color(255, 0 ,0),

    -- 3 "green",
    Color(0, 255 ,0),

    -- 4 "blue",
    Color(0, 0 ,255),

    -- 5 "cyan",
    Color(0, 255 ,255),

    -- 6 "purple",
    Color(255, 0 ,255),

    -- 7 "yellow",
    Color(255, 255 ,0),

    -- 8 "white",
    Color(255, 255 ,255),
}

_G.BlockTypes = {
    [0] = {
        name = "air",
        color = 1,
    },
    [1] = {
        name = "ground",
        color = 3,
    },
    [2] = {
        name = "water",
        color = 4,
    },
    [3] = {
        name = "ice",
        color = 6,
    },
    [4] = {
        name = "spring",
        color = 7,
    },
}

-- 22*16
_G.DefaultLevel = {
    author = "Brainchild Design",
    -- bgm = "bump.mod",
    bgm = "endless.mp3",
    map = {
        {1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0},
        {1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0},
        {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1},
        {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},
        {1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 3, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},
        {2, 2, 2, 2, 2, 2, 2, 2, 1, 4, 0, 0, 0, 0, 0, 1, 3, 3, 3, 1, 1, 1},
        {2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    }
}

function _G.Level(source)
    if source == nil then
        return DefaultLevel
    end
end

function _G.Character(world)
    local character = {
        world=world
    }

    character.maxHorizontalSpeed = 100
    character.maxVerticalSpeed = 300
    character.size = 17
    character.facing = "right"
    character.isMoveing = false
    character.moveStartTimer = utils.Timer(0.1)

    character.anim = gra.CharacterAnimation()
    character.anim:setAnim("walkRight")

    character.collider = world:newRectangleCollider(80, 90, character.size - 2.5, character.size)
    character.collider:setFixedRotation(true)
    character.collider:setMass(0.198)
    character.collider:setFriction(0.33)
 
    return character
end

function _G.Player(name, controls)
    return {
        name = name,
        control = controls,
        score = 0,
        character = nil
    }
end

function _G.Game(debug)
    return {
        debug = debug,
        level = nil,
        players = {},
        state = "initial",

        changeState = function (self, newState)
            if self.debug then
                print("Changing state From: [" .. self.state .. "] To: [" .. newState .. "]")
            end
            self.state = newState
        end
    }
end

return {
    Game = Game,
    Level = Level,
    Color = Color,
    Colors = Colors,
    BlockTypes = BlockTypes,
}
