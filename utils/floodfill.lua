local M = {}



local INF = 1 / 0

function M.fill(x, y, map)
	local from = map[x][y]
	local nodes = {}
	for x=1,#map do
		for y=1,#map[x] do
			local node = map[x][y]
			nodes[#nodes + 1] = node
			node.cost = node.wall and INF or -1
		end
	end
	from.cost = 1

	local visited = {}
	local check = { from }
	while #check > 0 do
		local node = table.remove(check, 1)
		local n = map[node.x][node.y + 1]
		local s = map[node.x][node.y - 1]
		local e = map[node.x + 1][node.y]
		local w = map[node.x - 1][node.y]
		if n.cost == -1 then
			n.cost = node.cost + 1
			table.insert(check, n)
		end
		if s.cost == -1 then
			s.cost = node.cost + 1
			table.insert(check, s)
		end
		if e.cost == -1 then
			e.cost = node.cost + 1
			table.insert(check, e)
		end
		if w.cost == -1 then
			w.cost = node.cost + 1
			table.insert(check, w)
		end
	end
end

return M