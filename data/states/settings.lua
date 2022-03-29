local class = require "class"
local state = require("state")
local AbstractState = require("states/abstract")

return class "SettingsState" (AbstractState) {
    __init__ = function(self)
        AbstractState.__init__(self)
        self.elements = {}
        self.offsety = math.floor(self.resolution[2] / 3.0)

        local padding = 8
        local groupMargin = 25
        local buttonHeight = 50
        local yoffset = self.offsety + 50

        yoffset = yoffset + buttonHeight + padding
        local a1 = uiSlider({cur = config.volume.music}, "Music volume", self.resolution[1]/2-100, yoffset, 200, 50, function(self, value)
            config.volume.music = value
            SaveState(encode(config))
        end)

        yoffset = yoffset + buttonHeight + padding
        local a2 = uiSlider({cur = config.volume.sound}, "SFX volume", self.resolution[1]/2-100, yoffset, 200, 50, function(self, value)
            config.volume.sound = value
            SaveState(encode(config))
        end)

        yoffset = yoffset + groupMargin

        yoffset = yoffset + buttonHeight + padding
        local btnQuit = uiButton("< Back", self.resolution[1]/2-100, yoffset, 200, 50, function()
            if state:previous() == "pause" then
                state:switch("pause")
            else
                state:switch("menu")
            end
        end)

        table.insert(self.elements, a1)
        table.insert(self.elements, a2)
        table.insert(self.elements, btnQuit)

        self.focusables = self.elements
    end,

    enter = function(self)
        state:setCursor(true)
        ui.updateFocusables(self.focusables, 0)
    end,

    update = function(self)
        for _,el in pairs(self.elements) do el:update(dt) end
    end,

    draw2d = function(self)
        local title = "Settings"
        local desc = "volume, sound, musical perception and other names"

        BindTexture(0)
        ui.drawTextShadow(self.titleFont, title, 0, self.offsety, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        ui.drawTextShadow(self.uiFont, desc, 0, self.offsety+50, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        for _,el in pairs(self.elements) do el:draw() end
    end,
}
