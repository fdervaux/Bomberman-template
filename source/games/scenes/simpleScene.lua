SimpleScene = {}
class("SimpleScene").extends(NobleScene)

SimpleScene.baseColor = Graphics.kColorWhite

local menu
local sequence

function SimpleScene:init()
    SimpleScene.super.init(self)

    menu = Noble.Menu.new(false, Noble.Text.ALIGN_CENTER, false, Graphics.kColorWhite, 4, 6, 0, Noble.Text.FONT_SMALL)

    menu:addItem('Ⓐ Start Game', function()
        Noble.transition(World, 0.5, Noble.TransitionType.SLIDE_OFF_LEFT)
    end)

    SimpleScene.inputHandler = {
        upButtonDown = function()
            menu:selectPrevious()
        end,
        downButtonDown = function()
            menu:selectNext()
        end,
        AButtonDown = function()
            menu:click()
        end
    }
end

function SimpleScene:enter()
    SimpleScene.super.enter(self)

    playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

    sequence = Sequence.new():from(0):to(180, 1, Ease.outBounce)

    if sequence then sequence:start() end

    local sound = playdate.sound.sampleplayer
    self.backgroundMusic = sound.new('sounds/Title Screen.wav')
    self.backgroundMusic:setVolume(0.6)
    self.backgroundMusic:play(0, 1)

    self.background = NobleSprite("images/background2")

    self.background:add()
    self.background:moveTo(200, 120)
end

function SimpleScene:start()
    SimpleScene.super.start(self)

    menu:activate()
end

function SimpleScene:drawBackground()
    SimpleScene.super.drawBackground(self)
end

function SimpleScene:update()
    SimpleScene.super.update(self)
    menu:draw(200, sequence:get())
end

function SimpleScene:exit()
    SimpleScene.super.exit(self)
    sequence = Sequence.new():from(180):to(0, 0.25, Ease.inOutCubic)
    if sequence then sequence:start() end
    self.backgroundMusic:stop()
end

function SimpleScene:finish()
    SimpleScene.super.finish(self)
end
