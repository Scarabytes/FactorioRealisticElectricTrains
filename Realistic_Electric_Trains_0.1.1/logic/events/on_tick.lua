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

		-- Power all locomotives
		local offset = event.tick % ticks_per_update
		local locos = global.electric_locos
		local count = 0
		for i = #locos - offset, 1, -ticks_per_update do
			count = count + 1
			local loco = locos[i]
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

return on_tick
