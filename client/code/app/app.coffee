# Client Code

# Load app - provides global game instance
require '/canvas'


# Load new game on page load

# Get level from pathname which should be /level*/
level = location.pathname.match(/^\/level([1-9][0-9]*)/i)?[1]
# Load on server
ss.rpc 'game.load', level, (res) ->
	if res instanceof Array then game.load(res) else alert 'Could not load level'