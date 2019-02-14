--positions.lua

require("util")


do

	local n  = defines.direction.north
	local ne = defines.direction.northeast
	local e  = defines.direction.east
	local se = defines.direction.southeast
	local s  = defines.direction.south
	local sw = defines.direction.southwest
	local w  = defines.direction.west
	local nw = defines.direction.northwest

	local straight = "straight-rail"
	local curved = "curved-rail"

	-- Many, many lookup tables... 

	-- Note that a signal for driving northbound has the direction south

	local pole_to_wire = {
		[n]  = { x =  1.75, y =  0.0  },
		[ne] = { x =  1.25, y =  0.9  },
		[e]  = { x =  0.0,  y =  1.25 },
		[se] = { x = -1.25, y =  0.9  },
		[s]  = { x = -1.75, y =  0.0  },
		[sw] = { x = -1.25, y = -0.9  },
		[w]  = { x =  0.0,  y = -1.25 },
		[nw] = { x =  1.25, y = -0.9  }
	}

	local pole_to_rail = {
		[n] = {
			{x =  1.5, y =  0.5, rail = straight, dir = n},
			{x =  1.5, y = -0.5, rail = straight, dir = n},
			{x =  2.5, y = -3.5, rail = curved,   dir = ne},
			{x =  0.5, y = -3.5, rail = curved,   dir = n},
			{x =  0.5, y =  3.5, rail = curved,   dir = sw},
			{x =  2.5, y =  3.5, rail = curved,   dir = s},
		},
		[ne] = {
			{x =  1.5, y =  1.5, rail = straight, dir = nw},
			{x =  0.5, y =  0.5, rail = straight, dir = se},
			{x = -0.5, y =  3.5, rail = curved,   dir = ne},
			{x = -1.5, y =  2.5, rail = curved,   dir = e},
			{x =  3.5, y = -0.5, rail = curved,   dir = w},
			{x =  2.5, y = -1.5, rail = curved,   dir = sw},
		},
		[e] = {
			{x =  0.5, y =  1.5, rail = straight, dir = e},
			{x = -0.5, y =  1.5, rail = straight, dir = e},
			{x =  3.5, y =  2.5, rail = curved,   dir = se},
			{x =  3.5, y =  0.5, rail = curved,   dir = e},
			{x = -3.5, y =  2.5, rail = curved,   dir = w},
			{x = -3.5, y =  0.5, rail = curved,   dir = nw},
		},
		[se] = {
			{x = -1.5, y =  1.5, rail = straight, dir = ne},
			{x = -0.5, y =  0.5, rail = straight, dir = sw},
			{x =  0.5, y =  3.5, rail = curved,   dir = n},
			{x = -3.5, y = -0.5, rail = curved,   dir = se},
			{x =  1.5, y =  2.5, rail = curved,   dir = nw},
			{x = -2.5, y = -1.5, rail = curved,   dir = s},
		},
		[s] = {
			{x = -1.5, y =  0.5, rail = straight, dir = n},
			{x = -1.5, y = -0.5, rail = straight, dir = n},
			{x = -0.5, y = -3.5, rail = curved,   dir = ne},
			{x = -2.5, y = -3.5, rail = curved,   dir = n},
			{x = -0.5, y =  3.5, rail = curved,   dir = s},
			{x = -2.5, y =  3.5, rail = curved,   dir = sw},
		},
		[sw] = {
			{x = -0.5, y = -0.5, rail = straight, dir = nw},
			{x = -1.5, y = -1.5, rail = straight, dir = se},
			{x = -2.5, y =  1.5, rail = curved,   dir = ne},
			{x = -3.5, y =  0.5, rail = curved,   dir = e},
			{x =  1.5, y = -2.5, rail = curved,   dir = w},
			{x =  0.5, y = -3.5, rail = curved,   dir = sw},
		},
		[w] = {
			{x =  0.5, y = -1.5, rail = straight, dir = e},
			{x = -0.5, y = -1.5, rail = straight, dir = e},
			{x =  3.5, y = -2.5, rail = curved,   dir = e},
			{x =  3.5, y = -0.5, rail = curved,   dir = se},
			{x = -3.5, y = -0.5, rail = curved,   dir = w},
			{x = -3.5, y = -2.5, rail = curved,   dir = nw},
		},
		[nw] = { 
			{x =  0.5, y = -0.5, rail = straight, dir = ne},
			{x =  1.5, y = -1.5, rail = straight, dir = sw},
			{x =  2.5, y =  1.5, rail = curved,   dir = n},
			{x = -1.5, y = -2.5, rail = curved,   dir = se},
			{x =  3.5, y =  0.5, rail = curved,   dir = nw},
			{x = -0.5, y = -3.5, rail = curved,   dir = s},
		}
	}

	local rail_to_pole = {
		[straight] = {
			[n] = {
				{x = -1.5, y =  0.5, dir = n},
				{x = -1.5, y = -0.5, dir = n},
				{x =  1.5, y =  0.5, dir = s},
				{x =  1.5, y = -0.5, dir = s}
			},
			[e] = {
				{x = -0.5, y =  1.5, dir = w},
				{x = -0.5, y = -1.5, dir = e},
				{x =  0.5, y =  1.5, dir = w},
				{x =  0.5, y = -1.5, dir = e}
			},
			[nw] = {
				{x = -1.5, y = -1.5, dir = ne},
				{x =  0.5, y =  0.5, dir = sw}
			},
			[ne] = {
				{x =  1.5, y = -1.5, dir = se},
				{x = -0.5, y =  0.5, dir = nw}
			},
			[se] = {
				{x =  1.5, y =  1.5, dir = sw},
				{x = -0.5, y = -0.5, dir = ne}
			},
			[sw] = {
				{x = -1.5, y =  1.5, dir = nw},
				{x =  0.5, y = -0.5, dir = se}
			}
		},
		[curved] = {
			[n] = {
				{x =  2.5, y =  3.5, dir = s},
				{x = -0.5, y =  3.5, dir = n},
				{x = -0.5, y = -3.5, dir = se},
				{x = -2.5, y = -1.5, dir = nw}
			},
			[ne] = {
				{x = -2.5, y =  3.5, dir = n},
				{x =  0.5, y =  3.5, dir = s},
				{x =  2.5, y = -1.5, dir = sw},
				{x =  0.5, y = -3.5, dir = ne}
			},
			[e] = {
				{x = -3.5, y = -0.5, dir = e},
				{x = -3.5, y =  2.5, dir = w},
				{x =  1.5, y = -2.5, dir = ne},
				{x =  3.5, y = -0.5, dir = sw}
			},
			[se] = {
				{x = -3.5, y = -2.5, dir = e},
				{x = -3.5, y =  0.5, dir = w},
				{x =  3.5, y =  0.5, dir = se},
				{x =  1.5, y =  2.5, dir = nw}
			},
			[s] = {
				{x = -2.5, y = -3.5, dir = n},
				{x =  0.5, y = -3.5, dir = s},
				{x =  2.5, y =  1.5, dir = se},
				{x =  0.5, y =  3.5, dir = nw}
			},
			[sw] = {
				{x =  2.5, y = -3.5, dir = s},
				{x = -0.5, y = -3.5, dir = n},
				{x = -2.5, y =  1.5, dir = ne},
				{x = -0.5, y =  3.5, dir = sw}
			},
			[w] = {
				{x =  3.5, y = -2.5, dir = e},
				{x =  3.5, y =  0.5, dir = w},
				{x = -3.5, y =  0.5, dir = ne},
				{x = -1.5, y =  2.5, dir = sw}
			},
			[nw] = {
				{x =  3.5, y =  2.5, dir = w},
				{x =  3.5, y = -0.5, dir = e},
				{x = -1.5, y = -2.5, dir = se},
				{x = -3.5, y = -0.5, dir = nw}
			}
		}
	}

	local rail_to_rail = {
		[straight] = {
			-- rail rotation north
			[n] = {
				-- driving direction north
				[n] = {
					{x =  0, y = -2, rail = straight, dir = n,  drive = n},
					{x =  1, y = -5, rail = curved,   dir = ne, drive = ne},
					{x = -1, y = -5, rail = curved,   dir = n,  drive = nw}
				},
				-- driving direction south
				[s] = {
					{x =  0, y =  2, rail = straight, dir = n,  drive = s},
					{x =  1, y =  5, rail = curved,   dir = s,  drive = se},
					{x = -1, y =  5, rail = curved,   dir = sw, drive = sw}
				}
			},
			-- rail rotation east
			[e] = {
				-- driving direction east
				[e] = {
					{x =  2, y =  0, rail = straight, dir = e,  drive = e},
					{x =  5, y =  1, rail = curved,   dir = se, drive = se},
					{x =  5, y = -1, rail = curved,   dir = e,  drive = ne}
				},
				-- driving direction west
				[w] = {
					{x = -2, y =  0, rail = straight, dir = e,  drive = w},
					{x = -5, y =  1, rail = curved,   dir = w,  drive = sw},
					{x = -5, y = -1, rail = curved,   dir = nw, drive = nw}
				}
			},
			-- rail rotation northeast
			[ne] = {
				-- driving direction northwest
				[nw] = {
					{x =  0, y = -2, rail = straight, dir = sw, drive = nw},
					{x = -3, y = -3, rail = curved,   dir = se, drive = w}
				}, 
				-- driving direction southeast
				[se] = {
					{x =  2, y =  0, rail = straight, dir = sw, drive = se},
					{x =  3, y =  3, rail = curved,   dir = n,  drive = s}
				}
			},
			-- rail rotation southeast
			[se] = {
				-- driving directio northeast
				[ne] = {
					{x =  2, y =  0, rail = straight, dir = nw, drive = ne},
					{x =  3, y = -3, rail = curved,   dir = sw, drive = n}
				},
				-- driving direction southwest
				[sw] = {
					{x =  0, y =  2, rail = straight, dir = nw, drive = sw},
					{x = -3, y =  3, rail = curved,   dir = e,  drive = w}
				}
			},
			-- rail rotation southwest
			[sw] = {
				-- driving direction northwest
				[nw] = {
					{x = -2, y =  0, rail = straight, dir = ne, drive = nw},
					{x = -3, y = -3, rail = curved,   dir = s,  drive = n}
				},
				-- driving direction southeast
				[se] = {
					{x =  0, y =  2, rail = straight, dir = ne, drive = se},
					{x =  3, y =  3, rail = curved,   dir = nw, drive = e}
				}
			},
			-- rail rotation northwest
			[nw] = {
				-- driving direction northeast
				[ne] = {
					{x =  0, y = -2, rail = straight, dir = se, drive = ne},
					{x =  3, y = -3, rail = curved,   dir = w,  drive = e}
				},
				-- driving direction southwest
				[sw] = {
					{x = -2, y =  0, rail = straight, dir = se, drive = sw},
					{x = -3, y =  3, rail = curved,   dir = ne, drive = s}
				}
			}
		},
		[curved] = {
			-- rail rotation north
			[n] = {
				-- driving direction south
				[s] = {
					{x =  1, y =  5, rail = straight, dir = n,  drive = s},
					{x =  0, y =  8, rail = curved,   dir = sw, drive = sw},
					{x =  2, y =  8, rail = curved,   dir = s,  drive = se}
				},
				-- driving direction northwest
				[nw] = {
					{x = -3, y = -3, rail = straight, dir = ne, drive = nw},
					{x = -4, y = -6, rail = curved,   dir = s,  drive = n}
				}
			},
			-- rail rotation northeast
			[ne] = {
				-- driving direction south
				[s] = {
					{x = -1, y =  5, rail = straight, dir = n,  drive = s},
					{x =  0, y =  8, rail = curved,   dir = s,  drive = se},
					{x = -2, y =  8, rail = curved,   dir = sw, drive = sw}
				},
				-- driving direction northeast
				[ne] = {
					{x =  3, y = -3, rail = straight, dir = nw, drive = ne},
					{x =  4, y = -6, rail = curved,   dir = sw, drive = n}
				}
			},
			-- rail rotation east
			[e] = {
				-- driving direction west
				[w] = {
					{x = -5, y =  1, rail = straight, dir = e,  drive = w},
					{x = -8, y =  0, rail = curved,   dir = nw, drive = nw},
					{x = -8, y =  2, rail = curved,   dir = w,  drive = sw}
				},
				-- driving direction northeast
				[ne] = {
					{x =  3, y = -3, rail = straight, dir = se, drive = ne},
					{x =  6, y = -4, rail = curved,   dir = w,  drive = e}
				}
			},
			-- rail rotation southeast
			[se] = {
				-- driving direction west
				[w] = {
					{x = -5, y = -1, rail = straight, dir = e,  drive = w},
					{x = -8, y =  0, rail = curved,   dir = w,  drive = sw},
					{x = -8, y = -2, rail = curved,   dir = nw, drive = nw}
				},
				-- driving direction southeast
				[se] = {
					{x =  3, y =  3, rail = straight, dir = ne, drive = se},
					{x =  6, y =  4, rail = curved,   dir = nw, drive = e}
				}
			},
			-- rail rotation south
			[s] = {
				-- driving direction north
				[n] = {
					{x = -1, y = -5, rail = straight, dir = n,  drive = n},
					{x =  0, y = -8, rail = curved,   dir = ne, drive = ne},
					{x = -2, y = -8, rail = curved,   dir = n,  drive = nw}
				},
				-- driving direction southeast
				[se] = {
					{x =  3, y =  3, rail = straight, dir = sw, drive = se},
					{x =  4, y =  6, rail = curved,   dir = n,  drive = s}
				}
			},
			-- rail rotation southwest
			[sw] = {
				-- driving direction north
				[n] = {
					{x =  1, y = -5, rail = straight, dir = n,  drive = n},
					{x =  0, y = -8, rail = curved,   dir = n,  drive = nw},
					{x =  2, y = -8, rail = curved,   dir = ne, drive = ne}
				},
				-- driving direction southwest
				[sw] = {
					{x = -3, y =  3, rail = straight, dir = se, drive = sw},
					{x = -4, y =  6, rail = curved,   dir = ne, drive = s}
				}
			},
			-- rail rotation west
			[w] = {
				-- driving direction east
				[e] = {
					{x =  5, y = -1, rail = straight, dir = e,  drive = e},
					{x =  8, y =  0, rail = curved,   dir = se, drive = se},
					{x =  8, y = -2, rail = curved,   dir = e,  drive = ne}
				},
				-- driving direction southwest
				[sw] = {
					{x = -3, y =  3, rail = straight, dir = nw, drive = sw},
					{x = -6, y =  4, rail = curved,   dir = e,  drive = w}
				}
			},
			-- rail rotation northwest
			[nw] = {
				-- straight side
				[e] = {
					{x =  5, y =  1, rail = straight, dir = e,  drive = e},
					{x =  8, y =  0, rail = curved,   dir = e,  drive = ne},
					{x =  8, y =  2, rail = curved,   dir = se, drive = se}
				},
				-- diagonal side
				[nw] = {
					{x = -3, y = -3, rail = straight, dir = sw, drive = nw},
					{x = -6, y = -4, rail = curved,   dir = se, drive = w}
				}
			}
		}
	}

	local driving_dir_for_rail = {
		[straight] = {
			[n] =  {n, s},
			[e] =  {e, w},
			[ne] = {nw, se},
			[se] = {ne, sw},
			[sw] = {nw, se},
			[nw] = {ne, sw}
		},
		[curved] = {
			[n] =  {s, nw},
			[ne] = {s, ne},
			[e] =  {w, ne},
			[se] = {w, se},
			[s] =  {n, se},
			[sw] = {n, sw},
			[w] =  {e, sw},
			[nw] = {e, nw}
		}
	}

	function fix_pole_dir(pole)
		if pole.name == "ret-pole-base" then
			-- in a blueprint, the direction isn't even stored if it is zero.
			if pole.direction then
				return (pole.direction + 2) % 8
			else
				return 2
			end
		else
			return pole.direction
		end
	end

	function fix_pole_build_dir(dir, type)
		if not type or type == "ret-pole-placer" then
			return (dir + 6) % 8
		else
			return dir
		end
	end

	function wire_pos_for_pole(pos, dir)
		local l = pole_to_wire[dir]
		return { x = pos.x + l.x, y = pos.y + l.y }
	end

	function pole_pos_for_rail(rail_type, rail_pos, rail_dir)
		local lookup = table.deepcopy(rail_to_pole[rail_type][rail_dir])
		for _, v in pairs(lookup) do
			v.x = v.x + rail_pos.x
			v.y = v.y + rail_pos.y
		end
		return lookup
	end

	function rail_pos_for_pole(pole_pos, pole_dir)
		local lookup = table.deepcopy(pole_to_rail[pole_dir])
		for _, v in pairs(lookup) do
			v.x = v.x + pole_pos.x
			v.y = v.y + pole_pos.y
		end
		return lookup
	end

	function driving_dirs_for_rail(rail_type, rail_dir)
		return driving_dir_for_rail[rail_type][rail_dir]
	end	

	function rail_pos_for_rail(rail_type, rail_pos, rail_dir, drive_dir)
		local lookup_ref = rail_to_rail[rail_type][rail_dir][drive_dir]
		if lookup_ref == nil then return {} end
		local lookup = table.deepcopy(lookup_ref)
		for _, v in pairs(lookup) do
			v.x = v.x + rail_pos.x
			v.y = v.y + rail_pos.y
		end
		return lookup
	end

	function around_position(pos, d)
		if not d then d = 0.5 end
		return {{pos.x - d, pos.y - d}, {pos.x + d, pos.y + d}}
	end
end
