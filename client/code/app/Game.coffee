
# TODO:
# - Move grid creation into class
# - Create warning tile for missing images

# Global game object constructor
window.Game = class Game
		
	# ----------------------------------------------------------------
	# 	Constructor: Loads new game from level data and level assets
	# ----------------------------------------------------------------
	constructor: (levelData, images, debug = off) ->

		# Debug on/of
		@debug = debug

		# Create debug group if set
		@debugGroup = new Kinetic.Group() if @debug

		# Debug conditional
		console.log levelData if @debug

		# Main canvas layer
		@layer = new Kinetic.Layer()

		# Main tiles group. Hidden until z-indexes sorted
		@tiles = new Kinetic.Group()

		# Assign images obj
		@images = images

		# Map object
		@map =
			grid: levelData.map
			length: levelData.grid
			canvas: levelData.canvas
			size: levelData.tile * levelData.map.length

		# Calculate tile dimensions
		@dims =
			size: levelData.tile
			h: levelData.tile/4
			w: levelData.tile/2
			x: @map.canvas.width/2
			y: (@map.canvas.height/2)-@map.size/4

		# Get player data
		@player =
			start: @parseCoord levelData.start
			finish: @parseCoord levelData.finish

		# Set current position to start
		@player.position = @player.start

		# Create player object
		do @createPlayer

		# Set finish position
		@map.grid[@player.finish.x][@player.finish.y] = 'finish'

		# Create canvas
		@stage = new Kinetic.Stage
			container: @map.canvas.el
			width: @map.canvas.width
			height: @map.canvas.height
			# Draggable only if canvas is bigger than container
			draggable: @map.canvas.width < @map.size

		# Points for creating a map sized polygon
		mapPolyPoints = [
			[-@map.size/2, @map.size/4]
			[0, @map.size/2]
			[@map.size/2, @map.size/4]
			[0, 0]
		]

		# Create terrain
		@grid = new Kinetic.Polygon
			visible: no
			fillPatternImage: @images.grid
			fillPatternRepeat: 'repeat'
			fillPatternOffset: [0, @dims.h]
			points: mapPolyPoints
			x: @dims.x
			y: @dims.y

		# Create terrain
		@terrain = new Kinetic.Polygon
			fillPatternImage: @images.tile
			fillPatternRepeat: 'repeat'
			fillPatternOffset: [-10, @dims.h]
			points: mapPolyPoints
			x: @dims.x
			y: @dims.y

		# Tile the map
		do @tile

		# Add objects to canvas
		@layer.add @terrain
		@layer.add @tiles
		@layer.add @debugGroup
		@layer.add @grid
		@stage.add @layer

		# Start all sprite animations and sort tile zindexes
		for tile in @tiles.getChildren()
			do tile.start if tile.shapeType is 'Sprite' and tile.getName() isnt 'player'

	# ---------------------------------------------
	# 	Create player image as directional sprite
	# ---------------------------------------------
	createPlayer: ->

		# Warn if no image, SHOULD BE REPLACED WITH ERRTILE
		unless img = @images.player
			console.error 'No player image found'
			return
		
		# Animation obj
		animations = north:[], east:[], south:[], west:[]

		# Get image height based on 4 directions
		height = img.height / 4

		# Get Number of frames
		frames = img.width/@dims.size

		# Create animation frame bounds
		for frame in [0...frames]
			animations.north.push x:(@dims.size*frame), y:height * 0, width:@dims.size, height:height
			animations.east.push x:(@dims.size*frame), y:height * 1, width:@dims.size, height:height
			animations.south.push x:(@dims.size*frame), y:height * 2, width:@dims.size, height:height
			animations.west.push x:(@dims.size*frame), y:height * 3, width:@dims.size, height:height

		# Get start tile center coords
		coord = @getTileCenter @player.start.x, @player.start.y

		# Add to tile group
		@tiles.add new Kinetic.Sprite
			name: 'player'
			id: coord.y
			x: coord.x - @dims.w
			y: coord.y - (height - @dims.h)
			fill: '#48FF26'
			image: img
			animation: 'west'
			animations: animations
			frameRate: frames

	# -----------------------------------------------
	# 	Loops over map and creates individual tiles
	# -----------------------------------------------
	tile: ->

		# Loop tiles in diamond structure
		for tile in @arrayToDiamond(@map.length)

			x = tile.x
			y = tile.y
			
			# Get img coordinates
			coord = @getTileCenter x, y

			# Check tile is not blank
			if @map.grid[x][y] isnt 0

				# Get image based on tile value
				img = @images[@map.grid[x][y]] || @images.default
				
				# Check if image is a sprite
				if img.width > @dims.size then @createSpriteTile img, coord

				# Else add as image
				else @createImageTile img, coord

			# Check if debugging is on to plot tiles
			@createDebugDot coord if @debug

	# -----------------------------------------------------------------------------
	# 	Return array of indexes in diamond/isometric shape
	# 	Ensures tiles are iterated top to bottom for correct zIndexing
	# 	See: https://gist.github.com/293566e1eaeb278e1170#file-zigzagarray-coffee
	# -----------------------------------------------------------------------------	
	arrayToDiamond: (size) ->

		# Return array
		diamond = []

		# Top half of array
		for i in [0...size]
			for j in [0...(i + 1)]
				diamond.push {x:j,y:i-j}

		# Bottom half of array
		for i in [1...(size + 1)]
			for j in [0...(size - i)]
				diamond.push {x:i+j, y:size-j-1}

		# Return diamond array with indexes
		diamond

	# ---------------------------------------------------------------------------
	# 	Creates a new sprite object based on image size and adds to tiles group
	# ---------------------------------------------------------------------------
	createSpriteTile: (img, coord) ->
		
		# Log error if image does not fit tiles as sprite
		console.error "Image interpreted as sprite with incorrect width: #{img.width}px. Should be divisible by: #{@dims.size}px" if img.width % @dims.size

		# Animation obj
		animations = idle:[]

		# Get Number of frames
		frames = img.width/@dims.size

		# Create animation frame bounds
		for frame in [0...frames]
			animations.idle.push x:(@dims.size*frame), y:0, width:@dims.size, height:img.height

		# Add to tile group
		@tiles.add new Kinetic.Sprite
			id: coord.y
			x: coord.x - @dims.w
			y: coord.y - (img.height - @dims.h)
			fill: 'orange'
			image: img
			animation: 'idle',
			animations: animations
			frameRate: frames

	# -------------------------------------------------------------
	# 	Creates dot in center of each tile to help with debugging
	# -------------------------------------------------------------
	createDebugDot: (coord) ->

		# Add circle to center of tile in debugGroup
		@debugGroup.add new Kinetic.Circle
			radius: 2
			x: coord.x
			y: coord.y
			fill: 'yellow'
	
	# ---------------------------------------
	# 	Get tile center xy from "x:y" index
	# ---------------------------------------
	getTileCenter: (x, y) ->

		# Get top xy
		center =
			x: @dims.x + ((x-y) * @dims.w)
			y: @dims.y + ((y+x) * @dims.h)

		# Offset to center
		center.y += @dims.h

		# Return
		center 

	# ------------------------------------------------------
	# 	Creates a new image object and adds to tiles group
	# ------------------------------------------------------
	createImageTile: (img, coord) ->

		# Add to tile group
		@tiles.add new Kinetic.Image
			image: img
			id: coord.y
			x: coord.x - (img.width / 2)
			y: coord.y - (img.height + @dims.h)

	# --------------------------------
	# 	Parse coord string to xy obj
	# --------------------------------
	parseCoord: (coord) ->

		# Split string
		coord = coord.split ':'

		xy = # Return xy object
			x: parseInt coord[0], 10
			y: parseInt coord[1], 10

	# -----------------------------------
	# 	Toggle grid overlay visibillity
	# -----------------------------------
	toggleGrid: =>

		# Reverse visibillity
		if @grid.getVisible() then do @grid.hide else do @grid.show

		# Redraw
		do @layer.draw

	# -----------------------------------
	# 	Update player position
	# -----------------------------------
	updatePosition: (position) ->
				
		# Update new position object
		@player.position =
			x: position.x
			y: position.y

		# Get player image
		img = @images.player

		coord =
			x: (@dims.x*-position.x)+(@dims.w*position.y)-(img.width/2)
			y: ((@dims.y*position.y)+(@dims.h*position.y)+@dims.h)-(img.height-@dims.h)

		@createImageTile img, coord, 'player'

		# anim = new Kinetic.Animation( (frame) ->
		# 	pl.setX 20
		# , @layer)

		# anim.start()

		# # Redraw
		# do @layer.draw






