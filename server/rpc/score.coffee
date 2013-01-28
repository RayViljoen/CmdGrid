
# Get score class
Score = require '../Score'

# RPC interface
exports.actions = (req, res, ss) ->

	# Save score
	save: (score) ->
		
		# Save score
		Score.save score

		# Signal done
		do res

	get: ->

		# Get highscores
		Score.get res