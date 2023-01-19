local json = require("../lib/json")
local model = require("src/game")

local function loadMap(fileName)
    local file = io.open(fileName, "r")

    if file == nil then return end

    local content = file:read("*all")

    file:close()

    return json.decode(content)
end

function LoadFromFile(fileName, blockSize)
    local level = loadMap(fileName)
    if not level then return end

    level.blockSize = blockSize

    level.buildWorldMap = function (self, world)
        for _, element in ipairs(self.map_elements) do
            local coords = {}
            for _, point in ipairs(element.bounding_polygon) do
                table.insert(coords, {
                    x = point.x * self.blockSize,
                    y = point.y * self.blockSize,
                })
            end
            for index, coord in ipairs(coords) do
                local nextCoord
                if index < #coords then
                    nextCoord = coords[index + 1]
                else
                    nextCoord = coords[1]
                end
                local line = world:newLineCollider(coord.x, coord.y, nextCoord.x, nextCoord.y)
                line:setType("static")
                if element.block_type == "ground" then
                    if coord.y == nextCoord.y then
                        line:setFriction(0.33)
                    else
                        line:setFriction(0.0)
                    end
                elseif  element.block_type == "ice" then
                    line:setFriction(0)
                end
            end
        end
    end

    level.getCell = function (self, x, y)
        return model.BlockTypes[y][x]
    end

    level.getCellByCoords = function (self, x, y)
        return model.BlockTypes[self.cell_map[math.floor(y / self.blockSize)][math.floor(x / self.blockSize)]]
    end

    level.draw = function (self)
        for y, row in ipairs(self.cell_map) do
            for x, block in ipairs(row) do
                if block > 0 then
                    love.graphics.setColor(model.Colors[model.BlockTypes[block].color])
                    love.graphics.rectangle("fill", (x - 1) * self.blockSize, (y - 1) * self.blockSize, self.blockSize, self.blockSize)
                end
            end
        end
    end

    return level
end

return {
    LoadFromFile = LoadFromFile,
}