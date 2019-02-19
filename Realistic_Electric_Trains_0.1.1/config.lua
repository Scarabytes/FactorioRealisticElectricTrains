--config.lua

local ticks_per_update = settings.startup["ret-ticks-per-update"].value

-- 2.4MW
local loco_max_supported_power = 2400000
-- 600kW (vanilla)
local locomotive_power = 600000

config = {
	pole_max_wire_distance = 16,
	pole_supply_area = 4,

	-- Supports 8 times the loco power per pole buffer
	pole_power_buffer = 8 * loco_max_supported_power / 60 * ticks_per_update,
	-- Refills the energy of two locos until the next update
	pole_flow_limit = 2 * loco_max_supported_power,

	-- 600kW (default)
	locomotive_power = locomotive_power,
	locomotive_storage = locomotive_power / 60 * ticks_per_update
}

function toW(value)
	return string.format("%dW", value)
end

function toJ(value)
	return string.format("%dJ", value)
end
