--config.lua

local ticks_per_update = settings.startup["ret-ticks-per-update"].value


function store(power)
	return power / 60 * (ticks_per_update + 5)
end

config = {
	pole_max_wire_distance = 16,

	pole_supply_area = 4,

	-- Refills the buffer until the next update
	pole_flow_limit = 4800000,
	-- Pole enable buffer (1kJ)
	pole_enable_buffer = 1000,
	-- Pole maximum deficit (9.6MJ)
	pole_max_deficit = 9600000,


	-- When a locomotive exceeds the soft cap, it might lose power temporarily 
	-- when multiple similar locomotives are powered by a single pole, e.g. when
	-- they pull the same train. (4.8MW)
	power_soft_cap = 4800000,
	-- When a locomotive exceeds the hard cap, it cannot be powered by the grid
	-- at all. (9.6MW)
	power_hard_cap = 9600000,



	-- Locomotive Mk 1 (600kW, like vanilla)
	locomotive_power = 600000,
	locomotive_storage = store(600000),
	-- Locomotive Mk 2 (1.2MW, two times vanilla)
	advanced_locomotive_power = 1200000,
	advanced_locomotive_storage = store(1200000),
	-- Modular Locomotive (1.8MW, three times vanilla)
	modular_locomotive_base_power = 1800000,
	modular_locomotive_storage = store(1800000)
}

function toW(value)
	return string.format("%dW", value)
end

function toJ(value)
	return string.format("%dJ", value)
end
