# Get game class
Game = require '../Game'
assets = require '../Assets'

# Object cloning library
clone = require 'clone'

# Client game instances stored with session keys
game = []

# TODO:
# - Notify user when his game instance has been removed using:
# ss.publish.user(req.session.userId, 'expire')

# RPC interface
exports.actions = (req, res, ss) ->

	# Enable sessions to store userId
	req.use('session')

	# Load a new level
	load: (level, player) ->

		# Store userId field in session as sessionId to easily message guests directly
		req.session.userId = req.sessionId

		# Save session
		req.session.save (err) ->

			# Make sure level number is nothing other than a round number
			# Do not want user specified include paths in require statement that follows
			unless level = Math.round(Math.abs level) or err
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

	# Get image files as dataURIs
	getAssets: (level) -> assets level, res

	# Move x spaces
	move: (spaces) -> res(game[req.sessionId].move spaces)

	# Turn to N,S,E,W
	turn: (direction) -> res(game[req.sessionId].turn direction)





