--config.lua

config = {
	
	pole_max_wire_distance = 16,
	pole_supply_area = 4,
	pole_power_buffer = "800kJ",
	pole_power_buffer_val = 800000,
	pole_flow_limit = "1200kW",
	pole_flow_limit_val = 1200000,
	loco_max_energy_transfer = "200kJ",
	loco_max_energy_transfer_val = 200000,
	supported_rails = {
		["straight-rail"] = true,
		["curved-rail"] = true,
		["bi-straight-rail-wood"] = true,
		["bi-curved-rail-wood"] = true,
		["bi-straight-rail-wood-bridge"] = true,
		["bi-curved-rail-wood-bridge"] = true,
		["bi-straight-rail-power"] = true,
		["bi-curved-rail-power"] = true,
	}
}