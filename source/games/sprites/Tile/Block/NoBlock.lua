class('NoBlock').extends(TileObject)

function NoBlock:init(i, j)
    Block.super.init(self, i, j, 3, false)
end