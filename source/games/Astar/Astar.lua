class("AstarNode").extends()

function AstarNode:init(i, j)
    self.i = i
    self.j = j
    self.G = 0
    self.H = 0
    self.F = 0
    self.parent = nil
end

function AstarNode:update(G, H, parent)
    self.G = G
    self.H = H
    self.F = G + H
    self.parent = parent
end

function AstarNode:asSameCoordinate(node)
    return node.i == self.i and node.j == self.j
end

class("AstarTileMapHandler").extends()

function AstarTileMapHandler:init(tiles)
    self.tiles = tiles
end

function AstarTileMapHandler:getNode(i, j)
    if i > #self.tiles[1] or j > #self.tiles then
        return nil
    end

    if i < 1 or j < 1 then
        return nil
    end

    if self.tiles[i][j] == 1 then
        return nil
    end

    return AstarNode(i, j)
end

function AstarTileMapHandler:getAdjacentNodes(currentNode)
    local nodes = {}

    local adjacentNode = nil

    adjacentNode = self:getNode(currentNode.i + 1, currentNode.j)
    if adjacentNode ~= nil then
        table.insert(nodes, adjacentNode)
    end

    adjacentNode = self:getNode(currentNode.i - 1, currentNode.j)
    if adjacentNode ~= nil then
        table.insert(nodes, adjacentNode)
    end

    adjacentNode = self:getNode(currentNode.i, currentNode.j + 1)
    if adjacentNode ~= nil then
        table.insert(nodes, adjacentNode)
    end

    adjacentNode = self:getNode(currentNode.i, currentNode.j - 1)
    if adjacentNode ~= nil then
        table.insert(nodes, adjacentNode)
    end

    return nodes
end

function AstarTileMapHandler:GetDistanceBetweenNode(A, B, heuristicFunction)
    return heuristicFunction(A.i, A.j, B.i, B.j)
end

function manhattanDistance(ax, ay, bx, by)
    local dx = math.abs(ax - bx)
    local dy = math.abs(ay - by)
    return dx + dy
end

function sqrDistance(ax, ay, bx, by)
    local dx = math.abs(ax - bx)
    local dy = math.abs(ay - by)
    return dx * dx + dy * dy
end

function distance(ax, ay, bx, by)
    return math.sqrt(sqrDistance(ax, ay, bx, by))
end

class("AstarPath").extends()

function AstarPath:init(success, nodes)
    self.nodes = nodes
    self.success = success
end

class("AstarPathFinder").extends()


function AstarPathFinder:init(mapHandler)
    self.mapHandler = mapHandler
end

function AstarPathFinder:getBestOpenNode()
    local bestNode = self.openNodes[1]

    for i = 2, #self.openNodes, 1 do
        local node = self.openNodes[i]

        if node.F < bestNode.F then
            bestNode = node
        end
    end

    return bestNode
end

function containsNode(list, node)
    for _, nodeInList in pairs(list) do
        if nodeInList:asSameCoordinate(node) then
            return true
        end
    end
    return false
end



