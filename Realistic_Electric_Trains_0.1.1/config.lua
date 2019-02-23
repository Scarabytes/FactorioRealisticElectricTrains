--config.lua

local ticks_per_update = settings.startup["ret-ticks-per-update"].value

-- 2.4MW
local loco_max_supported_power = 2400000
-- 600kW (vanilla)
local locomotive_power =   600000
-- 1.2MW (2* vanilla)
local locomotive2_power = 1200000

function store(power)
	return power / 60 * (ticks_per_update + 5)
end

config = {
	pole_max_wire_distance = 16,
	pole_supply_area = 4,

	-- Supports 8 times the maximum loco power per pole buffer
	pole_power_buffer = store(8 * loco_max_supported_power),
	-- Refills the energy of two locos until the next update
	pole_flow_limit = 2 * loco_max_supported_power,

	-- Locomotive Mk 1
	locomotive_power = locomotive_power,
	locomotive_storage = store(locomotive_power),
	-- Locomotive Mk 2
	locomotive2_power = locomotive2_power,
	locomotive2_storage = store(locomotive2_power)
}

function toW(value)
	return string.format("%dW", value)
end

function toJ(value)
	return string.format("%dJ", value)
end
