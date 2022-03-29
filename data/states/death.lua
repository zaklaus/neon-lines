local class = require "class"
local state = require("state")
local AbstractState = require("states/abstract")

return class "DeathState" (AbstractState) {
    enter = function(self)
        state:setCursor(false)
        self.entertime = getTime() + 5

        tanks[-1].alive = false
        tanks[-1].pos = Vector3(
            math.random(WORLD_SIZE,(WORLD_SIZE)*WORLD_TILES[1]),
            20,
            math.random(WORLD_SIZE,(WORLD_SIZE)*WORLD_TILES[2])
        )
        tanks[-1].vel = Vector3()
    end,

    update = function(self, dt)
        if self.entertime < getTime() then
            state:switch("game")

            tanks[-1].alive = true
            tanks[-1].tails = {}
        end
    end,

    draw2d = function(self)
        local title = "You've been vaporized"
        local desc = "Restructuing the nano-matter combination..."

        local off = math.floor(self.resolution[2]/2.15)
        ui.drawTextShadow(self.titleFont, title, 0, off, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        ui.drawTextShadow(self.uiFont, desc, 0, off+50, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
    end,
}

