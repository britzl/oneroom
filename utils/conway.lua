local M = {}



local function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end


function M.apply(l, W, H)
	local function count_neighbors(x, y)
		local count = 0
		count = count + (l[x-1][y-1].wall and 1 or 0)
		count = count + (l[x+0][y-1].wall and 1 or 0)
		count = count + (l[x+1][y-1].wall and 1 or 0)
		count = count + (l[x-1][y+0].wall and 1 or 0)
		count = count + (l[x+1][y+0].wall and 1 or 0)
		count = count + (l[x-1][y+1].wall and 1 or 0)
		count = count + (l[x+0][y+1].wall and 1 or 0)
		count = count + (l[x+1][y+1].wall and 1 or 0)
		return count
	end

	-- randomly fill parts of the level with walls
	for x=3,W-2 do
		for y=3,H-2 do
			if math.random(1, 10) > 3 then
				l[x][y].wall = true
			end
		end
	end

	-- apply game of life algorithm to evolve level
	for i=1,2 do
		local newl = deepcopy(l)
		for x=2,W-1 do
			for y=2,H-1 do
				local count = count_neighbors(x, y)
				if newl[x][y].wall then
					if count < 2 then
						newl[x][y].wall = true
					elseif count > 3 then
						newl[x][y].wall = false
					end
				else
					if count == 3 then
						newl[x][y].wall = true
					end
				end
			end
		end
		l = newl
	end

	return l
end


return M