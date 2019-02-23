--items.lua

-- assuming this is called from data.lua only
require("copy_prototype")

-- Add electric train subgroup
data:extend{{
	type = "item-subgroup",
	name = "electric-trains",
	group = "logistics",
	order = "e-a"
}}

-- Placer

local simple_pole_placer = {
	type = "item",
	name = "ret-pole-placer",
	icon = graphics .. "items/power-pole.png",
	icon_size = 32,
	flags = { "goes-to-quickbar" },
	place_result = "ret-pole-placer",
	stack_size = 50,
	subgroup = "electric-trains",
	order = "a[poles]-a"
}

local signal_pole_placer = {
	type = "item",
	name = "ret-signal-pole-placer",
	icon = graphics .. "items/signal-pole.png",
	icon_size = 32,
	flags = { "goes-to-quickbar" },
	place_result = "ret-signal-pole-placer",
	stack_size = 50,
	subgroup = "electric-trains",
	order = "a[poles]-b"
}

local chain_pole_placer = {
	type = "item",
	name = "ret-chain-pole-placer",
	icon = graphics .. "items/chain-pole.png",
	icon_size = 32,
	flags = { "goes-to-quickbar" },
	place_result = "ret-chain-pole-placer",
	stack_size = 50,
	subgroup = "electric-trains",
	order = "a[poles]-c"
}

local pole_debugger = {
	type = "selection-tool",
	name = "ret-pole-debugger",
	icon = graphics .. "items/pole-debugger.png",
	icon_size = 32,
	flags = { "goes-to-quickbar" },
	stack_size = 5,
	selection_color = {b = 1.0, g = 0.5},
	alt_selection_color = {b = 1.0, g = 0.5},
	selection_mode = {"blueprint"},
	alt_selection_mode = {"blueprint"},
	selection_cursor_box_type = "electricity",
	alt_selection_cursor_box_type = "electricity",
	subgroup = "electric-trains",
	order = "a[poles]-d"
}

data:extend{simple_pole_placer, signal_pole_placer, chain_pole_placer, pole_debugger}

--==============================================================================

-- Electric locomotive

local electric_locomotive = {
	type = "item",
	name = "ret-electric-locomotive",
	icon = graphics .. "items/electric-locomotive.png",
	icon_size = 32,
	flags = { "goes-to-quickbar" },
	place_result = "ret-electric-locomotive",
	stack_size = 5,
	subgroup = "electric-trains",
	order = "b[locomotives]-a"
}

local electric_locomotive_mk2 = {
	type = "item",
	name = "ret-electric-locomotive-mk2",
	icon = graphics .. "items/electric-locomotive-2.png",
	icon_size = 32,
	flags = { "goes-to-quickbar" },
	place_result = "ret-electric-locomotive-mk2",
	stack_size = 5,
	subgroup = "electric-trains",
	order = "b[locomotives]-b"
}

data:extend{electric_locomotive, electric_locomotive_mk2}

--==============================================================================

-- Dummy items

local dummy_pole_energy = {
	type = "item",
	name = "ret-dummy-pole-energy",
	icon = graphics .. "items/pole-wire.png",
	icon_size = 32,
	flags = { "hidden" },
	stack_size = 1
}

local dummy_pole_holder = {
	type = "item",
	name = "ret-dummy-pole-holder",
	icon = graphics .. "items/pole-wire.png",
	icon_size = 32,
	flags = { "hidden" },
	stack_size = 1
}

local dummy_fuel_1 = {
	type = "item",
	name = "ret-dummy-fuel-1",
	icon = graphics .. "items/dummy-fuel.png",
	icon_size = 32,
	flags = { "hidden" },
	stack_size = 1,
	fuel_category = "chemical",
	fuel_value = toJ(config.locomotive_storage),
	fuel_acceleration_multiplier = 1.5,
	fuel_top_speed_multiplier = 1.1,
	fuel_emission_multiplier = 0.1
	-- For Locomotive Mk1
	-- Adjusted acceleration: 150%
}

local dummy_fuel_2 = {
	type = "item",
	name = "ret-dummy-fuel-2",
	icon = graphics .. "items/dummy-fuel.png",
	icon_size = 32,
	flags = { "hidden" },
	stack_size = 1,
	fuel_category = "chemical",
	fuel_value = toJ(config.locomotive2_storage),
	fuel_acceleration_multiplier = 1.0,
	fuel_top_speed_multiplier = 1.2,
	fuel_emission_multiplier = 0.1
	-- For Locomotive Mk2
	-- Adjusted acceleration: 200%
}

data:extend{dummy_pole_energy, dummy_pole_holder, dummy_fuel_1, dummy_fuel_2}
