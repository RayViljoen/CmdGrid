
# Get score class
Same = require '../Score'

# RPC interface
exports.actions = (req, res, ss) ->

	# Save score
	score: (score, etc) ->
		console.log 'Save game to some db'