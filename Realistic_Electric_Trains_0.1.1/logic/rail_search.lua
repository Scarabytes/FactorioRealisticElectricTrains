--rail_search.lua

require("positions")

-- Finds rails adjacent to the given pole_position, which is treated
-- as a signal for the given driving direction when determining
-- position offsets. Rotation_fix is what was applied to shift entity rotation
-- to driving direction. It's negative will be used for the shift from driving-
-- to entity direction.
function find_rails(pole)
	local positions = rail_pos_for_pole(pole.position, fix_pole_dir(pole))
	local entities = pole.surface.find_entities(around_position(pole.position, 4))

	local results = {}
	for _, pos in pairs(positions) do
		for _, entity in pairs(entities) do
			if entity.name == pos.rail and
			   entity.position.x == pos.x and
			   entity.position.y == pos.y and
			   entity.direction == pos.dir then
					table.insert(results, entity)
			end
		end	
	end
	return results
end

-- Finds rails connected to the given rail
function find_adjacent_rails(rail, driving_direction)
	local positions = rail_pos_for_rail(rail.name, rail.position, 
										rail.direction, driving_direction)
	local entities = rail.surface.find_entities(
										around_position(rail.position, 5.5))

	local results = {}
	for _, pos in pairs(positions) do
		for _, entity in pairs(entities) do
			if entity.name == pos.rail and
			   entity.position.x == pos.x and
			   entity.position.y == pos.y and
			   entity.direction == pos.dir then
					table.insert(results, {rail = entity, drive = pos.drive})
			end
		end
	end
	return results
end


local valid_names = {
	["ret-pole-base-straight"] = true,
	["ret-pole-base-diagonal"] = true,
	["ret-signal-pole-base"] = true,
	["ret-chain-pole-base"] = true
}

-- Finds poles adjacent to the given rail.
function find_poles(rail)
	local positions = pole_pos_for_rail(rail.name, rail.position, rail.direction)
	local entities = rail.surface.find_entities(around_position(rail.position, 4))

	local results = {}
	for _, pos in pairs(positions) do
		for _, entity in pairs(entities) do
			if valid_names[entity.name] and
			   entity.position.x == pos.x and
			   entity.position.y == pos.y and
			   fix_pole_dir(entity) == pos.dir then
					table.insert(results, entity)
			end
		end
	end
	return results
end

