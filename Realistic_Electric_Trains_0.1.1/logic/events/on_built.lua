--on_build.lua
--Event handler for entities being built

require("logic.positions")
require("logic.overhead_line")

do
	local placer_to_base = {
		["ret-pole-placer"] = "ret-pole-base",
		["ret-signal-pole-placer"] = "ret-signal-pole-base",
		["ret-chain-pole-placer"] = "ret-chain-pole-base"
	}

	-- initializes a newly placed pole. The entity can either be a placer or the
	-- pole base entity.
	function create_pole(entity)
		local entity_name = entity.name
		local pos = { x = entity.position.x, y = entity.position.y }
		local force = entity.force
		local direction = entity.direction
		local surface = entity.surface

		-- Replace placer entity
		local pole_name, pole_direction = 
			fix_pole_build_name_and_dir(placer_to_base[entity_name], direction)

		local pole = surface.create_entity {
			name = pole_name,
			force = force,
			position = pos,
			direction = pole_direction,
			fast_replace = true
		}

		-- create wire, power and the pole rendering element
		local wire_pos = wire_pos_for_pole(pole.position, fix_pole_dir(pole))

		local wire = surface.create_entity {
			name = "ret-pole-wire",
			force = force,
			position = wire_pos
		}

		local power = surface.create_entity {
			name = "ret-pole-energy",
			force = force,
			position = pos,
			direction = 2 * (direction % 2)
		}

		local holder_name = "ret-pole-holder-straight"
		if direction % 2 == 1 then holder_name = "ret-pole-holder-diagonal" end

		local wire_holder = surface.create_entity {
			name = holder_name,
			force = force,
			position = pos,
			direction = direction - (direction % 2)
		}


		-- this defaults to 40kJ for whatever reason...
		power.electric_buffer_size = config.pole_power_buffer
		power.energy = config.pole_power_buffer


		-- store objects for fetching later
		global.wire_for_pole[pole.unit_number] = wire
		global.power_for_pole[pole.unit_number] = power
		global.graphic_for_pole[pole.unit_number] = wire_holder


		-- connect to the next poles
		install_pole(pole, {
				show_failures = enable_failure_text, 
				show_particles = enable_connect_particles
		})

		if enable_rewire_neighbours then
			rewire_neighbours(pole)
		end
	end

	-- Registers the given locomotive entity in the global table
	function register_locomotive(locomotive)
		global.electric_locos[locomotive.unit_number] = locomotive
	end

	-- Updates nearby poles when a rail is placed down
	function add_rail(rail)
		update_poles_near_rail(rail)
	end

	-- Handles the events on_built_entity & on_robot_built_entity
	function on_entity_built(event)
		local e = event.created_entity
		local n = e.name

			if n == "ret-pole-placer" or
			   n == "ret-signal-pole-placer" or
			   n == "ret-chain-pole-placer" then
					create_pole(e)

			elseif n == "ret-electric-locomotive" then
					register_locomotive(e)

			elseif n == "straight-rail" or n == "curved-rail" then
					add_rail(e)
			end
	end
end

return on_entity_built
