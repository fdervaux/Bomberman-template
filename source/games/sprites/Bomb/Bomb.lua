class('Bomb').extends(TileObject)

function Bomb:init(i, j, power)
    Bomb.super.init(self, i, j, 3, true)

    -- l'animation est composé de deux phases,
    -- une première lente, et la seconde rapide.
    local animationSpeed = 10

    print(self:isa(TileObject))

    self:addState('BombStart', 1, 3, {
        tickStep = animationSpeed,
        yoyo = true,
        loop = 4,
        nextAnimation = 'BombEnd',
        frames = { 29, 30, 31 }
    }).asDefault()
    self:addState('BombEnd', 1, 10, {
        tickStep = animationSpeed / 2,
        yoyo = true,
        loop = false,
        frames = { 30, 31, 30, 29, 30, 31, 30, 29, 30, 31 }
    })

    self:playAnimation()

    self.states.BombEnd.onAnimationEndEvent = function(self)
        self:explode()
    end

    local gameScene = Noble.currentScene()

    self:setCollidesWithGroups({ collisionGroup.p1, collisionGroup.p2, collisionGroup.bomb, collisionGroup.item,
        collisionGroup.block })

    local bombCollisionGroups = { collisionGroup.bomb }

    local sprites = self:overlappingSprites()

    for i = 1, #sprites, 1 do
        if (sprites[i] == gameScene.player1) then
            bombCollisionGroups[#bombCollisionGroups + 1] = collisionGroup.ignoreP1
        end

        if (sprites[i] == gameScene.player2) then
            bombCollisionGroups[#bombCollisionGroups + 1] = collisionGroup.ignoreP2
        end
    end



    self:setGroups(bombCollisionGroups)
end

function Bomb:explode()
    self:remove()
    self.isExploded = true
end

function Bomb:update()
    Bomb.super.update(self)

    local gameScene = Noble.currentScene()

    local sprites = self:overlappingSprites()

    local collideWithPlayer1, collideWithPlayer2 = false, false

    for i = 1, #sprites, 1 do
        if (sprites[i] == gameScene.player1) then
            collideWithPlayer1 = true
        end
        if (sprites[i] == gameScene.player2) then
            collideWithPlayer2 = true
        end
    end

    if maskContainsGroup(self:getGroupMask(), collisionGroup.ignoreP1) and collideWithPlayer1 == false then
        self:setGroupMask(self:getGroupMask() - bit(collisionGroup.ignoreP1))
    end

    if maskContainsGroup(self:getGroupMask(), collisionGroup.ignoreP2) and collideWithPlayer2 == false then
        self:setGroupMask(self:getGroupMask() - bit(collisionGroup.ignoreP2))
    end
end
