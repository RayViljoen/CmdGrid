
# TODO:
# Create game class instead
# Move all dom logic to arguments from app.coffee


# Global game object
window.game =

	# Toggle grid overlay visibillity
	toggleGrid: =>
		if @grid.getVisible() then do @grid.hide else do @grid.show
		do @layer.draw

	# Create level map
	load: (levelData, images) =>

		# Assign data to some easier vars
		map = levelData.map
		tileSize = levelData.tile

		# Calculate size of map based on 90px tiles
		mapSize = tileSize * map.length

		# Get container size
		cSize =
			width: $('#canvas').width()
			height: $('#canvas').height()

		# Create canvas
		@stage = new Kinetic.Stage
			container: 'canvas'
			width: cSize.width
			height: cSize.height
			# Draggable only if canvas is bigger than container
			draggable: (cSize.width < mapSize)
		
		# Create layer
		@layer = new Kinetic.Layer()

		# Set general polygon dimaensions
		dim = {}
		dim.h = tileSize/4
		dim.w = tileSize/2
		dim.x = cSize.width/2
		dim.y = (cSize.height/2)-mapSize/4

		# Create terrain
		@grid = new Kinetic.Polygon
			visible: no
			fillPatternImage: images.grid
			fillPatternOffset: [0,dim.h]
			x: cSize.width/2
			y: (cSize.height/2)-mapSize/4
			points: [
				[-mapSize/2, mapSize/4]
				[0, mapSize/2]
				[mapSize/2, mapSize/4]
				[0, 0]
			]

		# Create terrain
		@terrain = new Kinetic.Polygon
			x: cSize.width/2
			y: (cSize.height/2)-mapSize/4
			points: [
				[-mapSize/2, mapSize/4]
				[0, mapSize/2]
				[mapSize/2, mapSize/4]
				[0, 0]
			]

		# Group of tiles
		@tiles = new Kinetic.Group()

		for row in [0...(map.length)]
			for tile in [0...(map.length)]
				node = new Kinetic.Circle
					radius: 4
					name: "Tile:#{row}:#{tile}"
					x: dim.x+(dim.w*tile)
					y: dim.y+(dim.h*tile)+dim.h
					fill: 'yellow'

				# Add to group
				@tiles.add node

			# Move to next row
			dim.x -= dim.w
			dim.y += dim.h

		# Removing loading gif
		$('#canvas').css 'background-image', 'none'

		# Add objects to canvas
		@layer.add @terrain
		@layer.add @tiles
		@layer.add @grid
		@stage.add @layer