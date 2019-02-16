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

enable_connect_particles = settings.global["ret-enable-connect-particles"].value
enable_failure_text = settings.global["ret-enable-failure-text"].value
enable_zigzag_wire = settings.global["ret-enable-zigzag-wire"].value
enable_zigzag_vertical_only = settings.global["ret-enable-zigzag-vertical-only"].value
enable_circuit_wire = settings.global["ret-enable-circuit-wire"].value
enable_rewire_neighbours = settings.global["ret-enable-rewire-neighbours"].value
max_pole_search_distance = settings.global["ret-max-pole-search-distance"].value

function cache_settings()
	enable_connect_particles = settings.global["ret-enable-connect-particles"].value
	enable_failure_text = settings.global["ret-enable-failure-text"].value
	enable_zigzag_wire = settings.global["ret-enable-zigzag-wire"].value
	enable_zigzag_vertical_only = settings.global["ret-enable-zigzag-vertical-only"].value
	enable_circuit_wire = settings.global["ret-enable-circuit-wire"].value
	enable_rewire_neighbours = settings.global["ret-enable-rewire-neighbours"].value
	max_pole_search_distance = settings.global["ret-max-pole-search-distance"].value
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

	local actual_pole = {
		["ret-pole-placer"] = "ret-pole-base",
		["ret-signal-pole-placer"] = "ret-signal-pole-base",
		["ret-chain-pole-placer"] = "ret-chain-pole-base"
	}

	local pole_name, pole_direction = fix_pole_build_name_and_dir(
	                                    actual_pole[placer_name], direction)

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

		if n == "ret-pole-base-straight" or
		   n == "ret-pole-base-diagonal" or
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

do

	local dummy_fuel
	local dummy_fuel_value
	local max_transfer = config.loco_max_energy_transfer_val

	function on_tick(event)

		if event.tick % 10 == 0 then

			if not dummy_fuel then
				dummy_fuel = game.item_prototypes["ret-dummy-fuel-1"]
				dummy_fuel_value = dummy_fuel.fuel_value
			end

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

script.on_event(defines.events.on_tick, on_tick)


--==============================================================================

-- Replacement scripts for the pole placer

local valid_poles = {
	["ret-pole-base-straight"] = true,
	["ret-pole-base-diagonal"] = true,
	["ret-signal-pole-base"] = true,
	["ret-chain-pole-base"] = true
}

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
				if valid_poles[entity.name] then
					local entity_name, entity_direction = fix_pole_name_and_dir(entity)
					modified = true
					entity.direction = entity_direction
					entity.name = pole_to_placer[entity_name]
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

--==============================================================================

-- Commands

commands.add_command("print_electric_train_count", 
	"Prints how many electric trains are currently registered in the Realistic Electric Trains mod.",
	function()
		local count = 0
		for _, _ in pairs(global.electric_locos) do
			count = count + 1
		end
		game.print(string.format("Total Trains: %d", count))
	end
)
