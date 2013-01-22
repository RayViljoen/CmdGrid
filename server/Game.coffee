# Game class
module.exports = class Game

	constructor: (levelNum, player = 'Guest') ->

		# Reset level incase not the first round
		@level = {}

		# Load level from config or fail gracefully if not found
		try @level = require "./levels/#{levelNum}/"
		catch e then return no

		# Store level number
		@level.num = levelNum

		# Store player name
		@level.player = player
		
		# Create size x size array
		@level.map = []

		# Set move increment
		@level.moves = 0

		row = []
		row.push 0 for i in [1..@level.size]
		@level.map.push row[..] for i in [1..@level.size]

		# Loop level and add objects to map
		@setTile coord, obj for coord, obj of @level.obstacles

		# Set current position, _start
		@level.position = @level.start

	formatCoord: (coord) ->
		c = coord.split ':'
		{x:c[0], y:c[1]}

	getTile: (coord) ->
		c = @formatCoord coord
		@level.map[c.x][c.y]

	setTile: (coord, val) ->
		c = @formatCoord coord
		@level.map[c.x][c.y] = val

	# Evaluates tile by coordinate
	tryTile: (x,y) ->
		if @level.map[x]
			return @level.map[x][y] is 0
		else no

	# Rover move fn
	move: (spaces) ->
		# Check spaces isset to abs number
		spaces = Math.round(Math.abs spaces)
		return 'Invalid distance' unless spaces

		# Add move
		@level.moves++

		# Get current position x,y
		xy = @level.position.split ':'
		x = parseInt(xy[0], 10)
		y = parseInt(xy[1], 10)

		for i in [1..spaces]
			# Check direction
			switch @level.direction.toLowerCase()
				when 'north', 'n'
					return {ok:no, moves:@level.moves, tile:{x:x,y:y}, win:no} unless @tryTile(x-=1, y) is true
				when 'south', 's'
					return {ok:no, moves:@level.moves, tile:{x:x,y:y}, win:no} unless @tryTile(x+=1, y) is true
				when 'east', 'e'
					return {ok:no, moves:@level.moves, tile:{x:x,y:y}, win:no} unless @tryTile(x, y+=1) is true
				when 'west', 'w'
					return {ok:no, moves:@level.moves, tile:{x:x,y:y}, win:no} unless @tryTile(x, y-=1) is true
		
		# Passed switch so assign position to new last coordinate
		@level.position = "#{x}:#{y}"

		# Check if position is on _finish
		win = @level.position is @level.finish

		# Return ok with new tile xy
		{ok:yes, moves:@level.moves, tile:{x:x,y:y}, win:win}

	# Rover direction change fn
	turn: (direction) ->
		# Check a valid direction is provided
		unless direction?.match /^(north|south|east|west|[nesw])$/i
			return {ok:no, m:'Invalid direction'}
		@level.direction = direction
		ok:yes

