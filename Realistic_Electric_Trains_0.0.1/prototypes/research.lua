--research.lua

data:extend {
	
{
	type = "technology",
	name = "ret-electric-locomotives",
	icon_size = 128,
	icon = graphics .. "technology/electric-trains.png",
	effects = {
		{ type = "unlock-recipe", recipe = "ret-electric-locomotive" },
		{ type = "unlock-recipe", recipe = "ret-power-pole" },
		{ type = "unlock-recipe", recipe = "ret-signal-pole" },
		{ type = "unlock-recipe", recipe = "ret-chain-pole" },
		{ type = "unlock-recipe", recipe = "ret-pole-debugger" }
	},
	prerequisites = { "railway", "electric-engine"},
	unit =
	{
		count = 200,
		ingredients =
		{
			{"science-pack-1", 1},
			{"science-pack-2", 1},
			{"science-pack-3", 1}
		},
		time = 30
	},
	order = "c-g-c"
}

}