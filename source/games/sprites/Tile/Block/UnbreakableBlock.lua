class('UnbreakableBlock').extends(Block)

function UnbreakableBlock:init(i, j)
    UnbreakableBlock.super.init(self, i, j)
    local imageIndex = 43
    self:setImageWithIndex(imageIndex)
end