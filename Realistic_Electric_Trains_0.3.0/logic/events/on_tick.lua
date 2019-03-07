--on_tick.lua
-- Tick handler

do

	local loco_fuel_data


	function on_tick(event)

		if not loco_fuel_data then
			loco_fuel_data = {
				["ret-electric-locomotive"] = {
					item = game.item_prototypes["ret-dummy-fuel-1"],
					fuel = game.item_prototypes["ret-dummy-fuel-1"].fuel_value,
					transfer = config.locomotive_power / 60 * ticks_per_update * 1.05
				},
				["ret-electric-locomotive-mk2"] = {
					item = game.item_prototypes["ret-dummy-fuel-2"],
					fuel = game.item_prototypes["ret-dummy-fuel-2"].fuel_value,
					transfer = config.locomotive2_power / 60 * ticks_per_update * 1.05
				}
			}
		end


		-- Power all locomotives
		local offset = event.tick % ticks_per_update
		local locos = global.electric_locos

		for i = #locos - offset, 1, -ticks_per_update do
			local loco = locos[i]
			local burner = loco.burner

			local fuel_data = loco_fuel_data[loco.name]

			if burner.remaining_burning_fuel <= 0 then
				burner.currently_burning = fuel_data.item
			end

			local missing_energy = fuel_data.fuel - burner.remaining_burning_fuel
			local power_provider = find_power_provider(loco)

			if power_provider then
				local transfer = math.min(missing_energy, 
								 math.min(power_provider.energy, fuel_data.transfer))
				if transfer > 0 then
					burner.remaining_burning_fuel =
							burner.remaining_burning_fuel + transfer
					power_provider.energy =
							power_provider.energy - transfer
				end
			end
		end -- for loop


	end
end

return on_tick
