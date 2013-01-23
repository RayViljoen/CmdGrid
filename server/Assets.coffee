
path = require 'path'

# Glob module for matching images
glob = require 'glob'

# DataURI module
datauri = require 'datauri'

# Loads level assets as DataURIs
module.exports = (levelNum, callback) ->

	# Make sure levelNum is nothing other than a round number
	# Do not want user specied include paths in require statement that follows
	return no unless levelNum = Math.round(Math.abs levelNum)

	# Glob image files from level directory
	glob "./server/levels/#{levelNum}/*.+(jpg|jpeg|png|gif)", (err, images) ->
		if err
			console.log err
			callback err
			return

		# Create array of dataURI's
		encImages = {}
		for image in images
			# Get filename as used to identify map object
			imgName = path.basename image, path.extname(image)
			encImages[imgName] = datauri image

		# Finally do callback
		callback err, encImages