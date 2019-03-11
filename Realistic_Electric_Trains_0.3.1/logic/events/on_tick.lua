--on_tick.lua
-- Tick handler

do

	local loco_fuel_data


	function on_tick(event)

		if not loco_fuel_data then
			setup_fuel_data()
		end

		-- Power all locomotives
		local offset = event.tick % ticks_per_update
		local locos = global.electric_locos

		for i = #locos - offset, 1, -ticks_per_update do
			update_locomotive(locos[i])
		end

	end



	function setup_fuel_data()
		local loco_1_prototype = game.entity_prototypes["ret-electric-locomotive"]
		local loco_1_efficiency_modifier = 1.05
		if loco_1_prototype.burner_prototype.effectivity < 1 then
			loco_1_efficiency_modifier = loco_1_efficiency_modifier / loco_1_prototype.burner_prototype.effectivity
		end
		
		local loco_2_prototype = game.entity_prototypes["ret-electric-locomotive-mk2"]
		local loco_2_efficiency_modifier = 1.05
		if loco_2_prototype.burner_prototype.effectivity < 1 then
			loco_2_efficiency_modifier = loco_2_efficiency_modifier / loco_2_prototype.burner_prototype.effectivity
		end
		
		loco_fuel_data = {
			["ret-electric-locomotive"] = {
				item = game.item_prototypes["ret-dummy-fuel-1"],
				fuel = game.item_prototypes["ret-dummy-fuel-1"].fuel_value,
				-- max_energy_usage is in J/t instead of J/s as in data
				transfer = loco_1_prototype.max_energy_usage * ticks_per_update * loco_1_efficiency_modifier,
			},
			["ret-electric-locomotive-mk2"] = {
				item = game.item_prototypes["ret-dummy-fuel-2"],
				fuel = game.item_prototypes["ret-dummy-fuel-2"].fuel_value,
				-- max_energy_usage is in J/t instead of J/s as in data
				transfer = loco_2_prototype.max_energy_usage * ticks_per_update * loco_2_efficiency_modifier,
			}
		}
	end


	function update_locomotive(loco)
		local burner = loco.burner
		local fuel_data = loco_fuel_data[loco.name]

		if burner.remaining_burning_fuel <= 0 then
			burner.currently_burning = fuel_data.item
		end

		local missing_energy = fuel_data.fuel - burner.remaining_burning_fuel
		if missing_energy > 0 then
			local power_provider = find_power_provider(loco)

			if power_provider then
				local transfer = math.min(missing_energy, fuel_data.transfer)
				local charge = take_power(power_provider, transfer)
				if charge > 0 then
					burner.remaining_burning_fuel =
							burner.remaining_burning_fuel + charge
				end
			end
		end
	end

	local enable_buffer = config.pole_enable_buffer

	function take_power(power_provider, power)
		local deficit = power_provider.electric_buffer_size - power_provider.energy

		if power_provider.energy >= enable_buffer and deficit + power < config.pole_max_deficit then
			-- pole is powered and not too drained, we can draw some power from it
			power_provider.electric_buffer_size = deficit + power + enable_buffer
			power_provider.energy = enable_buffer
			return power
		else
			-- no power can be drawn
			return 0
		end
	end
end


return on_tick
