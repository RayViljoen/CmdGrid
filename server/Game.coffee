# Game class
class Game

	constructor: (@level, player = 'Guest') ->

		# Track win status to reject any post-win commands
		@won = no

		# Store player name
		@level.player = player
		
		# Create size x size array
		@level.map = []

		# Set move increment
		@level.moves = 0

		row = []
		row.push 0 for i in [1..@level.grid]
		@level.map.push row[..] for i in [1..@level.grid]

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

	# Player move fn
	move: (spaces) ->

		# Reject any commands if game is won
		return {ok:no, m:'Game won'} if @won

		# Check spaces isset to abs number
		spaces = Math.round(Math.abs spaces)
		return {ok:no, m:'Invalid distance'} unless spaces

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
					return {ok:no, m:'Invalid move!', moves:@level.moves, tile:{x,y}, win:no} unless @tryTile(x-=1, y) is true
				when 'south', 's'
					return {ok:no, m:'Invalid move!', moves:@level.moves, tile:{x,y}, win:no} unless @tryTile(x+=1, y) is true
				when 'east', 'e'
					return {ok:no, m:'Invalid move!', moves:@level.moves, tile:{x,y}, win:no} unless @tryTile(x, y+=1) is true
				when 'west', 'w'
					return {ok:no, m:'Invalid move!', moves:@level.moves, tile:{x,y}, win:no} unless @tryTile(x, y-=1) is true
		
		# Passed switch so assign position to new last coordinate
		@level.position = "#{x}:#{y}"

		# Check if position is on _finish
		@won = @level.position is @level.finish

		# Return ok with new tile xy
		{ok:yes, moves:@level.moves, tile:{x,y}, @won}

	# Rover direction change fn
	turn: (direction) ->

		# Reject any commands if game is won
		return {ok:no, m:'Game won'} if @won

		# Check a valid direction is provided
		unless direction?.match /^(north|south|east|west|[nesw])$/i
			return {ok:no, m:'Invalid direction'}

		# Set to full direction if abbreviatted
		switch direction.toLowerCase()
			when 'n' then direction = 'north'
			when 's' then direction = 'south'
			when 'e' then direction = 'east'
			when 'w' then direction = 'west'
		
		@level.direction = direction
		{ok:yes, direction:direction}

module.exports = Game