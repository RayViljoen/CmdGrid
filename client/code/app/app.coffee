# Client Code

# Load app - provides global game instance
require '/canvas'

# Load new game with level from url hash
ss.rpc 'game.load', location.hash[1..], (res) ->
	if res instanceof Array then game.load(res) else alert 'Could not load level'