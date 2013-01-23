
# Client Code

# Load app - provides global game instance
require '/canvas'

# Load new game

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

		# Image objects array
		images = {}

		# Loop dataURIs to create img objects
		images[imgName] = new Image(src:dataURI) for imgName, dataURI of assets	

		# Do callback with img objects
		callback images

# Load on server
ss.rpc 'game.load', level, (levelData) ->

	# Tile size
	size = levelData.tile

	# Load assets
	loadAssets level, (images) ->

		# Create grid and push to assets
		createGrid levelData.tile, (gridImg) ->

			# Push grid image to assets
			images['grid'] = gridImg

			# Check if response ok and load canvas with data
			if levelData.map instanceof Array
				game.load levelData, images
			else alert 'Could not load level'

