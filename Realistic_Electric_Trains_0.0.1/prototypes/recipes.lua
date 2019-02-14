-- recipes.lua

data:extend {
	
{
	type = "recipe",
	name = "ret-electric-locomotive",
	result = "ret-electric-locomotive",
	ingredients = {
		{"steel-plate", 40}, 
		{"electric-engine-unit", 30},
		{"advanced-circuit", 20},
		{"iron-gear-wheel", 20}
	},
	energy_required = 8,
	enabled = false
},

{
	type = "recipe",
	name = "ret-power-pole",
	result = "ret-pole-placer",
	ingredients = {
		{"steel-plate", 4},
		{"iron-stick", 2},
		{"copper-plate", 4}
	},
	energy_required = 1,
	enabled = false
},

{
	type = "recipe",
	name = "ret-signal-pole",
	result = "ret-signal-pole-placer",
	ingredients = {
		{"ret-pole-placer", 1},
		{"rail-signal", 1}
	},
	energy_required = 1,
	enabled = false
},

{
	type = "recipe",
	name = "ret-chain-pole",
	result = "ret-chain-pole-placer",
	ingredients = {
		{"ret-pole-placer", 1},
		{"rail-chain-signal", 1}
	},
	energy_required = 1,
	enabled = false
},

{
	type = "recipe",
	name = "ret-pole-debugger",
	result = "ret-pole-debugger",
	ingredients = {
		{"electronic-circuit", 3}
	},
	enabled = false
}

}