
# Get game class
Game = require '../Game'
assets = require '../assets'

# Empty game instance
game = {}

# RPC interface
exports.actions = (req, res, ss) ->

	# Load a new level
	load: (level, player) ->
		# Create new game instance
		game = new Game(level)
		# Check if level was included ok and respond with map and tilesize
		res(if game then {map: game.level.map, tile: game.level.tile} else false)

	# Get tile size
	getSize: -> res(game.level.tile)

	# Get map
	getMap: -> res(game.level.map)

	# Get image files as dataURIs
	getAssets: (level) -> assets level, res

	# Get current direction
	getDirection: -> res(game.level.direction)

	# Get current level number
	getLevel: -> res(game.level.num)

	# Get current position
	getPosition: ->
		c = game.level.position
		res(game.formatCoord c)

	# Get finish tile
	getFinish: ->
		c = game.level.finish
		res(game.formatCoord c)

	# Move x spaces
	move: (spaces) -> res(game.move spaces)

	# Turn to N,S,E,W
	turn: (direction) -> res(game.turn direction)





