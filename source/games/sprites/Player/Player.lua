class('Player').extends(AnimatedSprite)

P1, P2 = 0, 1
playerImagetable = playdate.graphics.imagetable.new('images/character-table-32-32.png')


function Player:init(i, j, player)
    Player.super.init(self, playerImagetable)

    self:add()

    -- player variables
    self.bombs = {}
    self.nbBombMax = 1
    self.power = 1
    self.maxSpeed = 5
    self.canKick = false
    self.isDead = false

    self.lastDirection = 'Down'
    self.inputMovement = playdate.geometry.vector2D.new(0, 0)

    -- configure collision

    -- self:setCollideRect(0,0,32,32)
    self:setCollideRect(8, 16, 16, 16)

    local playerCollisionGroup = playerNumber == P1 and collisionGroup.player1 or collisionGroup.player2
    self:setGroups({ playerCollisionGroup })

    self:setCollidesWithGroups({
        collisionGroup.block,
        collisionGroup.bomb,
        collisionGroup.item,
        collisionGroup.explosion
    })

    -- place character
    local x, y = Noble.currentScene():getPositionAtCoordinates(i, j)

    self:moveTo(x, y - 8)
    self:playAnimation()
    self:setZIndex(10)

    -- add animation States

    local playerShiftSpriteSheet = player == P1 and 0 or 5
    local animationSpeed = 5

    self:addState("dead", 64 + playerShiftSpriteSheet, 67 + playerShiftSpriteSheet, {
        tickStep = animationSpeed,
        loop = false
    })

    self:addState('IdleUp', 1 + playerShiftSpriteSheet, 1 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    })
    self:addState('RunUp', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 2 + playerShiftSpriteSheet, 1 + playerShiftSpriteSheet, 3 + playerShiftSpriteSheet }
    })

    self:addState('IdleRight', 10 + playerShiftSpriteSheet, 10 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    })
    self:addState('RunRight', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 11 + playerShiftSpriteSheet, 10 + playerShiftSpriteSheet, 12 + playerShiftSpriteSheet }
    })

    self:addState('IdleDown', 19 + playerShiftSpriteSheet, 19 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    }).asDefault()
    self:addState('RunDown', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 20 + playerShiftSpriteSheet, 19 + playerShiftSpriteSheet, 21 + playerShiftSpriteSheet }
    })

    self:addState('IdleLeft', 28 + playerShiftSpriteSheet, 28 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    })
    self:addState('RunLeft', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 29 + playerShiftSpriteSheet, 28 + playerShiftSpriteSheet, 30 + playerShiftSpriteSheet }
    })

    self.states.dead.onAnimationEndEvent = function(self)
        self:remove()
    end
end

function Player:Move(x, y)
    local inputMovement = playdate.geometry.vector2D.new(x, y)
    inputMovement:normalize()
    self.inputMovement = inputMovement
end

function Player:collisionResponse(other)
    return 'slide'
end

function Player:update()
    Player.super.update(self)

    -- dead update
    if self.isDead then
        self:changeState('dead', true)
        return
    end

    -- change state with inputMovement
    if self.inputMovement.y < 0 then
        self:changeState('RunUp', true)
        self.lastDirection = "Up"
    elseif self.inputMovement.x > 0 then
        self:changeState('RunRight', true)
        self.lastDirection = "Right"
    elseif self.inputMovement.y > 0 then
        self:changeState('RunDown', true)
        self.lastDirection = "Down"
    elseif self.inputMovement.x < 0 then
        self:changeState('RunLeft', true)
        self.lastDirection = "Left"
    else
        self:changeState('Idle' .. self.lastDirection, true)
    end

    if (self.inputMovement.x ~= 0 and self.inputMovement.y == 0)
        or (self.inputMovement.y ~= 0 and self.inputMovement.x == 0) then
        local rect = getRect(
            self.x,
            self.y + 8,
            self.x + self.inputMovement.x * 16,
            self.y + 8 + self.inputMovement.y * 16
        )

        rect.x = rect.x - 1
        rect.y = rect.y - 1
        rect.w = rect.w + 2
        rect.h = rect.h + 2

        local collisions = playdate.graphics.sprite.querySpritesInRect(rect)

        local isObstacleFront = false
        if collisions then
            for i = 1, #collisions, 1 do
                if collisions[i]:isa(Block) then
                    isObstacleFront = true
                    break
                end
            end
        end

        if not isObstacleFront then
            if self.lastDirection == "Left" or self.lastDirection == "Right" then
                local i, j = Noble.currentScene():getcoordinates(self.x, self.y + 8)
                local _, y = Noble.currentScene():getPositionAtCoordinates(i, j)
                self:moveTo(self.x, y - 8)
            end
            if self.lastDirection == "Up" or self.lastDirection == "Down" then
                local i, j = Noble.currentScene():getcoordinates(self.x, self.y + 8)
                local x, _ = Noble.currentScene():getPositionAtCoordinates(i, j)
                self:moveTo(x, self.y)
            end
        end
    end

    -- move player With Collision
    local x, y, _, _ = self:moveWithCollisions(
        self.x + self.inputMovement.x * self.maxSpeed,
        self.y + self.inputMovement.y * self.maxSpeed
    )

    -- reset inmputMovement

    self.inputMovement.x = 0
    self.inputMovement.y = 0


    if #self.bombs > 0 and self.bombs[1].isExploded then
        table.remove(self.bombs, 1)
    end
end

function Player:dropBomb()
    local sprites = playdate.graphics.sprite.querySpritesAtPoint(self.x, self.y + 8)

    if sprites ~= nil then
        for i = 1, #sprites, 1 do
            if sprites[i]:isa(Bomb) then
                return
            end
        end
    end

    if #self.bombs >= self.nbBombMax then
        return
    end

    local i, j = Noble.currentScene():getcoordinates(self.x, self.y + 8)

    self.bombs[#self.bombs + 1] = Bomb(i, j, self.power)
    
end
