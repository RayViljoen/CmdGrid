
# Get game class
Game = require '../Game'

# Empty game instance
game = {}

# RPC interface
exports.actions = (req, res, ss) ->

	# Load a new level
	load: (level, player) ->
		# Make sure level is nice round number as requiring from user input can be risky
		unless Math.round(Math.abs level)
			res 'Could not load level'
			return
		# Create new game instance
		game = new Game(level)
		# Check if level was included ok and set resObj as newly created map
		resObj = if game then game.level.map else 'Could not load level'
		# Respond
		res resObj

	# Get map
	getMap: -> res(game.level.map)

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