function AstarPathFinder:findPath(startNode, endNode, heuristicFunction)
    self.openNodes = {}
    self.closedNodes = {}

    startNode.H = heuristicFunction(startNode.i, startNode.j, endNode.i, endNode.j)
    table.insert(self.openNodes, startNode)


    local success = false

    while not success and #self.openNodes ~= 0 do
        local bestOpenNode = self:getBestOpenNode()

        table.remove(self.openNodes, table.indexOfElement(self.openNodes, bestOpenNode))
        print("remove", bestOpenNode.i, bestOpenNode.j)
        table.insert(self.closedNodes, bestOpenNode)

        if bestOpenNode:asSameCoordinate(endNode) then
            success = true
            break
        end

        local adjacentNodes = self.mapHandler:getAdjacentNodes(bestOpenNode)

        for i = 1, #adjacentNodes, 1 do
            local node = adjacentNodes[i]

            if containsNode(self.closedNodes, node) then
                goto continue
            end

            node:update(
                bestOpenNode.G + self.mapHandler:GetDistanceBetweenNode(node, bestOpenNode, heuristicFunction),
                heuristicFunction(node.i, node.j, endNode.i, endNode.j),
                bestOpenNode
            )

            local indexOfNode = table.indexOfElement(self.openNodes)

            if indexOfNode == nil then
                table.insert(self.openNodes, node)
                print("add", node.i, node.j)
            elseif self.openNodes[indexOfNode].F > node.F then
                self.openNodes[indexOfNode] = node
            end

            ::continue::
        end
    end

    local path = AstarPath(success, {})
    local pathNode = self.closedNodes[#self.closedNodes]

    if not success then
        for i = 1, #self.closedNodes - 1, 1 do
            if self.closedNodes[i].H < pathNode.H then
                pathNode = self.closedNodes[i]
            end
        end
    end

    repeat
        print(pathNode.i, pathNode.j)
        table.insert(path.nodes, pathNode)
        pathNode = pathNode.parent
    until pathNode == nil

    return path
end

AstarTestScene = {}
class("AstarTestScene").extends(NobleScene)


function AstarTestScene:init()
    AstarTestScene.super.init(self)

    self.tileSize = 16       -- la size d'une tile en pixels
    self.gameTileShiftX = 6  -- le décallage horizontale en nombre de tile
    self.gameTileShiftY = 1  -- le décallage verticale en nombre de tile
    self.gameTileWidth = 13  -- la largeur en nombre de tile
    self.gameTileHeight = 13 -- la hauteur en nombre de tile
end

function AstarTestScene:enter()
    AstarTestScene.super.enter(self)

    playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)

    self.gameTileTable = {}
    for i = 1, self.gameTileWidth, 1 do
        self.gameTileTable[i] = {}
        for j = 1, self.gameTileHeight, 1 do
            self.gameTileTable[i][j] = {}
        end
    end

    -- add block on top and down
    for i = 1, self.gameTileWidth, 1 do
        self:addElement(UnbreakableBlock, i, 1)
        self:addElement(UnbreakableBlock, i, self.gameTileHeight)
    end

    -- add block on right and left
    for j = 2, self.gameTileHeight - 1, 1 do
        self:addElement(UnbreakableBlock, 1, j)
        self:addElement(UnbreakableBlock, self.gameTileWidth, j)
    end

    -- add block on middle
    for i = 3, self.gameTileWidth - 2, 2 do
        for j = 3, self.gameTileHeight - 2, 2 do
            self:addElement(UnbreakableBlock, i, j)
        end
    end


    -- add sprite to startPose and end pose
    self:addElement(NoBlock, 2, 7)
    self:addElement(NoBlock, 12, 7)

    Player(2, 7, P1)
    Player(12, 7, P2)


    --add BreakableBlock randomly
    local emptySpace = {}
    local emptySpaceIndex = 1

    for i = 2, self.gameTileWidth - 1, 1 do
        for j = 2, self.gameTileHeight - 1, 1 do
            if #self.gameTileTable[i][j] <= 0 then
                emptySpace[emptySpaceIndex] = { i, j }
                emptySpaceIndex = emptySpaceIndex + 1
            end
        end
    end

    local nbBloc = math.floor(#emptySpace * 0.3)

    while nbBloc ~= 0 do
        local elementsIndex = math.random(#emptySpace)
        local coord = table.remove(emptySpace, elementsIndex)
        local i, j = coord[1], coord[2]
        self:addElement(BreakableBlock, i, j)
        nbBloc = nbBloc - 1
    end


    -- add Floor
    for i = 2, self.gameTileWidth - 1, 1 do
        for j = 2, self.gameTileHeight - 1, 1 do
            self:addElement(Floor, i, j)
            self:updateFloor(i, j)
        end
    end

    self.tiles = {}

    for i = 1, self.gameTileWidth, 1 do
        self.tiles[i] = {}
        for j = 1, self.gameTileHeight, 1 do
            self.tiles[i][j] = containsClass(self.gameTileTable[i][j], Block) and 1 or 0
        end
    end

    self.astarTileMapHandler = AstarTileMapHandler(self.tiles)
    self.pathFinder = AstarPathFinder(self.astarTileMapHandler)

    local path = self.pathFinder:findPath(AstarNode(2, 7), AstarNode(12, 7), manhattanDistance)

    for i = 2, #path.nodes - 1, 1 do
        local node = path.nodes[i]
        self:addElement(Bomb, node.i, node.j)
    end

    if not path.success then
        local node = path.nodes[1]
        self:addElement(Bomb, node.i, node.j)
    end
end

function AstarTestScene:start()
    AstarTestScene.super.start(self)
end

function AstarTestScene:drawBackground()
    AstarTestScene.super.drawBackground(self)
end

function AstarTestScene:update()
    AstarTestScene.super.update(self)
end

function AstarTestScene:exit()
    AstarTestScene.super.exit(self)
end

function AstarTestScene:finish()
    AstarTestScene.super.finish(self)
end

function AstarTestScene:getPositionAtCoordinates(i, j)
    return ((i - 1) + 0.5 + self.gameTileShiftX) * self.tileSize,
        ((j - 1) + 0.5 + self.gameTileShiftY) * self.tileSize
end

-- le 0.5 disparait car pour faire l'arrondi on ajoute 0.5,
-- puis on utilise la fonction floor
function AstarTestScene:getcoordinates(x, y)
    return math.floor((x / self.tileSize) - self.gameTileShiftX + 1),
        math.floor((y / self.tileSize) - self.gameTileShiftY + 1)
end

function AstarTestScene:addElement(Type, i, j, ...)
    local tileSprites = self.gameTileTable[i][j]
    tileSprites[#tileSprites + 1] = Type(i, j, ...)
end

function AstarTestScene:updateFloor(i, j)
    local floor = self:getElementOfTypeAt(Floor, i, j)

    local caseTable = self.gameTileTable[i][j - 1]
    local shadow = containsClass(caseTable, Block)

    if floor then
        floor:setShadow(shadow)
    end
end

function AstarTestScene:getElementOfTypeAt(type, i, j)
    return getObjectOfClass(self.gameTileTable[i][j], type)
end
