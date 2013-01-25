
# Global game object constructor
window.Game = class Game
	
	# --------------------
	# 	Main tiles group
	# --------------------
	tiles: new Kinetic.Group()

	# ---------------------
	# 	Main canvas layer
	# ---------------------
	layer: new Kinetic.Layer()

	# ----------------------------------------------------------------
	# 	Constructor: Loads new game from level data and level assets
	# ----------------------------------------------------------------
	constructor: (levelData, images, @debug = off) ->

		# Debug conditional
		console.log levelData if debug

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

		@character =
			start: @parseCoord levelData.start
			finish: @parseCoord levelData.finish

		# Set current position to start
		@character.position = @character.start

		console.log @character

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

		# Loop tiles
		for row in [0...@map.length]
			for tile in [0...@map.length]

				# Check tile is not blank
				if @map.grid[row][tile] isnt 0

					# Get image based on tile value
					img = @images[@map.grid[row][tile]] || @images.default
					
					# Get image dimensions
					imgW = img.width
					imgH = img.height

					# Set img coordinates
					coord =
						x: @dims.x+(@dims.w*tile)-(imgW/2)
						y: (@dims.y+(@dims.h*tile)+@dims.h)-(imgH-@dims.h)

					# Check if image is a sprite
					if imgW > @dims.size then @createSpriteTile img, coord
					# Else add as image
					else @createImageTile img, coord

				# Check if debugging is on to plot tiles
				@createDebugDot tile if debug

			# Move to next row
			@dims.x -= @dims.w
			@dims.y += @dims.h

		# Add objects to canvas
		@layer.add @terrain
		@layer.add @tiles
		@layer.add @grid
		@stage.add @layer

		# Start all sprite animations
		for sprite in @tiles.getChildren()
			do sprite.start if sprite.shapeType is 'Sprite'

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

		for frame in [0...frames]
			animations.idle.push x:(@dims.size*frame), y:0, width:@dims.size, height:img.height

		# Add to tile group
		@tiles.add new Kinetic.Sprite
			x: coord.x
			y: coord.y
			fill: 'orange'
			image: img
			animation: 'idle',
			animations: animations
			frameRate: frames

	# -------------------------------------------------------------
	# 	Creates dot in center of each tile to help with debugging
	# -------------------------------------------------------------
	createDebugDot: (tile) ->
		@tiles.add new Kinetic.Circle
			radius: 1
			x: @dims.x+(@dims.w*tile)
			y: @dims.y+(@dims.h*tile)+@dims.h
			fill: 'yellow'

	# ------------------------------------------------------
	# 	Creates a new image object and adds to tiles group
	# ------------------------------------------------------
	createImageTile: (img, coord) ->

		# Add to tile group
		@tiles.add new Kinetic.Image
			image: img
			x: coord.x
			y: coord.y

	# --------------------------------
	# 	Parse coord string to xy obj
	# --------------------------------
	parseCoord: (coord) ->
		coord = coord.split ':'
		xy = # Return xy object
			x: parseInt coord[0], 10
			y: parseInt coord[1], 10

	# -----------------------------------
	# 	Toggle grid overlay visibillity
	# -----------------------------------
	toggleGrid: ->
		if @grid.getVisible() then do @grid.hide else do @grid.show
		do @layer.draw


