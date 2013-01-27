
# Get game class
Game = require '../Game'
assets = require '../assets'

# Object cloning library
clone = require 'clone'

# Client game instances stored with session keys
game = []

# RPC interface
exports.actions = (req, res, ss) ->

	test: (attr) ->
		game[req.sessionId].added = attr

	# Load a new level
	load: (level, player) ->

		# Make sure level number is nothing other than a round number
		# Do not want user specified include paths in require statement that follows
		unless level = Math.round(Math.abs level)
			res false
			return 

		# Load level from config or fail gracefully if not found
		# NB: Important to clone level object here or read json file.
		# Simply pointing to it will apply changes to all game instances.
		try levelData = clone(require "../levels/#{level}/")
		catch e
			res false
			return 
		
		# Create new game instance
		game[req.sessionId] = new Game(levelData)

		# Check if level was included ok and respond with map and tilesize
		res(if game[req.sessionId] then game[req.sessionId].level else false)

	# Get tile size
	getSize: -> res(game[req.sessionId].level.tile)

	# Get map
	getMap: -> res(game[req.sessionId].level.map)

	# Get image files as dataURIs
	getAssets: (level) -> assets level, res

	# Get current direction
	getDirection: -> res(game[req.sessionId].level.direction)

	# Get current level number
	getLevel: -> res(game[req.sessionId].level.num)

	# Get current position
	getPosition: ->
		c = game[req.sessionId].level.position
		res(game[req.sessionId].formatCoord c)

	# Get finish tile
	getFinish: ->
		c = game[req.sessionId].level.finish
		res(game[req.sessionId].formatCoord c)

	# Move x spaces
	move: (spaces) -> res(game[req.sessionId].move spaces)

	# Turn to N,S,E,W
	turn: (direction) -> res(game[req.sessionId].turn direction)





