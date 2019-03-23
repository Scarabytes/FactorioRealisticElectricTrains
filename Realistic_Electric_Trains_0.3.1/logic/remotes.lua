--remotes.lua
-- Registers remote calls for other mods to use


-- This function adds the given locomotive to the list of locomotives that will
-- be updated and sets the given fuel information for it. This also sets the
-- given fuel item as the currently burning item.
--
-- `locomotive` is the locomotive entity that should be registered
-- `fuel_info` is a table with the following contents:
--     `item` is an item prototype that will be used as the fuel item
--     `power` is a multiplier for the power consumption. Defaults to 1. This is
--         only applied to the amount of power taken from the grid and has no
--         effect on the rate the fuel item is consumed.
--     `transfer` is a number defining the maximum energy transfered each update
--         cycle. You can calculate it as follows:
--         transfer = loco_max_energy / burner_effectivity * ticks_per_update * power_factor (* 1.05)
--         power_factor is the same as the power field of this table. loco_max_energy
--         and burner_effectivity depend on the locomotive prototype.
function register_locomotive(locomotive, fuel_info)
	if not locomotive or not fuel_info then error("register_locomotive called with nil arguments") end
	if not fuel_info.item or not fuel_info.transfer then error("register_locomotive called with invalid fuel_info") end
	if not fuel_info.power then fuel_info.power = 1 end

	locomotive.burner.currently_burning = fuel_info.item
	table.insert(global.electric_locos, locomotive)
	global.fuel_for_loco[locomotive.unit_number] = fuel_info
end


-- Removes the given locomotive from the list of locomotives that will be 
-- updated. This should be used before a locomotive is deleted using destroy().
function unregister_locomotive(locomotive)
	local id = locomotive.unit_number
	for n, loco in ipairs(global.electric_locos) do
		if loco.unit_number == id then
			table.remove(global.electric_locos, n)
			break
		end
	end
	global.fuel_for_loco[locomotive.unit_number] = nil
end


-- Returns the length of an update cycle in ticks, as it is set in the mod 
-- settings.
function get_ticks_per_update()
	return ticks_per_update
end


remote.add_interface("realistic_electric_trains",
{
	register_locomotive = register_locomotive,
	unregister_locomotive = unregister_locomotive,
	get_ticks_per_update = get_ticks_per_update
})
