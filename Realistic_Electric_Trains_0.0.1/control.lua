--control.lua

require("config")
require("logic.overhead_line")


-- initialization
script.on_init(
	function(e)
		-- init lookup tables
		global.wire_for_pole = {}   -- Pole ID -> Wire Entity
		global.power_for_pole = {}  -- Pole ID -> Power Entity
		global.graphic_for_pole = {}-- Pole ID -> Graphic Entity
		global.power_for_rail = {}  -- Rail ID -> Power Entity
		global.electric_locos = {}  -- Loco ID -> Loco Entity
	end
)

-- settings cache

enable_failure_text = settings.global["ret-enable-failure-text"].value
enable_connect_particles = settings.global["ret-enable-connect-particles"].value
max_pole_search_distance = settings.global["ret-max-pole-search-distance"].value
enable_rewire_neighbours = settings.global["ret-enable-rewire-neighbours"].value
enable_circuit_wire = settings.global["ret-enable-circuit-wire"].value

function cache_settings()
	enable_failure_text = settings.global["ret-enable-failure-text"].value
	enable_connect_particles = settings.global["ret-enable-connect-particles"].value
	max_pole_search_distance = settings.global["ret-max-pole-search-distance"].value
	enable_rewire_neighbours = settings.global["ret-enable-rewire-neighbours"].value
	enable_circuit_wire = settings.global["ret-enable-circuit-wire"].value
end

script.on_event(defines.events.on_runtime_mod_setting_changed, cache_settings)

--==============================================================================

-- On build events

function create_pole(event)
	local placer = event.created_entity

	-- replace pole placer
	local placer_name = placer.name
	local pos = { x = placer.position.x, y = placer.position.y }
	local force = placer.force
	local direction = placer.direction
	local surface = placer.surface

	placer.destroy() -- Need to destroy first, because signals can't be placed
	                 -- on top of each other

	local actual_pole = {
		["ret-pole-placer"] = "ret-pole-base",
		["ret-signal-pole-placer"] = "ret-signal-pole-base",
		["ret-chain-pole-placer"] = "ret-chain-pole-base"
	}

	local pole = surface.create_entity {
		name = actual_pole[placer_name],
		force = force,
		position = pos,
		direction = fix_pole_build_dir(direction, placer_name)
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
		direction = 2 * math.floor(direction / 2)
	}


	-- this defaults to 40kJ for whatever reason...
	power.electric_buffer_size = config.pole_power_buffer_val


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

function register_locomotive(event)
	local locomotive = event.created_entity
	global.electric_locos[locomotive.unit_number] = locomotive
end

function add_rail(event)
	update_poles_near_rail(event.created_entity)
end

script.on_event({
		defines.events.on_built_entity,
		defines.events.on_robot_built_entity
	},
	function (event)
		local n = event.created_entity.name

		if n == "ret-pole-placer" or
		   n == "ret-signal-pole-placer" or
		   n == "ret-chain-pole-placer" then
				create_pole(event)

		elseif n == "ret-electric-locomotive" then
				register_locomotive(event)

		elseif n == "straight-rail" or n == "curved-rail" then
				add_rail(event)
		end
	end
)

--==============================================================================

-- On remove events

function destroy_pole(event)
	local pole = event.entity

	-- disconnect from neighbours
	uninstall_pole(pole, enable_connect_particles)

	-- remove wire, power and graphic
	local wire = global.wire_for_pole[pole.unit_number]
	if wire then wire.destroy() end
	global.wire_for_pole[pole.unit_number] = nil

	local power = global.power_for_pole[pole.unit_number]
	if power then power.destroy() end
	global.power_for_pole[pole.unit_number] = nil

	local graphic = global.graphic_for_pole[pole.unit_number]
	if graphic then graphic.destroy() end
	global.graphic_for_pole[pole.unit_number] = nil
end

function deregister_locomotive(event)
	global.electric_locos[event.entity.unit_number] = nil
end

function remove_rail(event)
	local power_provider = global.power_for_rail[event.entity.unit_number]
	if power_provider and power_provider.valid then
		unpower_nearby_rails(event.entity)
	end
end

script.on_event({
		defines.events.on_entity_died,
		defines.events.on_pre_player_mined_item,
		defines.events.on_robot_pre_mined
	},
	function (event)
		local n = event.entity.name

		if n == "ret-pole-base" or
		   n == "ret-signal-pole-base" or
		   n == "ret-chain-pole-base" then
				destroy_pole(event)

		elseif n == "ret-electric-locomotive" then
				deregister_locomotive(event)

		elseif n == "straight-rail" or n == "curved-rail" then
				remove_rail(event)
		end
	end
)

--==============================================================================

-- Tick handler

function on_tick(event)

	-- power all trains
	if event.tick % 10 == 0 then
		local dummy_fuel = game.item_prototypes["ret-dummy-fuel-1"]
		
		for _, loco in pairs(global.electric_locos) do
			local burner = loco.burner
			burner.currently_burning = dummy_fuel
			local missing_energy = dummy_fuel.fuel_value - burner.remaining_burning_fuel
			local power_provider = find_power_provider(loco)
			if power_provider then
				local transfer = math.min(missing_energy, 
								 math.min(power_provider.energy, 
								 config.loco_max_energy_transfer_val))
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

script.on_event(defines.events.on_tick, on_tick)


--==============================================================================

-- Replacement scripts for the pole placer

local pole_to_placer = {
	["ret-pole-base"] = "ret-pole-placer",
	["ret-signal-pole-base"] = "ret-signal-pole-placer",
	["ret-chain-pole-base"] = "ret-chain-pole-placer"
}

script.on_event(defines.events.on_player_pipette,
	function(e)
		local replace = pole_to_placer[e.item.name]
		if replace then
			game.players[e.player_index].pipette_entity(replace)
		end
	end
)

script.on_event(defines.events.on_player_setup_blueprint,
	function(e)
		local stack = game.players[e.player_index].blueprint_to_setup
		if stack.name == "blueprint" then
			local entities = stack.get_blueprint_entities()
			local modified = false
			for _, entity in pairs(entities) do
				local replace = pole_to_placer[entity.name]
				if replace then
					modified = true
					entity.direction = fix_pole_dir(entity)
					entity.name = replace
				end
			end
			if modified then
				stack.set_blueprint_entities(entities)
			end
		end
	end
)

--==============================================================================

-- Selection script for the debugger

script.on_event(defines.events.on_player_selected_area,
	function (e)
		if e.item == "ret-pole-debugger" then
			for _, entity in pairs(e.entities) do
				if entity.name == "straight-rail" or entity.name == "curved-rail" then
					local power_provider = global.power_for_rail[entity.unit_number]
					local powered = power_provider and power_provider.valid
					display_powered_state(entity, not powered)
				end
			end 
		end
	end
)
