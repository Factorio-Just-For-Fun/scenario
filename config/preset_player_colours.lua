--- Preset colours that players get when they join the server, if not in the list then will be given a random colour (which isnt disallowed)
-- @config Preset-Player-Colours

return {
	players={ --- @setting players list of all players and the colour in rgb256 that they will recive upon joining
		joloman2 = {r = 0, g = 255, b = 255},
		ciderdave = {r = 0, g = 0, b = 255},
		Cykloid = {r = 0, g = 255, b = 0},
		Spzi = {r = 111, g = 111, b = 252},
		mskitty = {r = 255, g = 105, b = 180},
	},
	disallow = { --- @setting disallow colours which will not given to players; the value does not matter it is only the key which is checked
		black = {r = 0, g = 0, b = 0},
		white = {r = 255, g = 255, b = 255},
		success = {r = 0, g = 255, b = 0},
		warning = {r = 255, g = 255, b = 0},
		fail = {r = 255, g = 0, b = 0},
		info = {r = 255, g = 255, b = 255}
	}
}
