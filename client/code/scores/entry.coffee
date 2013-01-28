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


# Scoredata rcvd feom server
scoreData = null

# RPC server ready
ss.server.on 'ready', ->

	# Wait for the DOM to finish loading
	jQuery ->

		# Load scores only if not loaded as socket reconnection will fire ready event again
		unless scoreData then ss.rpc 'score.get', (err, scores) ->

			# Check all good
			if err
				alert err
				return

			# Set scoredata
			scoreData = scores

			console.log scoreData

			# Create table data
			tData = []
			
			# Create table
			for row in scoreData
				tData.push [row.player, row.score, row.level]

			$('#scores').simple_datagrid {data:tData}

