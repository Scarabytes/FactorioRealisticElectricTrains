--on_tick.lua
-- Tick handler

do

	local dummy_fuel
	local dummy_fuel_value
	local max_transfer = config.locomotive_power / 60 * ticks_per_update

	function on_tick(event)
		if not dummy_fuel then
			dummy_fuel = game.item_prototypes["ret-dummy-fuel-1"]
			dummy_fuel_value = dummy_fuel.fuel_value
		end

		if event.tick % ticks_per_update == 0 then
			-- power all trains
			for _, loco in pairs(global.electric_locos) do
				local burner = loco.burner
				burner.currently_burning = dummy_fuel
				local missing_energy = dummy_fuel_value - burner.remaining_burning_fuel
				local power_provider = find_power_provider(loco)
				if power_provider then
					local transfer = math.min(missing_energy, 
									 math.min(power_provider.energy, max_transfer))
					if transfer > 0 then
						burner.remaining_burning_fuel =
								burner.remaining_burning_fuel + transfer
						power_provider.energy =
								power_provider.energy - transfer
					end
				end
			end
		end
	end

end

return on_tick
