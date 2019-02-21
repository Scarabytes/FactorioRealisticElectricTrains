--on_setup_changed.lua
--Event handler for caching the runtime settings and updating when configuration changes

function on_settings_changed(event)
	ticks_per_update = settings.startup["ret-ticks-per-update"].value

	enable_connect_particles = settings.global["ret-enable-connect-particles"].value
	enable_failure_text = settings.global["ret-enable-failure-text"].value
	enable_zigzag_wire = settings.global["ret-enable-zigzag-wire"].value
	enable_zigzag_vertical_only = settings.global["ret-enable-zigzag-vertical-only"].value
	enable_circuit_wire = settings.global["ret-enable-circuit-wire"].value
	enable_rewire_neighbours = settings.global["ret-enable-rewire-neighbours"].value
	max_pole_search_distance = settings.global["ret-max-pole-search-distance"].value
end

function on_configuration_changed(event)
	-- update the electric buffer size for all energy consumers when the 
	-- settings were changed
	for _, power in pairs(global.power_for_pole) do
		local missing_energy = power.electric_buffer_size - power.energy
		power.electric_buffer_size = config.pole_power_buffer
		power.energy = config.pole_power_buffer - missing_energy
	end
end
