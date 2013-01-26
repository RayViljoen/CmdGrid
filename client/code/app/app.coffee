
# Client Code

# Load app - provides global Game class
require '/Game'

# Toggle debugging
debug = on

# Get level from pathname which should be /level*/
level = location.pathname.match(/^\/level([1-9][0-9]*)/i)?[1]

# Creates grid pattern image at specified size
# Callback contains grid image
createGrid = (size, callback) ->

	grid = new Kinetic.Line
		strokeWidth: 1
		stroke: 'blue'
		points: [[size/2, 0],[0, size/4],[size/2, size/2],[size, size/4],[size/2, 0]]

	grid.toImage
		height: size/2
		width: size
		callback: callback

# Loads level assets from server and creates img objects for use with canvas
loadAssets = (level, callback) ->

	# Load from server
	ss.rpc 'game.getAssets', level, (err, assets) ->

		# Image objects
		images = {}

		# Loop dataURIs to create img objects
		for imgName, dataURI of assets
			images[imgName] = new Image()
			images[imgName].src = dataURI

		# Do callback with img objects
		callback images

# Handles sending and receiving server responses
sendCmd = (cmd, callback) ->

	# Check move command type
	spaces = (cmd.match /^\s*move\s+([1-9]+[0-9]*)\s*$/i)?[1]
	if spaces
		ss.rpc 'game.move', spaces, (res) ->
			res._type = 'move'
			console.log res if debug
			callback res
		return

	# Check turn command type
	direction = (cmd.match /^\s*turn\s+([A-z]+)\s*$/i)?[1]
	if direction
		ss.rpc 'game.turn', direction, (res) ->
			res._type = 'turn'
			console.log res if debug
			callback res
		return

	# Lastly return false if no matched commands
	callback no

# Load on server
if level then ss.rpc 'game.load', level, (levelData) ->

	# Check if response ok and load canvas with data
	if levelData is false
		alert 'Could not load level'
		return

	# Tile size
	size = levelData.tile

	# Load assets
	loadAssets level, (images) ->

		# Create grid and push to assets
		createGrid levelData.tile, (gridImg) ->

			# Push grid image to assets
			images['grid'] = gridImg

			# New game instance
			game = null

			# Get some canvas element data
			canvasEl = $('#canvas')

			# Get canvas container size
			levelData.canvas =
				el: canvasEl[0]
				width: canvasEl.width()
				height: canvasEl.height()

			# Create canvas
			game = new Game(levelData, images, debug)

			# Remove loading gif
			$('#canvas').css 'background-image', 'none'

			# Listen for grid toggle
			$('.toggleGrid').click game.toggleGrid

			# Make game instance global to call methods directly
			window._game = game if debug

			# Show grid if debug
			do game.toggleGrid if debug

			# Register cmd submit
			$('form.terminal').submit ->

				# Get command value
				cmd = $(@).find('.cmd').val()

				# Pass to handler method
				sendCmd cmd, (res) ->
					# Check server responded
					if res

						# Check server response was not invalid
						unless res.ok
							alert res.m
							return

						# Check command type and send to cavas method
						if res._type is 'move' then game.moveTo(res.tile.x, res.tile.y)
						if res._type is 'turn' then game.turnTo(res.direction)

					# Else alert user
					else alert 'Invalid command'

				# Stop submitting
				no


