class('Bomb').extends(TileObject)

function Bomb:init(i,j,power)
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

    self:setGroups({collisionGroup.bomb})

    self.states.BombEnd.onAnimationEndEvent = function(self)
        self:explode()
    end
end

function Bomb:explode()
    self:remove()
    self.isExploded = true

end

function Bomb:update()
    Bomb.super.update(self)
end