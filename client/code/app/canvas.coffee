
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

		# Removing loading gif
		$('#canvas').css 'background-image', 'none'
		
		# Create layer
		@layer = new Kinetic.Layer()

		# No real reason to have main map polygon
		# @terrain = new Kinetic.Polygon
		# 	x: cSize.width/2
		# 	y: cSize.height/2
		# 	points: [-mapSize/2, 0, 0, mapSize/4, mapSize/2, 0, 0, -mapSize/4]
		# 	fill: 'blue'

		# @layer.add @terrain

		# Set general polygon dimaensions
		nH = tileSize/4
		nW = tileSize/2

		nStart =
			x: cSize.width/2
			y: (cSize.height/2)-(nH*4)

		# Group of tiles
		@tiles = new Kinetic.Group()

		# Lay tiles
		for row in [0...(map.length)]
			for tile in [0...(map.length)]
				node = new Kinetic.Polygon
					name: "Tile:#{row}:#{tile}"
					x: nStart.x+(nW*tile)
					y: nStart.y+(nH*tile)
					points: [ 0, 0, -nW, nH, 0, nW, nW, nH ]
					fill: 'yellow'

				# Add to group
				@tiles.add node

			# Move to next row
			nStart.x -= nW
			nStart.y += nH

		# Add to layer
		@layer.add @tiles

		# Add main layer to stage
		@stage.add @layer



