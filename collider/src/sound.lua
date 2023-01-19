-- Background music
local BGM = {
    tracks = {},

    currentTrack = nil,

    paused = false,

    volume = 5,

    loadTrack = function(self, source)
        table.insert(self.tracks, love.audio.newSource(source, "stream"))
    end,

    togglePause = function(self)
        if not self.paused then
            self.tracks[self.currentTrack]:pause()
            self.paused = true
        else
            self.tracks[self.currentTrack]:play()
            self.paused = false
        end
    end,

    setVolume = function(self, newVolume)
        self.volume = newVolume
        for i, track in ipairs(self.tracks) do
            track:setVolume(self.volume / 10)
        end
    end,

    play = function(self)
        if self.currentTrack == nil then
            if #self.tracks > 0 then
                self.currentTrack = 1
            else
                return
            end
        end
        self.paused = false
        local track = self.tracks[self.currentTrack]
        track:setVolume(self.volume / 10)
        track:play()
    end,

    update = function(self)
        if not self.paused then
            if not self.tracks[self.currentTrack]:isPlaying() then
                if self.currentTrack == #self.tracks then
                    self.currentTrack = 1
                else
                    self.currentTrack = self.currentTrack + 1
                end
                self.tracks[self.currentTrack]:play()
            end
        end
    end,
}

local Effect = function(src)
    return {
        {
            sound = src,
            hasPlayed = false,
            play = function(self, mode)
                if mode == "once" then
                    if not self.hasPlayed and not self.sound:isPlaying() then
                        self.hasPlayed = true
                        self.sound:play()
                    end
                elseif mode =="discrate" then
                    if not self.sound:isPlaying() then
                        self.hasPlayed = true
                        self.sound:play()
                    end
                else
                    self.hasPlayed = true
                    self.sound:stop()
                    self.sound:play()
                end
            end
        }
    }
end

local FX = {
    effects = {},

    paused = false,

    volume = 5,

    togglePause = function(self)
        self.paused = not self.paused
    end,

    setVolume = function(self, newVolume)
        self.volume = newVolume
        for i, effect in ipairs(self.effects) do
            effect:setVolume(self.volume / 10)
        end
    end,

    loadEffect = function(self, name, source)
        local src = love.audio.newSource(source, "static")
        src:setVolume(self.volume / 10)
        table[name] = Effect(src)
    end,

    play = function(self, name, mode)
        if not self.paused then
            self.effects[name]:play(mode)
        end
    end,
}

return {
    Effect = Effect,
    FX     = FX,
    BGM    = BGM,
}