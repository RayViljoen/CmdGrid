
# TODO:
# Move all dom logic to arguments from app.coffee


# Global game object
window.Game = class Game
	
	# Loads new game from level data and level assets
	constructor: (levelData, images, @debug = off) ->

		console.log @debug

		# Create a tiles group
		@tiles = new Kinetic.Group()

		# Assign data to some easier vars
		map = levelData.map
		tileSize = levelData.tile

		# Calculate size of map based on 90px tiles
		mapSize = tileSize * map.length

		# Get canvas size object
		canvas = levelData.canvas

		# Calculate tile dimensions
		tileDim =
			h: tileSize/4
			w: tileSize/2
			x: canvas.width/2
			y: (canvas.height/2)-mapSize/4

		# Create canvas
		@stage = new Kinetic.Stage
			container: canvas.el
			width: canvas.width
			height: canvas.height
			# Draggable only if canvas is bigger than container
			draggable: (canvas.width < mapSize)
		
		# Create layer
		@layer = new Kinetic.Layer()

		# Create terrain
		@grid = new Kinetic.Polygon
			visible: no
			fillPatternImage: images.grid
			fillPatternRepeat: 'repeat'
			fillPatternOffset: [0,tileDim.h]
			x: canvas.width/2
			y: (canvas.height/2)-mapSize/4
			points: [
				[-mapSize/2, mapSize/4]
				[0, mapSize/2]
				[mapSize/2, mapSize/4]
				[0, 0]
			]

		# Create terrain
		@terrain = new Kinetic.Polygon
			fillPatternImage: images.tile
			fillPatternRepeat: 'repeat'
			fillPatternOffset: [-10,tileDim.h]
			x: canvas.width/2
			y: (canvas.height/2)-mapSize/4
			points: [
				[-mapSize/2, mapSize/4]
				[0, mapSize/2]
				[mapSize/2, mapSize/4]
				[0, 0]
			]

		# Creates a new sprite object based on image size and adds to tiles group
		@createSpriteTile = (img, coord) ->
			
			# Log error if image does not fit tiles as sprite
			console.error "Image interpreted as sprite with incorrect width: #{img.width}px. Should be divisible by: #{tileSize}px" if img.width % tileSize

			# Animation obj
			animations = idle:[]

			# Get Number of frames
			frames = img.width/tileSize

			for frame in [0...frames]
				animations.idle.push x:(tileSize*frame), y:0, width:tileSize, height:img.height

			# Add to tile group
			@tiles.add new Kinetic.Sprite
				x: coord.x
				y: coord.y
				fill: 'orange'
				image: img
				animation: 'idle',
				animations: animations
				frameRate: frames

		# Creates dot in center of each tile to help with debugging
		@createDebugDot = (tile) ->
			console.log 'DOTTING'
			@tiles.add new Kinetic.Circle
				radius: 2
				name: "Tile:#{row}:#{tile}"
				x: tileDim.x+(tileDim.w*tile)
				y: tileDim.y+(tileDim.h*tile)+tileDim.h
				fill: 'green'

		# Creates a new image object and adds to tiles group
		@createImageTile = (img, coord) ->

			# Add to tile group
			@tiles.add new Kinetic.Image
				image: img
				x: coord.x
				y: coord.y

		# Loop tiles
		for row in [0...(map.length)]
			for tile in [0...(map.length)]

				# Check if debugging is on
				@createDebugDot tile if @debug

				# Check tile is not blank
				if map[row][tile] isnt 0

					# Get image based on tile value
					img = images[map[row][tile]] || images.default
					
					# Get image dimensions
					imgW = img.width
					imgH = img.height

					# Set img coordinates
					coord =
						x: tileDim.x+(tileDim.w*tile)-(imgW/2)
						y: (tileDim.y+(tileDim.h*tile)+tileDim.h)-(imgH-tileSize/4)

					# Check if image is a sprite
					if imgW > tileSize then @createSpriteTile img, coord
					# Else add as image
					else @createImageTile img, coord				

			# Move to next row
			tileDim.x -= tileDim.w
			tileDim.y += tileDim.h

		# Add objects to canvas
		@layer.add @terrain
		@layer.add @tiles
		@layer.add @grid
		@stage.add @layer

		# Start all sprite animations
		for sprite in @tiles.getChildren()
			do sprite.start if sprite.shapeType is 'Sprite'

	# Toggle grid overlay visibillity
	toggleGrid: =>
		if @grid.getVisible() then do @grid.hide else do @grid.show
		do @layer.draw


