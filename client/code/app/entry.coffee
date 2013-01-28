# This file automatically gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

ss.server.on 'disconnect', ->
	console.log('Connection down :-(')

ss.server.on 'reconnect', ->
	console.log('Connection back up :-)')

# Listen for session expire
ss.event.on 'expire', ->
	alert 'Your game session has expired!'
	do location.reload

ss.server.on 'ready', ->

	# Wait for the DOM to finish loading
	jQuery ->

		# Load app
		require('/app')
