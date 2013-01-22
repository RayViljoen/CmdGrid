nStore = require 'nstore'
scores = nStore.new 'scores.db'


# Save new score
module.exports =

	# Save score
	save: (player, level, moves) ->
		scores.save player, {level:level, score:100/moves}, (err) ->
			console.log err if err