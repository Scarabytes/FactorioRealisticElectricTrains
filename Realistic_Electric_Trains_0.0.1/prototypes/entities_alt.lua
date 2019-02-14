--entities.lua

-- assuming this is called from data.lua only
require("copy_prototype")
require("util")


-- Overhead Line Poles
local simple_pole =
	copy_prototype("rail-signal", "rail-signal", "ret-overhead-line-pole")
simple_pole.icon = graphics .. "items/overhead-line-pole.png"
simple_pole.icon_size = 32
simple_pole.animation = {
	filename = graphics .. "entities/overhead-line-pole.png",
	width = 330, height = 240,
	frame_count = 1, direction_count = 8, 
	shift = util.by_pixel(77, -40)
}
simple_pole.minable.result = "ret-overhead-line-pole-placer"
simple_pole.green_light = nil
simple_pole.orange_light = nil
simple_pole.red_light = nil
simple_pole.collision_mask = { "item-layer", "floor-layer", "train-layer", "player-layer" }
simple_pole.circuit_wire_max_distance = config.pole_max_wire_distance

local signal_pole =
	copy_prototype("rail-signal", "rail-signal", "ret-overhead-line-signal-pole")
signal_pole.icon = graphics .. "items/overhead-line-signal-pole.png"
signal_pole.icon_size = 32
signal_pole.animation = {
	filename = graphics .. "entities/overhead-line-signal-pole.png",
	width = 330, height = 240,
	frame_count = 3, direction_count = 8, 
	shift = util.by_pixel(77, -40)
}
signal_pole.collision_mask = { "item-layer", "floor-layer", "train-layer", "player-layer" }
signal_pole.circuit_wire_max_distance = config.pole_max_wire_distance

local chain_signal_pole =
	copy_prototype("rail-chain-signal", "rail-chain-signal", "ret-overhead-line-chain-signal-pole")
chain_signal_pole.icon = graphics .. "items/overhead-line-chain-signal-pole.png"
chain_signal_pole.icon_size = 32
chain_signal_pole.animation = {
	-- need to be rendered differently because for whatever reason, factorio 
	-- renders chain signals centered on the rail, not on the signal...
	filename = graphics .. "entities/overhead-line-chain-signal-pole.png",
	width = 380, height = 260,
	line_length = 5, frame_count = 5, direction_count = 8, 
	shift = util.by_pixel(110, -53)
}
chain_signal_pole.collision_mask = { "item-layer", "floor-layer", "train-layer", "player-layer" }
chain_signal_pole.circuit_wire_max_distance = config.pole_max_wire_distance

-- Placer

local simple_pole_placer = 
	copy_prototype("rail-signal", "rail-signal", "ret-overhead-line-pole-placer")
simple_pole_placer.icon = graphics .. "items/overhead-line-pole.png"
simple_pole_placer.icon_size = 32
simple_pole_placer.animation = {
	filename = graphics .. "entities/overhead-line-pole-placer.png",
	width = 165, height = 120, scale = 2,
	frame_count = 1, direction_count = 8, 
	shift = util.by_pixel(38.5, -20)
}
simple_pole_placer.circuit_wire_max_distance = config.pole_max_wire_distance

data:extend{simple_pole, signal_pole, chain_signal_pole, simple_pole_placer}

--==============================================================================

-- Pole wire and power consumer

local pole_wire = {
	type = "electric-pole",
	name = "ret-overhead-line-wire",
	icon = graphics .. "items/overhead-line-wire.png",
	icon_size = 32,
	flags = { "placeable-off-grid", "not-blueprintable", "not-deconstructable" },
	collision_box = {{0, 0}, {0, 0}},
	collision_mask = {},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	drawing_box = {{-0.5, -0.5}, {0.5, 0.5}},
	pictures = { 
		filename = graphics .. "marker.png",
		width = 32, height = 32, direction_count = 1
	},
	selection_priority = 100,
	maximum_wire_distance = config.pole_max_wire_distance,
	supply_area_distance = config.pole_supply_area,
	connection_points = { {
		shadow = { copper = {4.3, 0.1}, green = {0.0, 0.0}, red = {0.0, 0.0} },
		wire   = { copper = {0.0, -2.5}, green = {0.0, 0.0}, red = {0.0, 0.0} },
	} },
	radius_visualisation_picture =
	{
		filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
		width = 12, height = 12, priority = "extra-high-no-scale"
    }
}

local pole_power = {
	type = "electric-energy-interface",
	name = "ret-overhead-line-power",
	icon = graphics .. "items/overhead-line-wire.png",
	icon_size = 32,
	flags = { "placeable-off-grid", "not-blueprintable", "not-deconstructable" },
	collision_mask = {},
	picture = {
		filename = graphics .. "empty.png",
		width = 1, height = 1
	},
	energy_source = {
		type = "electric",
		buffer_capacity = config.pole_power_buffer,
		usage_priority = "secondary-input",
		input_flow_limit = "6MW"
	}
}

data:extend{pole_wire, pole_power}

--==============================================================================

-- Visual feedback

local connected_particle = {
	type = "particle",
	name = "ret-connected-particle",
    flags = { "not-on-map", "placeable-off-grid" },
	pictures = {{
		filename = graphics .. "entities/powered-particle.png",
		width = 32, height = 32, frame_count = 1
	}},
	life_time = 150
}

local disconnected_particle = {
	type = "particle",
	name = "ret-disconnected-particle",
    flags = { "not-on-map", "placeable-off-grid" },
	pictures = {{
		filename = graphics .. "entities/unpowered-particle.png",
		width = 32, height = 32, frame_count = 1
	}},
	life_time = 150
}

data:extend{connected_particle, disconnected_particle}

--==============================================================================

-- Electric Locomotives

local electric_locomotive =
	copy_prototype("locomotive", "locomotive", "ret-electric-locomotive")
electric_locomotive.burner.fuel_inventory_size = 0
electric_locomotive.burner.smoke = nil
electric_locomotive.reversing_power_modifier = 0.8

data:extend{electric_locomotive}
