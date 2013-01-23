
# TODO:
# Move all dom logic to arguments from app.coffee


# Global game object
window.Game = class Game
	
	# Loads new game from level data and level assets
	constructor: (levelData, images) ->

		# Assign data to some easier vars
		map = levelData.map
		tileSize = levelData.tile

		# Calculate size of map based on 90px tiles
		mapSize = tileSize * map.length

		# Get canvas size object
		canvas = levelData.canvas

		# Create canvas
		@stage = new Kinetic.Stage
			container: canvas.el
			width: canvas.width
			height: canvas.height
			# Draggable only if canvas is bigger than container
			draggable: (canvas.width < mapSize)
		
		# Create layer
		@layer = new Kinetic.Layer()

		# Set general polygon dimaensions
		dim = {}
		dim.h = tileSize/4
		dim.w = tileSize/2
		dim.x = canvas.width/2
		dim.y = (canvas.height/2)-mapSize/4

		# Create terrain
		@grid = new Kinetic.Polygon
			visible: no
			fillPatternImage: images.grid
			fillPatternRepeat: 'repeat'
			fillPatternOffset: [0,dim.h]
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
			fillPatternOffset: [-10,dim.h]
			x: canvas.width/2
			y: (canvas.height/2)-mapSize/4
			points: [
				[-mapSize/2, mapSize/4]
				[0, mapSize/2]
				[mapSize/2, mapSize/4]
				[0, 0]
			]

		# Group of tiles
		@tiles = new Kinetic.Group()

		# Loop tiles
		for row in [0...(map.length)]
			for tile in [0...(map.length)]

				# Check tile is not blank
				if map[row][tile] isnt 0

					# Get image based on tile value
					img = images[map[row][tile]] || images.default
					
					# Get image dimensions
					imgW = img.width
					imgH = img.height

					# Get image to use for tile
					obj = new Kinetic.Image
						image: img
						name: "Tile:#{row}:#{tile}"
						x: dim.x+(dim.w*tile)-(imgW/2)
						y: (dim.y+(dim.h*tile)+dim.h)-(imgH-tileSize/4)

					# Add to group
					@tiles.add obj

					# ==============================================
					# 	Debug image placement with tile center dot
					# ==============================================
					# node = new Kinetic.Circle
					# 	radius: 2
					# 	name: "Tile:#{row}:#{tile}"
					# 	x: dim.x+(dim.w*tile)
					# 	y: dim.y+(dim.h*tile)+dim.h
					# 	fill: 'green'
					# @tiles.add node
					# ==============================================					

			# Move to next row
			dim.x -= dim.w
			dim.y += dim.h

		# Add objects to canvas
		@layer.add @terrain
		@layer.add @tiles
		@layer.add @grid
		@stage.add @layer

	# Toggle grid overlay visibillity
	toggleGrid: =>
		if @grid.getVisible() then do @grid.hide else do @grid.show
		do @layer.draw


