class('BreakableBlock').extends(Block)

function BreakableBlock.new(i,j)
    return BreakableBlock(i, j)
end

function BreakableBlock:init(i, j)
    BreakableBlock.super.init(self, i, j)

    local speedAnimation = 10
    self:addState('block', 44, 44, { tickStep = speedAnimation }).asDefault()
    self:addState('destruction', 1, 3, { tickStep = speedAnimation, loop = false, frames = { 45, 46, 47 } })

    self.states.destruction.onAnimationEndEvent = function(self)
       self:remove()
    end

    self:playAnimation()
end

function BreakableBlock:breakBloc()
   self:changeState('destruction', true)
end