-- Checks whether a result of a pole search has the poles close enough to any
-- curves in the path.
function check_curve_policy(start_position, find_result)
	local end_pole = find_result.pole
	local path = find_result.path

	-- fast-return short paths, which include S-curves
	if #path <= 2 then return { pass=true } end

	local status = 0
	local straight_count_before = 0
	local curve = nil
	local straight_count_after = 0

	for k, rail in ipairs(path) do
		if status == 0 then
			-- first rail to be examined
			if rail.name == "straight-rail" then
				if rail.direction % 2 == 0 then
					straight_count_before = straight_count_before + 1
				else
					-- diagonal rails aren't as long as straight rails
					straight_count_before = straight_count_before + 0.5
				end
				status = 1
			else
				if util.distance(start_position, path[2].position) <
					util.distance(rail.position, path[2].position) then
					-- curve is not significant
					straight_count_before = straight_count_before + 0.5
					status = 1
				else
					curve = rail
					status = 2
				end
			end
		elseif status == 1 then
			-- waiting for first curve
			if rail.name == "straight-rail" then
				if rail.direction % 2 == 0 then
					straight_count_before = straight_count_before + 1
				else
					-- diagonal rails aren't as long as straight rails
					straight_count_before = straight_count_before + 0.5
				end
			else
				if k ~= #path or 
					util.distance(end_pole.position, path[#path - 1].position) >=
					util.distance(rail.position, path[#path - 1].position) then
						-- only if curve is significant
						curve = rail
						status = 2
				end
			end
		elseif status == 2 then
			-- after the first curve
			if rail.name == "straight-rail" then
				if rail.direction % 2 == 0 then
					straight_count_after = straight_count_after + 1
				else
					-- diagonal rails aren't as long as straight rails
					straight_count_after = straight_count_after + 0.5
				end
			else
				if k == #path and 
					util.distance(end_pole.position, path[#path - 1].position) <
					util.distance(rail.position, path[#path - 1].position) then
					-- curve is not significant
					straight_count_after = straight_count_after + 0.5
				else
					return { fail = true, curve = curve }
				end
			end
		end
	end

	if status < 2 then 
		return { pass = true }
	else
		if straight_count_before + straight_count_after <= 2 and
			straight_count_before <= 1 and straight_count_after <= 1 then
				return { pass = true }
		else
				-- ignore test when it is obvious that the poles weren't meant
				-- to connect anyway
				if straight_count_before + straight_count_after < 4 then
					return { fail = true, curve = curve }
				else
					return {}
				end
		end
	end
end

-- Executes the search for poles along a rail path.
function run_search_for_poles(start_position, check_list, known_poles, known_rails, max_distance, no_sanity_check)
	local results = {}

	local begin = #check_list

	-- loop until the check_list is empty
	while #check_list > 0 do
		local check = check_list[1]

		-- check for poles at this position
		local poles = find_poles(check.rail)
		local search_adjacent = true

		if #poles > 0 then
			-- poles found here. If any of them are new, this branch
			-- is done searching
			for _, pole in pairs(poles) do
				if not known_poles[pole.unit_number] then
					search_adjacent = false
					table.insert(results, { pole = pole, 
							path = table.deepcopy(check.path), 
							has_curve = check.has_curve})
					known_poles[pole.unit_number] = true
				end
			end
		end

		if begin > 0 then
			search_adjacent = true
		end
		begin = begin - 1

		if search_adjacent and 
		   util.distance(start_position, check.rail.position) <= max_distance + max_pole_search_distance and
		   #check.path * 1.4 <= max_distance + max_pole_search_distance then
				-- find adjacent rails and add them to the check_list
				local rails = find_adjacent_rails(check.rail, check.drive)
				for _, adjacent in pairs(rails) do
					local rail = adjacent.rail
					if not known_rails[rail.unit_number] then
						local is_curve = rail.name == "curved-rail"
						local drive = adjacent.drive
						local path = table.deepcopy(check.path)
						table.insert(path, rail)
						table.insert(check_list, 
									 {rail = rail, drive = drive, path = path,
									 has_curve = check.has_curve or is_curve})
						known_rails[rail.unit_number] = true
					end
				end
		end

		table.remove(check_list, 1)
	end

	-- do sanity checks and sort by success and failure
	local success = {}
	local failure = {}

	for _, result in pairs(results) do
		local successful = true

		if not no_sanity_check then
			-- check if path contains curves that are too far away from poles
			if result.has_curve then
				local curve_check = check_curve_policy(start_position, result)
				if not curve_check.pass then
					successful = false
					if curve_check.fail then
						table.insert(failure, {pole = result.pole, path = result.path, curve = curve_check.curve})
					end
				end
			end

			-- check actual distance between pole wires
			local target_wire = global.wire_for_pole[result.pole.unit_number]

			if successful and util.distance(start_position, target_wire.position) > max_distance + 0.2 then
				table.insert(failure, {pole = result.pole, path = result.path, curve = nil})
				successful = false
			end
		end

		if successful then
			table.insert(success, {pole = result.pole, path = result.path, 
									has_curve = result.has_curve})
		end
	end

	return {success = success, failure = failure}
end

-- Searches along the rail in all possible directions for an overhead
-- line pole, starting from the given one. Returns a table of two
-- lists, one for successes and one for failures.
-- A failure occurs if the distance is a few tiles too long (further
-- distances are not reported at all) or a curve in the path forces
-- the poles to be closer together.
--
-- The "success" list contains results of the following structure:
-- {
--   pole = The pole that was reached within the distance limit	
--   path = All rails that lead to the pole
-- }
-- The "failure" list contains results of the following structure:
-- {
--   pole = A found pole that couldn't be reached
--	 path = All rails that were checked
--   curve = A curved rail that was too far away from the poles or
--           nil if the failure was caused by linear pole distance
-- } 
function search_next_poles(start_pole, max_distance, ignore)
	-- setup utility references
	local surface = start_pole.surface

	local start_position = global.wire_for_pole[start_pole.unit_number].position

	-- find rails immediately adjacent to the pole
	local begin = find_rails(start_pole)

	-- setup lists used in the search process
	local check_list = {}
	local known_rails = {}
	local known_poles = {[start_pole.unit_number] = true}
	for _, rail in pairs(begin) do
		local has_curve = rail.name == "curved-rail"
		known_rails[rail.unit_number] = true
		for _, dir in pairs(driving_dirs_for_rail(rail.name, rail.direction)) do
			table.insert(check_list, {rail = rail, drive = dir, path = {rail}, has_curve = has_curve})
		end
	end
	if ignore then
		if ignore.name == "straight-rail" or ignore.name == "curved-rail" then
			known_rails[ignore.unit_number] = true
		else
			known_poles[ignore.unit_number] = true
		end
	end
	
	return run_search_for_poles(start_position, check_list, known_poles, 
		known_rails, max_distance)
end

-- Similar to search_next_poles, but starts from a rail and does not do any
-- sanity checks
function search_nearby_poles(start_rail, max_distance)
	local check_list = {}
	local known_rails = {[start_rail.unit_number] = true}
	local known_poles = {}
	for _, dir in pairs(driving_dirs_for_rail(start_rail.name, start_rail.direction)) do
		local has_curve = start_rail.name == "curved-rail"
		table.insert(check_list, {rail = start_rail, drive = dir, path = {start_rail}, has_curve = has_curve})
	end

	return run_search_for_poles(start_rail.position, check_list, known_poles, 
		known_rails, max_distance, true)
end
