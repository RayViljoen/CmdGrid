# Client Code

# Load app
require '/canvas'

# Load new game with level from url hash
ss.rpc 'game.load', location.hash[1..], (res) ->
	console.log location.hash[1..]
	game.load(res) if res instanceof Array
