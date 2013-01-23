
# Client Code

# Load app - provides global Game class
require '/Game'

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

# Load on server
if level then ss.rpc 'game.load', level, (levelData) ->

	# Check if response ok and load canvas with data
	unless levelData.map instanceof Array
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
			game = new Game(levelData, images)

			# Remove loading gif
			$('#canvas').css 'background-image', 'none'

			# Listen for grid toggle
			$('.toggleGrid').click game.toggleGrid

