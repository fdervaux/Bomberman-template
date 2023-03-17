
envImagetable = playdate.graphics.imagetable.new('images/env-table-16-16.png')

class("TileObject").extends(AnimatedSprite)

function TileObject:setImageWithIndex(imageIndex)
    local image = envImagetable:getImage(imageIndex)
    self:setImage(image)
end

function TileObject:init(i, j, zIndex, hasCollider)
    TileObject.super.init(self, envImagetable)

    self:add()

    self.i, self.j = i, j

    print(Noble.currentScene().className)

    local x, y = Noble.currentScene():getPositionAtCoordinates(i, j)

    self:moveTo(x, y)
    self:setZIndex(zIndex)

    if hasCollider then
        self:setCollideRect(0, 0, 16, 16)
    end
end