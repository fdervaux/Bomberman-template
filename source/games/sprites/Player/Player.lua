class('Player').extends(NobleSprite)

P1, P2 = 0, 1
playerImagetable = playdate.graphics.imagetable.new('images/character-table-32-32.png')


function Player:init(i, j, player)
    Player.super.init(self)

    self:add()
    self:setSize(16, 16)

    self.animatedSprite = AnimatedSprite(playerImagetable)
    self.animatedSprite:add()

    self.playerNumber = player

    -- player variables
    self.bombs = {}
    self.nbBombMax = 1
    self.power = 1
    self.maxSpeed = 5
    self.canKick = false
    self.isDead = false

    self.Direction = 'Down'
    self.inputMovement = playdate.geometry.vector2D.new(0, 0)

    -- configure collision

    -- self:setCollideRect(0,0,32,32)
    self:setCollideRect(0, 0, 16, 16)

    local playerCollisionGroup = self.playerNumber == P1 and collisionGroup.p1 or collisionGroup.p2
    self:setGroups({ playerCollisionGroup })

    self:setCollidesWithGroups({
        collisionGroup.block,
        collisionGroup.bomb,
        collisionGroup.item,
        collisionGroup.explosion
    })

    -- place character
    local x, y = Noble.currentScene():getPositionAtCoordinates(i, j)

    self:moveTo(x, y)
    self.animatedSprite:playAnimation()
    self.animatedSprite:setZIndex(10)
    self.animatedSprite:moveTo(self.x, self.y - 8)


    -- add animation States

    local playerShiftSpriteSheet = player == P1 and 0 or 5
    local animationSpeed = 5

    self.animatedSprite:addState("dead", 64 + playerShiftSpriteSheet, 67 + playerShiftSpriteSheet, {
        tickStep = animationSpeed,
        loop = false
    })

    self.animatedSprite:addState('IdleUp', 1 + playerShiftSpriteSheet, 1 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    })
    self.animatedSprite:addState('RunUp', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 2 + playerShiftSpriteSheet, 1 + playerShiftSpriteSheet, 3 + playerShiftSpriteSheet }
    })

    self.animatedSprite:addState('IdleRight', 10 + playerShiftSpriteSheet, 10 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    })
    self.animatedSprite:addState('RunRight', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 11 + playerShiftSpriteSheet, 10 + playerShiftSpriteSheet, 12 + playerShiftSpriteSheet }
    })

    self.animatedSprite:addState('IdleDown', 19 + playerShiftSpriteSheet, 19 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    }).asDefault()
    self.animatedSprite:addState('RunDown', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 20 + playerShiftSpriteSheet, 19 + playerShiftSpriteSheet, 21 + playerShiftSpriteSheet }
    })

    self.animatedSprite:addState('IdleLeft', 28 + playerShiftSpriteSheet, 28 + playerShiftSpriteSheet, {
        tickStep = animationSpeed
    })
    self.animatedSprite:addState('RunLeft', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        frames = { 29 + playerShiftSpriteSheet, 28 + playerShiftSpriteSheet, 30 + playerShiftSpriteSheet }
    })

    self.animatedSprite.states.dead.onAnimationEndEvent = function(self)
        self:remove()
    end

    self.animationSequence = Sequence.new():from(1)

end

function Player:Move(x, y)
    local inputMovement = playdate.geometry.vector2D.new(x, y)
    inputMovement:normalize()
    self.inputMovement = inputMovement
end

function Player:update()
    Player.super.update(self)

    -- dead update
    if self.isDead then
        self:changeState('dead', true)
        return
    end

    -- change state with inputMovement
    local lastState = self.animatedSprite.currentState

    if self.inputMovement.y < 0 then
        self.animatedSprite:changeState('RunUp', true)
        self.Direction = "Up"
    elseif self.inputMovement.x > 0 then
        self.animatedSprite:changeState('RunRight', true)
        self.Direction = "Right"
    elseif self.inputMovement.y > 0 then
        self.animatedSprite:changeState('RunDown', true)
        self.Direction = "Down"
    elseif self.inputMovement.x < 0 then
        self.animatedSprite:changeState('RunLeft', true)
        self.Direction = "Left"
    else
        self.animatedSprite:changeState('Idle' .. self.Direction, true)
    end

    if (self.inputMovement.x ~= 0 and self.inputMovement.y == 0)
        or (self.inputMovement.y ~= 0 and self.inputMovement.x == 0) then
        local rect = getRect(
            self.x,
            self.y,
            self.x + self.inputMovement.x * 16,
            self.y + self.inputMovement.y * 16
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

        if not isObstacleFront and lastState ~= self.animatedSprite.currentState then
            if self.Direction == "Left" or self.Direction == "Right" then
                local i, j = Noble.currentScene():getcoordinates(self.x, self.y)
                local _, y = Noble.currentScene():getPositionAtCoordinates(i, j)
                if y ~= self.y then
                    self.animationSequence = Sequence.new():from(0):to(1, 0.2, Ease.outCubic)
                    self.animationSequence:start()
                    self:moveTo(self.x, y)
                end
            end
            if self.Direction == "Up" or self.Direction == "Down" then
                local i, j = Noble.currentScene():getcoordinates(self.x, self.y)
                local x, _ = Noble.currentScene():getPositionAtCoordinates(i, j)
                if x ~= self.x then
                    self.animationSequence = Sequence.new():from(0):to(1, 0.3, Ease.outCubic)
                    self.animationSequence:start()
                    self:moveTo(x, self.y)
                end
            end
        end
    end

    -- move player With Collision
    local x, y, _, _ = self:moveWithCollisions(
        self.x + self.inputMovement.x * self.maxSpeed,
        self.y + self.inputMovement.y * self.maxSpeed
    )


    local spriteX = playdate.math.lerp(self.animatedSprite.x, self.x, self.animationSequence:get())
    local spriteY = playdate.math.lerp(self.animatedSprite.y, self.y - 8, self.animationSequence:get())

    self.animatedSprite:moveTo(spriteX, spriteY)

    -- self.animatedSprite:moveTo(self.x, self.y - 8)
    -- reset inmputMovement

    self.inputMovement.x = 0
    self.inputMovement.y = 0


    if #self.bombs > 0 and self.bombs[1].isExploded then
        table.remove(self.bombs, 1)
    end
end

function Player:collisionResponse(other)
    if self.playerNumber == P1 and maskContainsGroup(other:getGroupMask(), collisionGroup.ignoreP1) then
        return playdate.graphics.sprite.kCollisionTypeOverlap
    end

    if self.playerNumber == P2 and maskContainsGroup(other:getGroupMask(), collisionGroup.ignoreP2) then
        return playdate.graphics.sprite.kCollisionTypeOverlap
    end

    return playdate.graphics.sprite.kCollisionTypeSlide
end

function Player:dropBomb()
    local sprites = self:overlappingSprites()

    for i = 1, #sprites, 1 do
        if sprites[i]:isa(Bomb) then
            return
        end
    end


    if #self.bombs >= self.nbBombMax then
        return
    end

    local i, j = Noble.currentScene():getcoordinates(self.x, self.y)

    self.bombs[#self.bombs + 1] = Bomb(i, j, self.power)
end
