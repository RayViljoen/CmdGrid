
window.game =

	# Create level map
	load: (map) ->

		# Tile size
		tileSize = 90

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
		dim.y = (cSize.height/2)-(dim.h*4)

		# Group of tiles
		@tiles = new Kinetic.Group()

		# Lay tiles
		for row in [0...(map.length)]
			for tile in [0...(map.length)]
				node = new Kinetic.Polygon
					name: "Tile:#{row}:#{tile}"
					x: dim.x+(dim.w*tile)
					y: dim.y+(dim.h*tile)
					points: [ 0, 0, -dim.w, dim.h, 0, dim.w, dim.w, dim.h ]
					fill: 'yellow'

				# Add to group
				@tiles.add node

			# Move to next row
			dim.x -= dim.w
			dim.y += dim.h

		# Add to layer
		@layer.add @tiles

		# Removing loading gif
		$('#canvas').css 'background-image', 'none'

		# Add main layer to stage
		@stage.add @layer

