class("Floor").extends(TileObject)

function Floor:setShadow(hasShadow)
    local imageIndex = hasShadow and 48 or 49
    self:setImageWithIndex(imageIndex)
end

function Floor:init(i, j)
    Floor.super.init(self, i, j, 1, false)
    self:setImageWithIndex(48)
end