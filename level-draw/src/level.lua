local function color(red, green, blue)
    return {
        red / 255,
        green / 255,
        blue / 255,
    }
end

local colors = {
    black = color(0, 0, 0),

    white = color(255, 255, 255),

    red = color(255, 0, 0),

    green = color(0, 255, 0),

    blue = color(0, 0, 255),

    cyan = color(0, 255, 255),

    purple = color(255, 0, 255),

    yellow = color(255, 255, 0),
}

local function round(num)
    local rem = math.abs(num) % 1
    local op = math.floor
    if num > 0 and rem >= 0.5 then op = math.ceil end
    if num < 0 and rem < 0.5 then op = math.ceil end
    return op(num)
end

local function checkTwoLines(x1, y1, x2, y2, x3, y3, x4, y4)
    local dx1, dy1 = x2 - x1, y2 - y1
    local dx2, dy2 = x4 - x3, y4 - y3
    local dx3, dy3 = x1 - x3, y1 - y3
    local d = dx1 * dy2 - dy1 * dx2
    if d == 0 then
        return false
    end
    local t1 = (dx2 * dy3 - dy2 * dx3) / d
    if t1 < 0 or t1 > 1 then
        return false
    end
    local t2 = (dx1 * dy3 - dy1 * dx3) / d
    if t2 < 0 or t2 > 1 then
        return false
    end
    -- point of intersection
    return true, x1 + t1 * dx1, y1 + t1 * dy1
end

