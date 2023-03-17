class('UnbreakableBlock').extends(Block)

function UnbreakableBlock.new(i, j)
    return UnbreakableBlock(i, j)
end

function UnbreakableBlock:init(i, j)
    UnbreakableBlock.super.init(self, i, j)
    local imageIndex = 43
    self:setImageWithIndex(imageIndex)
end