class('Block').extends(TileObject)

function Block:init(i, j)
    Block.super.init(self, i, j, 3, true)
    self:setGroups({ collisionGroup.block })
end