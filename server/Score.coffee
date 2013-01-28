
# Open sqlite db
sqlite3 = require 'sqlite3'
db = new sqlite3.Database('scores.db')

# Create table structure
tableStructure = """
	CREATE TABLE IF NOT EXISTS "scores" (
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"date" DATETIME DEFAULT (CURRENT_DATE),
		"player" VARCHAR(255),
		"score" INT,
		"level" INT
	) """

# Execute create table and log if error
db.run tableStructure, (err) ->
	console.log 'Database ready'
	console.log err if err

# ====================================================
# 	Export db getter/setter
# ====================================================

module.exports =

	save: (data) ->

		db.run "INSERT INTO scores (player, score, level) VALUES (?, ?, ?)", data.player, data.score, data.level, (err) ->
			
			# Log any errors
			if err
				console.log err
				return

	# Simply gets all rows for today
	get: (callback) -> # Get Saved message of the day only else null

		db.all "SELECT * FROM scores ORDER BY score DESC", (err, rows) ->

			console.log rows

			# Log any errors
			console.log err if err

			# Pass rows to callback
			callback err, rows