local function Poly(scale, paddingLeft, paddingTop)
    local poly = {
        scale = scale,
        paddingLeft = paddingLeft,
        paddingTop = paddingTop,
        points = {}
    }

    poly.addPoint = function(self, x, y)
        table.insert(self.points, {
            x = x,
            y = y
        })
    end

    poly.addPointByCoord = function(self, x, y)
        self:addPoint(math.floor((x - self.paddingLeft) / self.scale), math.floor((y - self.paddingTop) / self.scale))
    end

    poly.isOccupied = function (self, x, y)
        for _, point in ipairs(self.points) do
            if point.x == x and point.y == y then
                return true
            end
        end
        return false
    end

    poly.isOccupiedByCoord = function(self, x, y)
        return self:isOccupied(math.floor((x - self.paddingLeft) / self.scale), math.floor((y - self.paddingTop) / self.scale))
    end

    poly.popLast = function(self)
        if #self.points > 0 then
            table.remove(self.points, #self.points)
        end
        return #self.points
    end

    poly.getCoordsOfPoint = function(self, pos)
        if pos == nil or pos == 0 then
            pos = #self.points
        end
        return self.points[pos].x * self.scale + self.paddingLeft, self.points[pos].y * self.scale + self.paddingTop
    end

    poly.draw = function(self)
        if #self.points > 1 then
            love.graphics.setColor(colors.yellow)
            love.graphics.setLineWidth(4)
            for i = 1, #self.points - 1 do
                local p1x, p1y = self:getCoordsOfPoint(i)
                local p2x, p2y = self:getCoordsOfPoint(i + 1)
                love.graphics.line(p1x, p1y, p2x, p2y)
            end
        end
    end

    return poly
end

local function NewLevel(width, height, screenWidth, screenHeight)
    local boxSize
    if width > height then
        boxSize = math.floor(screenWidth / width)
    else
        boxSize = math.floor(screenHeight / height)
    end
    boxSize = boxSize - 2

    local paddingTop = math.floor((screenHeight - (height * boxSize)) / 2)
    local paddingLeft = math.floor((screenWidth - (width * boxSize)) / 2)

    local level = {
        width = width,
        height = height,
        screenWidth = screenWidth,
        screenHeight = screenHeight,
        boxSize = boxSize,
        paddingTop = paddingTop,
        paddingLeft = paddingLeft,
        state = "beginDraw",
        nextMoveLegal = true,

        mousePos = {},
        nearestPos = {},
        polys = {}
    }

    level.draw = function(self)
        love.graphics.setColor(colors.white)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", 1, 1, self.screenWidth - 2, self.screenHeight - 2)
        for x = 1, self.width do
            for y = 1, self.height do
                love.graphics.rectangle("line", self.paddingLeft + ((x - 1) * self.boxSize),
                    self.paddingTop + ((y - 1) * self.boxSize), self.boxSize, self.boxSize)
            end
        end

        for _, poly in ipairs(self.polys) do
            poly:draw()
        end

        if self.state == "beginDraw" then
            love.graphics.setLineWidth(5)
        else
            love.graphics.setLineWidth(3)
        end
        if self.nextMoveLegal then
            love.graphics.setColor(colors.green)
        else
            love.graphics.setColor(colors.red)
        end
        love.graphics.circle("line", self.nearestPos.x, self.nearestPos.y, 5)

        if self.state == "searchNextCoord" then
            local px, py = self:lastPoly():getCoordsOfPoint()
            if self.nextMoveLegal then
                love.graphics.setColor(colors.green)
            else
                love.graphics.setColor(colors.red)
            end
            love.graphics.setLineWidth(3)
            love.graphics.line(px, py, self.nearestPos.x, self.nearestPos.y)
        end
    end

    level.lastPoly = function(self)
        return self.polys[#self.polys]
    end

    level.nearestPoint = function(self, x, y)
        x = round((x - self.paddingLeft) / self.boxSize) * self.boxSize + self.paddingLeft
        y = round((y - self.paddingTop) / self.boxSize) * self.boxSize + self.paddingTop
        return x, y 
    end

    level.isOccupied = function (self, x, y)
        for _, poly in ipairs(self.polys) do
            if poly:isOccupiedByCoord(x, y) then
                return true
            end
        end
        return false
    end

    level.changeState = function(self, newState)
        print("Changeing state from:", self.state, "to", newState)
        self.state = newState
    end

    level.update = function(self, dt)
        local mx, my = love.mouse.getPosition()
        local px, py = self:nearestPoint(mx, my)
        self.mousePos.x, self.mousePos.y = my, my
        self.nearestPos.x, self.nearestPos.y = px, py

        self.nextMoveLegal = true

        if self.state == "beginDraw" then
            self.nextMoveLegal = not self:isOccupied(self.nearestPos.x, self.nearestPos.y)
        end

        if self.state == "searchNextCoord" then
            local lastPoly = self:lastPoly()
            if #lastPoly.points > 2 then
                local lastX, lastY = lastPoly:getCoordsOfPoint()
                for i = 1, #lastPoly.points - 2 do
                    local p1x, p1y = lastPoly:getCoordsOfPoint(i)
                    local p2x, p2y = lastPoly:getCoordsOfPoint(i + 1)
                    local intersect, x, y = checkTwoLines(p1x, p1y, p2x, p2y, lastX, lastY, px, py)
                    if intersect then
                        self.nextMoveLegal = false
                    end
                end
            end

            if #lastPoly.points > 2 then
                local firstX, firstY = lastPoly:getCoordsOfPoint(1)
                if px == firstX and py == firstY then
                    self.nextMoveLegal = true
                end
            end
        end
    end

    level.mouseDown = function(self, x, y, button)
        if button == 1 then
            if self.state == "beginDraw" then
                if not self:isOccupied(self.nearestPos.x, self.nearestPos.y) then
                    table.insert(self.polys, Poly(self.boxSize, self.paddingLeft, self.paddingTop))
                    self:lastPoly():addPointByCoord(self.nearestPos.x, self.nearestPos.y)
                    self:changeState("searchNextCoord")
                end
            elseif self.state == "searchNextCoord" then
                if not self.nextMoveLegal then return end
                local lastPoly = self:lastPoly()
                -- if self.canContinue then
                lastPoly:addPointByCoord(self.nearestPos.x, self.nearestPos.y)
                -- end
                if #lastPoly.points > 2 then
                    local firstX, firstY = lastPoly:getCoordsOfPoint(1)
                    local lastX, lastY = lastPoly:getCoordsOfPoint()
                    if firstX == lastX and firstY == lastY then
                        self:changeState("beginDraw")
                    end
                end
            end
        end
    end

    level.mouseUp = function(self, x, y, button)

    end

    level.keyDown = function(self, key)
        -- ESC exits from the game
        if key == "escape" then
            love.event.quit()
        end

        if key == "backspace" then
            if self.state == "searchNextCoord" then
                if #self.polys > 0 then
                    local lastPoly = self:lastPoly()
                    if #lastPoly.points > 1 then
                        lastPoly:popLast()
                        print("Deleted line. Remaining:", #lastPoly.points)
                    else
                        table.remove(self.polys, #self.polys)
                        self:changeState("beginDraw")
                    end
                end
            elseif self.state == "beginDraw" then
                if #self.polys > 0 then
                    self:lastPoly():popLast()
                    self:changeState("searchNextCoord")
                end
            end
        end

        if key == "p" then
            for i, poly in ipairs(self.polys) do
                print("Polygon #", i)
                for _, point in ipairs(poly.points) do
                    print("\t X", point.x, "Y", point.y)
                end
            end
        end

    end

    return level
end

return {
    NewLevel = NewLevel
}
