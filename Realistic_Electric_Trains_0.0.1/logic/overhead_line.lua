--overhead_line.lua

require("util")
require("config")
require("rail_search")

function display_powered_state(rail, unpowered)
	local surface = rail.surface

	local e = surface.find_entity("ret-disconnected-particle", rail.position)
	if e then e.destroy() end
	e = surface.find_entity("ret-connected-particle", rail.position)
	if e then e.destroy() end

	local particle = "ret-connected-particle"
	if unpowered then particle = "ret-disconnected-particle" end

	surface.create_entity {
		name = particle,
		position = rail.position,
		movement = {0, 0},
		height = 0,
		vertical_speed = 0,
		frame_speed = 0
	}
end

function mark_powered_rails(pole, search_results, show_particles)
	for _, success in ipairs(search_results.success) do
		local other_pole = success.pole
		for _, rail in ipairs(success.path) do
			local d1 = util.distance(rail.position, pole.position)
			local d2 = util.distance(rail.position, other_pole.position)
			if d1 <= d2 then
				global.power_for_rail[rail.unit_number] = global.power_for_pole[pole.unit_number]
			else
				global.power_for_rail[rail.unit_number] = global.power_for_pole[other_pole.unit_number]	
			end
			if show_particles then
				display_powered_state(rail)
			end
		end
	end
end

function remove_powered_rails(search_results, show_particles)
	for _, success in pairs(search_results.success) do
		for _, rail in pairs(success.path) do
			global.power_for_rail[rail.unit_number] = nil
			if show_particles then
				display_powered_state(rail, true)
			end
		end
	end
end

function rewire_pole(pole, search_results)
	-- disconnect all wires to neighbour overhead lines
	local wire = global.wire_for_pole[pole.unit_number]
	for _, neighbour in pairs(wire.neighbours.copper) do
		if neighbour.name == "ret-pole-wire" then
			wire.disconnect_neighbour(neighbour)
		end
	end

	-- reconnect proper wires
	for _, success in pairs(search_results.success) do
		wire.connect_neighbour(global.wire_for_pole[success.pole.unit_number])
		if enable_circuit_wire then
			pole.connect_neighbour(
				{wire = defines.wire_type.red, target_entity = success.pole})
			pole.connect_neighbour(
				{wire = defines.wire_type.green, target_entity = success.pole})
		end
	end
end

function rewire_neighbours(pole)
	local search_results = search_next_poles(pole, config.pole_max_wire_distance)
	for _, success in pairs(search_results.success) do
		local new_search = search_next_poles(success.pole, config.pole_max_wire_distance)
		rewire_pole(success.pole, new_search)
	end
end

function display_failures(pole, search_results)
	for _, failure in pairs(search_results.failure) do 
		if failure.curve then
			local pos = failure.curve.position
			failure.pole.surface.create_entity {
				name = "flying-text",
				position = pos,
				text = {"message.ret-connect-failure"},
				color = {r = 1, g = 0.25}
			}
			failure.pole.surface.create_entity {
				name = "flying-text",
				position = {x = pos.x + 0.5, y = pos.y + 0.5},
				text = {"message.ret-connect-failure-curve"},
				color = {r = 1, g = 0.5}
			}
		else
			local pos = failure.pole.position
			local distance = util.distance(pos, pole.position)
			local too_far = math.ceil(distance - config.pole_max_wire_distance)
			failure.pole.surface.create_entity {
				name = "flying-text",
				position = pos,
				text = {"message.ret-connect-failure"},
				color = {r = 1, g = 0.25}
			}
			failure.pole.surface.create_entity {
				name = "flying-text",
				position = {x = pos.x + 0.5, y = pos.y + 0.5},
				text = {"message.ret-connect-failure-distance", too_far},
				color = {r = 1, g = 0.5}
			}
		end
	end
end

-- moves the wires so that a zigzag pattern is created
function zigzag_pole_wire(start_pole, search_results)
	local other_nonstandard = 0
	local has_straight = false
	local has_vertical

	for _, success in pairs(search_results.success) do
		if not success.has_curve then
			has_straight = true
			has_vertical = success.path[1].direction == defines.direction.north
			local pole = success.pole
			local mode = find_wire_mode(pole, global.wire_for_pole[pole.unit_number])
			if mode ~= 2 then
				if other_nonstandard == 0 then
					other_nonstandard = mode
				elseif other_nonstandard ~= mode then
					other_nonstandard = 2
				end
			end
		end
	end

	local invert = {[0] = 3, [1] = 3, [2] = 2, [3] = 1}

	if has_straight and (has_vertical or not enable_zigzag_vertical_only) then
		local wire = global.wire_for_pole[start_pole.unit_number]
		local position = wire_pos_for_pole(start_pole.position, 
							fix_pole_dir(start_pole), invert[other_nonstandard])
		wire.teleport(position)
	end
end

-- options contains two booleans named show_failures and show_particles
function install_pole(pole, options, ignore) 
	local next_poles = search_next_poles(pole, config.pole_max_wire_distance, ignore)
	if options.show_failures then display_failures(pole, next_poles) end
	mark_powered_rails(pole, next_poles, options.show_particles)
	if enable_zigzag_wire then zigzag_pole_wire(pole, next_poles) end
	rewire_pole(pole, next_poles)
end

function uninstall_pole(pole, show_particles)
	local next_poles = search_next_poles(pole, config.pole_max_wire_distance)
	remove_powered_rails(next_poles, show_particles)
	for _, success in pairs(next_poles.success) do
		install_pole(success.pole, {show_particles = show_particles}, pole)
	end
end

function find_power_provider(locomotive)
	local surface = locomotive.surface
	local entities = surface.find_entities(around_position(locomotive.position, 1))
	local lookup = global.power_for_rail

	for _, entity in pairs(entities) do
		local power = lookup[entity.unit_number]
		if power and power.valid then return power end
	end
	return nil
end

function update_poles_near_rail(rail)
	local nearby_poles = search_nearby_poles(rail, config.pole_max_wire_distance / 2 + 2)
	for _, success in pairs(nearby_poles.success) do
		install_pole(success.pole, {show_particles = enable_connect_particles})
	end
end

function unpower_nearby_rails(rail)
	local nearby_poles = search_nearby_poles(rail, config.pole_max_wire_distance / 2 + 2)
	for _, success in pairs(nearby_poles.success) do
		for _, spot in pairs(success.path) do
			global.power_for_rail[spot.unit_number] = nil
			if enable_connect_particles then display_powered_state(spot, true) end
		end
		install_pole(success.pole, {}, rail)
	end
end
