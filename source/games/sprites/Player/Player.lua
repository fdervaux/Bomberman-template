class('Player').extends(AnimatedSprite)

P0, P1 = 0, 1
playerImagetable = playdate.graphics.imagetable.new('images/character-table-32-32.png')


function Player:init(i, j, player)
    Player.super.init(self, playerImagetable, nil, nil)

    self:add()

    -- player variables
    self.bombs = {}
    self.nbBombMax = 1
    self.power = 1
    self.maxSpeed = 2
    self.canKick = false
    self.isDead = false

    self.lastDirection = 'Down'
    self.velocity = playdate.geometry.vector2D.new(0, 0)
    self.shiftY = 0
    self.shiftX = 0

    self.shiftTolerance = 8

    -- configure collision

    self:setCollideRect(10, 18, 12, 12)
    local playerCollisionGroup = playerNumber == P1 and collisionGroup.player1 or collisionGroup.player2
    self:setGroups({ playerCollisionGroup })

    self:setCollidesWithGroups({
        collisionGroup.block,
        collisionGroup.bomb,
        collisionGroup.item,
        collisionGroup.p1,
        collisionGroup.p2,
        collisionGroup.explosion
    })

    -- place character
    local x, y = Noble.currentScene():getPositionAtCoordinates(i, j)

    self:moveTo(x, y - 8)

    self:playAnimation()
    self:setZIndex(10)

    -- add animation States

    local playerShiftSpriteSheet = player == P1 and 0 or 5
    local animationSpeed = 10

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
        --playdate.timer.performAfterDelay(500, function()
        --    world:endGame(self ~= player1)
        --end)
    end
end

function Player:Move(playerDirection)
    local velocity = playerDirection
    velocity:normalize()
    self.velocity = velocity
end

function Player:collisionResponse(other)
    self.shiftY = 0
    self.shiftX = 0

    if (hasGroup(other:getGroupMask(), collisionGroup.block)) then
        local scene = Noble.currentScene()

        local i,j = scene:getcoordinates(self.x,self.y)

        print (i .. ", " .. j)

        if  ( i == 2 and self.lastDirection == "Left" ) or
            ( i == scene.gameTileWidth - 1 and  self.lastDirection == "Right" ) or
            ( j == 2 and self.lastDirection == "Up") or
            ( j == scene.gameTileHeight - 1 and  self.lastDirection == "Down" )
            then
            return 'slide'
        end

        if self.velocity.x > 0 or self.velocity.x < 0 then
            if self.y + 8 > other.y then
                self.shiftY = other.y - self.y - 8 + 14
            else
                self.shiftY = other.y - self.y - 8 - 14
            end
        end

        if self.velocity.y > 0 or self.velocity.y < 0 then
            if self.x > other.x then
                self.shiftX = other.x - self.x + 14
            else
                self.shiftX = other.x - self.x - 14
            end
        end
    end
    

    return 'slide'
end

function Player:update()
    Player.super.update(self)


    -- dead update
    if self.isDead then
        self:changeState('dead', true)
        return
    end


    -- compute velocity

    local oldX, oldY, _, _ = self:getPosition()
    local x, y, collisions, _ = self:moveWithCollisions(self.x + self.velocity.x * self.maxSpeed,
        self.y + self.velocity.y * self.maxSpeed)
    self.velocity = playdate.geometry.vector2D.new(x - oldX, y - oldY)


    -- change state with velocity

    if self.velocity.y < 0 then
        self:changeState('RunUp', true)
        self.lastDirection = "Up"
    elseif self.velocity.x > 0 then
        self:changeState('RunRight', true)
        self.lastDirection = "Right"
    elseif self.velocity.y > 0 then
        self:changeState('RunDown', true)
        self.lastDirection = "Down"
    elseif self.velocity.x < 0 then
        self:changeState('RunLeft', true)
        self.lastDirection = "Left"
    else
        self:changeState('Idle' .. self.lastDirection, true)
    end


    if self.shiftY < self.shiftTolerance and self.shiftY > -self.shiftTolerance then
        self.y = self.y + self.shiftY
    end
    if self.shiftX < self.shiftTolerance and self.shiftX > -self.shiftTolerance then
        self.x = self.x + self.shiftX
    end

    -- reset velocity

    self.velocity.x = 0
    self.velocity.y = 0

    -- reset shift

    self.shiftY = 0
    self.shiftX = 0
end
