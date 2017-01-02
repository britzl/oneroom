-- ======================================================================
-- Copyright (c) 2012 RapidFire Studio Limited 
-- All Rights Reserved. 
-- http://www.rapidfirestudio.com

-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:

-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ======================================================================


local M = {}

----------------------------------------------------------------
-- local variables
----------------------------------------------------------------

local INF = 1/0
local cachedPaths = nil

----------------------------------------------------------------
-- local functions
----------------------------------------------------------------

local function dist(x1, y1, x2, y2)
	return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
end

local function dist_between(nodeA, nodeB)
	return dist(nodeA.x, nodeA.y, nodeB.x, nodeB.y)
end

local function heuristic_cost_estimate(nodeA, nodeB)
	return dist(nodeA.x, nodeA.y, nodeB.x, nodeB.y)
end

local function lowest_f_score(set, f_score)
	local lowest, bestNode = INF, nil
	for _, node in ipairs(set) do
		local score = f_score[node]
		if score < lowest then
			lowest, bestNode = score, node
		end
	end
	return bestNode
end

local function neighbor_nodes(theNode, nodes, valid_node_fn)
	local neighbors = {}
	for _, node in ipairs(nodes) do
		if theNode ~= node and valid_node_fn(theNode, node) then
			table.insert(neighbors, node)
		end
	end
	return neighbors
end

local function not_in(set, theNode)
	for _, node in ipairs(set) do
		if node == theNode then return false end
	end
	return true
end

local function remove_node(set, theNode)
	for i, node in ipairs(set) do
		if node == theNode then 
			set[i] = set[#set]
			set[#set] = nil
			break
		end
	end	
end

local function unwind_path(flat_path, map, current_node)
	if map[current_node] then
		table.insert(flat_path, 1, map[current_node]) 
		return unwind_path(flat_path, map, map[current_node])
	else
		return flat_path
	end
end

----------------------------------------------------------------
-- pathfinding functions
----------------------------------------------------------------

local function a_star(start, goal, nodes, valid_node_fn)
	assert(start)
	assert(goal)
	assert(nodes)
	assert(valid_node_fn)
	local closedset = {}
	local openset = { start }
	local came_from = {}

	local g_score, f_score = {}, {}
	g_score[start] = 0
	f_score[start] = g_score[start] + heuristic_cost_estimate(start, goal)

	while #openset > 0 do
		local current = lowest_f_score(openset, f_score)
		if current == goal then
			local path = unwind_path({}, came_from, goal)
			table.insert(path, goal)
			return path
		end

		remove_node(openset, current)
		table.insert(closedset, current)
		
		local neighbors = neighbor_nodes(current, nodes, valid_node_fn)
		for _, neighbor in ipairs(neighbors) do 
			-- ignore the neighbor which is already evaluated.
			if not_in(closedset, neighbor) then
				-- the distance from start to a neighbor
				local tentative_g_score = g_score[current] + dist_between(current, neighbor)
				 
				local new_node = not_in(openset, neighbor)
				if new_node or tentative_g_score < g_score[neighbor] then 
					-- this path is the best until now. Record it!
					came_from[neighbor] = current
					g_score[ neighbor] = tentative_g_score
					f_score[ neighbor] = g_score[neighbor] + heuristic_cost_estimate(neighbor, goal)
					
					-- discover a new node
					if new_node then
						table.insert(openset, neighbor)
					end
				end
			end
		end
	end
	return nil -- no valid path
end

----------------------------------------------------------------
-- exposed functions
----------------------------------------------------------------

function M.clear_cached_paths ()
	cachedPaths = nil
end

function M.distance(x1, y1, x2, y2)
	return dist(x1, y1, x2, y2)
end

function M.path(start, goal, nodes, ignore_cache, valid_node_func)
	cachedPaths = cachedPaths or {}
	if not cachedPaths[start] then
		cachedPaths[start] = {}
	elseif cachedPaths[start][goal] and not ignore_cache then
		return cachedPaths[start][goal]
	end
	
	return a_star(start, goal, nodes, valid_node_func)
end


return M
