--rail_search.lua

require("positions")

-- Finds rails adjacent to the given pole_position, which is treated
-- as a signal for the given driving direction when determining
-- position offsets. Rotation_fix is what was applied to shift entity rotation
-- to driving direction. It's negative will be used for the shift from driving-
-- to entity direction.
function find_rails(pole)
	local positions = rail_pos_for_pole(pole.position, fix_pole_dir(pole))

	local results = {}
	for _, pos in pairs(positions) do
		local entities = pole.surface.find_entities(around_position(pos))

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

	local results = {}
	for _, pos in pairs(positions) do
		local entities = rail.surface.find_entities(around_position(pos))

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
	["ret-pole-base"] = true,
	["ret-signal-pole-base"] = true,
	["ret-chain-pole-base"] = true
}

-- Finds poles adjacent to the given rail.
function find_poles(rail)
	local positions = pole_pos_for_rail(rail.name, rail.position, rail.direction)

	local results = {}
	for _, pos in pairs(positions) do
		local entities = rail.surface.find_entities(around_position(pos))

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


function check_curve_policy(start_pole, find_result)
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
				if util.distance(start_pole.position, path[2].position) <
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
				if straight_count_before + straight_count_after < 8 then
					return { fail = true, curve = curve }
				else
					return {}
				end
		end
	end
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

	local start_direction = fix_pole_dir(start_pole)
	local start_position = start_pole.position

	-- find rails immediately adjacent to the pole
	local begin = find_rails(start_pole)

	-- setup lists used in the search process
	local results = {}
	local check_list = {}
	local known_rails = {}
	local known_poles = {[start_pole.unit_number] = true}
	for _, rail in pairs(begin) do
		known_rails[rail.unit_number] = true
		for _, dir in pairs(driving_dirs_for_rail(rail.name, rail.direction)) do
			table.insert(check_list, {rail = rail, drive = dir, path = {rail}})
		end
	end
	if ignore then
		known_poles[ignore.unit_number] = true
	end
	
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
					table.insert(results, { pole = pole, path = table.deepcopy(check.path)})
					known_poles[pole.unit_number] = true
				end
			end
		end

		if search_adjacent and 
		   util.distance(start_position, check.rail.position) <= max_distance + max_pole_search_distance and
		   #check.path * 2 <= max_distance + max_pole_search_distance then
				-- find adjacent rails and add them to the check_list
				local rails = find_adjacent_rails(check.rail, check.drive)
				for _, adjacent in pairs(rails) do
					local rail = adjacent.rail
					if not known_rails[rail.unit_number] then
						local drive = adjacent.drive
						local path = table.deepcopy(check.path)
						table.insert(path, rail)
						table.insert(check_list, 
									 {rail = rail, drive = drive, path = path})
						known_rails[rail.unit_number] = true
					end
				end
		end

		table.remove(check_list, 1)
	end

	-- do sanity checks and sort by success and failure
	local success = {}
	local failure = {}

	local start_wire = global.wire_for_pole[start_pole.unit_number]

	for _, result in pairs(results) do
		local successful = true

		-- check if path contains curves that are too far away from poles
		local curve_check = check_curve_policy(start_pole, result)
		if not curve_check.pass then
			successful = false
			if curve_check.fail then
				table.insert(failure, {pole = result.pole, path = result.path, curve = curve_check.curve})
			end
		end

		-- check actual distance between pole wires
		local target_wire = global.wire_for_pole[result.pole.unit_number]

		if successful and util.distance(start_wire.position, target_wire.position) > max_distance then
			table.insert(failure, {pole = result.pole, path = result.path, curve = nil})
			successful = false
		end

		if successful then
			table.insert(success, {pole = result.pole, path = result.path})
		end
	end

	return {success = success, failure = failure}
end
