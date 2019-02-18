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

local enable_zigzag_wire = {
	type = "bool-setting",
	name = "ret-enable-zigzag-wire",
	setting_type = "runtime-global",
	default_value = false,
	order = "b-a"
}

local enable_zigzag_vertical_only = {
	type = "bool-setting",
	name = "ret-enable-zigzag-vertical-only",
	setting_type = "runtime-global",
	default_value = true,
	order = "b-a-a"
}

local enable_circuit_wire = {
	type = "bool-setting",
	name = "ret-enable-circuit-wire",
	setting_type = "runtime-global",
	default_value = false,
	order = "b-b"
}

local enable_rewire_neighbours = {
	type = "bool-setting",
	name = "ret-enable-rewire-neighbours",
	setting_type = "runtime-global",
	default_value = false,
	order = "b-c"
}

local max_pole_search_distance = {
	type = "int-setting",
	name = "ret-max-pole-search-distance",
	setting_type = "runtime-global",
	default_value = 6,
	min_value = 1,
	max_value = 20,
	order = "c"
}

data:extend{enable_connect_particles, enable_failure_text, 
			enable_circuit_wire, enable_zigzag_wire, enable_zigzag_vertical_only,
			enable_rewire_neighbours, max_pole_search_distance}