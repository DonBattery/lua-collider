local function getNeighbours(map, type, x, y)
    local checkPoints = {}
    if x > 1 then
        table.insert(checkPoints, {
            x = x - 1,
            y = y,
        })
    end
    if x < #map[1] then
        table.insert(checkPoints, {
            x = x + 1,
            y = y,
        })
    end
    if y > 1 then
        table.insert(checkPoints, {
            x = x,
            y = y - 1,
        })
    end
    if y < #map then
        table.insert(checkPoints, {
            x = x,
            y = y + 1,
        })
    end

    local neighbours = {}
    for i, checkPoint in ipairs(checkPoints) do
        if map[checkPoint.y][checkPoint.x] == type then
            table.insert(neighbours, checkPoint)
        end
    end

    return neighbours
end

local timers = {}
local debug = false

local function add(timerName, timer)
    if timers[timerName] ~= nil and debug then
        print("Timer " .. timerName .. " is already exists, overwriting...")
    end
    timers[timerName] = timer
end

local function update(dt)
    for timerName, timer in pairs(timers) do
        timer:update(dt)
        if debug then
            print("Timer Update: " .. timerName, "Elapsed time: ", timer.elapsedTime)
        end
    end
end

local function remove(timerName)
    if timers[timerName] == nil then
        if debug then
            print("Attempting to remove " .. timerName .. ", but there is no such a timer")
        end
        return
    end
    timers[timerName] = nil
    if debug then
        print("Timer Removed: " .. timerName)
    end
end

function Timer(triggerAt, callback)
    local timer = {
        triggerAt = triggerAt,
        callback = callback,
        elapsedTime = 0,
        triggered = false
    }

    timer.update = function (self, dt)
        self.elapsedTime = self.elapsedTime + dt
        if not self.triggered then
            if self.elapsedTime >= triggerAt then
                self.triggered = true
                if self.callback ~= nil then
                    self.callback()
                end
            end
        end
    end

    timer.reset = function (self)
        self.triggered = false
        self.elapsedTime = 0
    end

    return timer
end

function LoopTimer(loopIntervall, callback, callOnFirstUpdate)
    local loopTimer = {
        loopIntervall = loopIntervall,
        callback = callback,
        callOnFirstUpdate = callOnFirstUpdate,
        elapsedTime = 0,
    }

    loopTimer.update = function (self, dt)
        self.elapsedTime = self.elapsedTime + dt
        if self.callOnFirstUpdate then
            self.callOnFirstUpdate = false
            self.callback()
        elseif self.elapsedTime > self.loopIntervall then
            self.elapsedTime = 0
            self.callback()
        end
    end

    loopTimer.reset = function (self)
        self.elapsedTime = 0
    end

    return loopTimer
end

function Switch(onCallback, offCallback)
    local switch = {
        onCallback = onCallback,
        offCallback =  offCallback,
        on = false,
    }

    switch.turnOn = function (self)
        self.on = true
        if onCallback then
            onCallback()
        end
    end

    switch.turnOff = function (self)
        self.on = false
        if offCallback then
            offCallback()
        end
    end

    switch.toggle = function (self)
        if self.on then
            self:turnOff()
        else
            self:turnOn()
        end
    end

    return switch
end

function Toggle(callback)
    local toggle = {
        callback = callback,
        on = false,
    }

    toggle.toggle = function (self)
        self.on = not self.on
        if self.callback then
            self.callback()
        end
    end

    return toggle
end

return {
    Timer = Timer,
    LoopTimer = LoopTimer,
    Switch = Switch,
    Toggle = Toggle,
}