local class = require "class"
local state = require("state")
local AbstractState = require("states/abstract")

return class "PausedState" (AbstractState) {
    __init__ = function(self)
        AbstractState.__init__(self)
        self.elements = {}
        self.offsety = math.floor(self.resolution[2] / 3.0)

        local padding = 8
        local groupMargin = 25
        local buttonHeight = 50
        local yoffset = self.offsety + 50

        yoffset = yoffset + buttonHeight + padding
        local resume = uiButton("resume", self.resolution[1]/2-100, yoffset, 200, 50, function()
            state:switch("game")
        end)

        yoffset = yoffset + buttonHeight + padding
        local btnDisconnect = uiButton("Disconnect", self.resolution[1]/2-100, yoffset, 200, 50, function()
            nativedll.disconnect()
            nativedll.serverStop()
            isConnected = false
            state:switch("menu")
        end)

        yoffset = yoffset + groupMargin

        yoffset = yoffset + buttonHeight + padding
        local settings = uiButton("Sound settings", self.resolution[1]/2-100, yoffset, 200, 50, function()
            state:switch("settings")
        end)

        yoffset = yoffset + buttonHeight + padding
        local btnDiscord = uiButton("Our discord", self.resolution[1]/2-100, yoffset, 200, 50, function()
            nativedll.openLink()
        end)

        yoffset = yoffset + buttonHeight + padding
        local btnQuit = uiButton("Quit", self.resolution[1]/2-100, yoffset, 200, 50, function()
            ExitGame()
        end)

        table.insert(self.elements, resume)
        table.insert(self.elements, btnDisconnect)
        table.insert(self.elements, settings)
        table.insert(self.elements, btnDiscord)
        table.insert(self.elements, btnQuit)

        self.focusables = self.elements
    end,

    enter = function(self)
        state:setCursor(true)
        ui.updateFocusables(self.focusables, 0)
    end,

    update = function(self)
        if GetKeyDown(KEY_ESCAPE) then
            state:switch("game")
        end

        for _,el in pairs(self.elements) do el:update(dt) end
    end,

    draw2d = function(self)
        local title = "You are paused"
        local desc = "(Not really)"

        BindTexture(0)
        ui.drawTextShadow(self.titleFont, title, 0, self.offsety, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        ui.drawTextShadow(self.uiFont, desc, 0, self.offsety+50, self.resolution[1], 25, FONTFLAG_SINGLELINE|FONTFLAG_CENTER|FONTFLAG_NOCLIP)
        for _,el in pairs(self.elements) do el:draw() end
    end,
}
