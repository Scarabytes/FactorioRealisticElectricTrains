--settings.lua

local enable_connect_particles = {
	type = "bool-setting",
	name = "ret-enable-connect-particles",
	setting_type = "runtime-global",
	default_value = true,
	order = "a-a"
}

local enable_failure_text = {
	type = "bool-setting",
	name = "ret-enable-failure-text",
	setting_type = "runtime-global",
	default_value = true,
	order = "a-b"
}

local max_pole_search_distance = {
	type = "int-setting",
	name = "ret-max-pole-search-distance",
	setting_type = "runtime-global",
	default_value = 6,
	min_value = 1,
	max_value = 20,
	order = "b"
}

local enable_rewire_neighbours = {
	type = "bool-setting",
	name = "ret-enable-rewire-neighbours",
	setting_type = "runtime-global",
	default_value = false,
	order = "c"
}

data:extend{enable_failure_text, enable_connect_particles, 
			max_pole_search_distance, enable_rewire_neighbours}