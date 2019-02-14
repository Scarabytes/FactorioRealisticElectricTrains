--copy_prototype.lua

function copy_prototype(type, name, new_name)
	if not data.raw[type][name] then 
		error("Prototype "..type..":"..name.." doesn't exist") 
	end

	local p = table.deepcopy(data.raw[type][name])
	p.name = new_name

	if p.minable and p.minable.result then
		p.minable.result = new_name
	end

	if p.place_result then
		p.place_result = new_name
	end

	if p.result then
		p.result = new_name
	end

	if p.results then
		for _,result in pairs(p.results) do
			if result.name == name then
				result.name = new_name
			end
		end
	end

	return p
end