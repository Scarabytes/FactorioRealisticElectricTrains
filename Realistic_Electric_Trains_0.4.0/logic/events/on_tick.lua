--on_tick.lua
-- Tick handler

do

	function on_tick(event)
		-- Power all locomotives
		local offset = event.tick % ticks_per_update
		local locos = global.electric_locos

		for i = #locos - offset, 1, -ticks_per_update do
			update_locomotive(locos[i])
		end

	end



	function get_fuel_data(locomotive)
		if locomotive.name == "ret-electric-locomotive" then
			local proto = game.item_prototypes["ret-dummy-fuel-1"]
			return {
				item = proto,
				power = 1,
				transfer = calc_transfer_rate("ret-electric-locomotive")
			}

		elseif locomotive.name == "ret-electric-locomotive-mk2" then
			local proto = game.item_prototypes["ret-dummy-fuel-2"]
			return {
				item = proto,
				power = 1,
				transfer = calc_transfer_rate("ret-electric-locomotive-mk2")
			}

		elseif locomotive.name == "ret-modular-locomotive" then
			local c = get_module_counts(locomotive)
			local suffix = get_module_string(c.s, c.p, c.e, c.b)
			local stats = get_module_stats(c.s, c.p, c.e, c.b)
			local proto = game.item_prototypes["ret-dummy-fuel-modular-" .. suffix]
			if not proto then
				proto = game.item_prototypes["ret-dummy-fuel-modular-"]
			end
			return {
				item = proto,
				power = stats.power,
				transfer = calc_transfer_rate("ret-modular-locomotive") * stats.power
			}

		end
	end


	function calc_transfer_rate(prototype_name) 
		local prototype = game.entity_prototypes[prototype_name]
		local efficiency_modifier = 1.05
		if prototype.burner_prototype.effectivity < 1 then
			efficiency_modifier = efficiency_modifier / prototype.burner_prototype.effectivity
		end
		-- max_energy_usage is in J/t instead of J/s as in data
		return prototype.max_energy_usage * efficiency_modifier * ticks_per_update
	end


	function update_locomotive(loco)
		local burner = loco.burner

		-- Get fuel data for this specific locomotive
		local fuel_data = global.fuel_for_loco[loco.unit_number]
		local updated = false
		if not fuel_data then
			updated = true
			fuel_data = get_fuel_data(loco)
			global.fuel_for_loco[loco.unit_number] = fuel_data
			--game.print(string.format("Updated %d with %s", loco.unit_number, fuel_data.item.name))
		end

		if not fuel_data then return end

		-- Refresh the burning item when the type was changed or the fuel ran out
		if burner.remaining_burning_fuel <= 0 or updated then
			burner.currently_burning = fuel_data.item
		end

		-- Calculate the missing energy and multiply in the power factor of this locomotive
		local missing_energy = (fuel_data.item.fuel_value - burner.remaining_burning_fuel) * fuel_data.power
		if missing_energy > 0 then
			local power_provider = find_power_provider(loco)

			if power_provider then
				local charge = take_power(power_provider, missing_energy, fuel_data.transfer)
				if charge > 0 then
					burner.remaining_burning_fuel =
							burner.remaining_burning_fuel + charge / fuel_data.power
				end
			end
		end
	end


	local enable_buffer = config.pole_enable_buffer
	local update_factor = ticks_per_update / 60

	function take_power(power_provider, missing_energy, max_transfer)
		if power_provider.energy >= enable_buffer then
			-- pole is powered, we can draw some power from it
			local deficit = power_provider.electric_buffer_size - power_provider.energy
			local max_deficit = max_transfer * 2 * update_factor + enable_buffer
			local max_deficit_increase = math.max(max_deficit - deficit, 0)

			local power = math.min(math.min(missing_energy, max_transfer * update_factor), max_deficit_increase)

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
