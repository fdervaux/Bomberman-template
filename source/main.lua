import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "libraries/noble/Noble"
import "libraries/animatedSprite/AnimatedSprite.lua"
import "games/sprites/Player/Player.lua"
import "games/sprites/Tile/TileObject.lua"
import "games/sprites/Tile/Block/NoBlock.lua"
import "games/sprites/Tile/Block/Block.lua"
import "games/sprites/Tile/Block/BreakableBlock.lua"
import "games/sprites/Tile/Block/UnbreakableBlock.lua"
import "games/sprites/Tile/Floor.lua"
import "games/scenes/simpleScene.lua"
import "games/scenes/GameScene.lua"

import "games/Utils.lua"

Noble.new(SimpleScene)