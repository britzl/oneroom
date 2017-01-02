local floodfill = require "utils.floodfill"
local conway = require "utils.conway"

local M = {}


local TILES = {
	{ pattern = "WWWWWWWWW", index = 13 },
	
	{ pattern = ".W.WWWFWF", index = 15 },
	{ pattern = ".W.WWWFW.", index = 5 },
	{ pattern = ".W.WWW.WF", index = 25 },
	{ pattern = ".F.WWWFWF", index = 35 },
	{ pattern = ".W.FWWFWF", index = 45 },
	{ pattern = ".W.WWFFW.", index = 55 },
	{ pattern = ".F.WWWWWF", index = 65 },
	{ pattern = ".F.WWWFW.", index = 75 },

	{ pattern = ".F.WWWWWW", index = 3 },	-- bottom wall
	{ pattern = ".W.WWW.F.", index = 23 },	-- top wall
	{ pattern = ".W.FWW.W.", index = 12 },	-- right wall
	{ pattern = ".W.WWFWW.", index = 14 },	-- left wall
	
	{ pattern = ".W.WWWWWW", index = 13 }, -- filled
	
	{ pattern = ".F.FWF.F.", index = 7 }, -- pillar
	
	{ pattern = ".F.FWF.W.", index = 6 }, -- top pillar
	{ pattern = ".W.FWF.F.", index = 26 }, -- bottom pillar
	{ pattern = ".W.FWF.W.", index = 16 }, -- middle pillar
	
	{ pattern = ".F.WWW.F.", index = 33 }, -- horizontal thin wall middle
	{ pattern = ".F.FWW.F.", index = 32 }, -- horizontal thin wall left
	{ pattern = ".F.WWF.F.", index = 34 }, -- horizontal thin wall right
	
	{ pattern = ".F.FWW.WW", index = 2 },	-- inner top left corner
	{ pattern = ".F.WWFWW.", index = 4 },	-- inner top right corner
	{ pattern = ".W.FWW.F.", index = 22 },	-- inner bottom left corner
	{ pattern = ".W.WWF.F.", index = 24 }, -- inner bottom right corner
	
	{ pattern = ".F.FWW.WF", index = 42 },
	{ pattern = ".F.WWFFW.", index = 43 },
}


function M.create(url, W, H, TILE_SIZE)

	local instance = {}

	local seed = socket.gettime()
	
	local tilemap_url = msg.url(url.socket, url.path, "tilemap")

	function instance.clear()
		instance.layout = {}
		local l = instance.layout
		for x=0,W+1 do
			l[x] = {}
			for y=0,H+1 do
				l[x][y] = { wall = false, x = x, y = y }
			end
		end
		for x=0,W+1 do
			l[x][0].wall = true
			l[x][1].wall = true
			l[x][H].wall = true
			l[x][H+1].wall = true
		end
		for y=0,H+1 do
			l[0][y].wall = true
			l[1][y].wall = true
			l[W][y].wall = true
			l[W+1][y].wall = true
		end
	end
	
	function instance.generate()
		instance.clear()
		instance.layout = conway.apply(instance.layout, W, H)
		instance.update_tilemap()
	end

	function instance.update_tilemap()
		local l = instance.layout
		local function get_key(x, y)
			local key = ""
			key = key .. (l[x-1][y+1].wall and "W" or "F")
			key = key .. (l[x+0][y+1].wall and "W" or "F")
			key = key .. (l[x+1][y+1].wall and "W" or "F")
			key = key .. (l[x-1][y+0].wall and "W" or "F")
			key = key .. (l[x+0][y+0].wall and "W" or "F")
			key = key .. (l[x+1][y+0].wall and "W" or "F")
			key = key .. (l[x-1][y-1].wall and "W" or "F")
			key = key .. (l[x+0][y-1].wall and "W" or "F")
			key = key .. (l[x+1][y-1].wall and "W" or "F")
			return key
		end
	
		local function get_wall_tile(key)
			for _,tile in ipairs(TILES) do
				if key:match(tile.pattern) then
					return tile.index
				end
			end
		end
		
		local function get_floor_tile(x, y)
			math.randomseed(seed - x * 1034 - y * 1678)
			return l[x][y].destroyed_wall and math.random(51, 53) or 1
		end
		
		for x=1,W do
			for y=1,H do
				local key = get_key(x, y)
				tilemap.set_tile(tilemap_url, "floor", x, y, get_floor_tile(x, y))
				tilemap.set_tile(tilemap_url, "walls", x, y, get_wall_tile(key) or 0)
			end
		end
	end

	function instance.random_position()
		local l = instance.layout
		local x = 1
		local y = 1
		for i=1,100 do
			x = math.random(2, W - 1)
			y = math.random(2, H - 1)
			if not l[x][y].wall and not l[x][y].spawn then
				break
			end
		end
		local pos = go.get_world_position(url) + vmath.vector3((TILE_SIZE / 2) + ((x - 1) * TILE_SIZE), (TILE_SIZE / 2) + ((y - 1) * TILE_SIZE), 1)
		pos.z = 1
		return x, y, pos
	end
	
	function instance.create_spawn_position()
		local x, y, pos = instance.random_position()
		instance.layout[x][y].spawn = true
		return pos
	end
	
	function instance.destroy(x, y)
		local l = instance.layout
		if x > 1 and x < (W - 0) and y > 1 and y < (H - 0) then
			if l[x][y].wall then
				l[x][y].destroyed_wall = true
				l[x][y].wall = false
				instance.update_tilemap()
			end
		end
	end

	function instance.dump()
		local l = instance.layout
		local s = "\n"
		for y=H,1,-1 do
			s = s .. ("%2.d"):format(y) .. " "
			for x=1,W do
				s = s .. (l[x][y].wall and "W" or "F")
			end
			s  = s .. "\n"
		end
		print(s)
	end
	
	function instance.dumpcost()
		local l = instance.layout
		local s = "\n"
		for y=H,1,-1 do
			s = s .. ("%2.d"):format(y) .. " "
			for x=1,W do
				s = s .. ("[%3.d]"):format(l[x][y].cost or 0)
			end
			s  = s .. "\n"
		end
		print(s)
	end
	
	function instance.vector3_to_xy(v3)
		local pos = go.get_world_position(url)
		local delta = v3 - pos
		local x = 1 + math.floor(delta.x / TILE_SIZE)
		local y = 1 + math.floor(delta.y / TILE_SIZE)
		return x, y
	end
	
	function instance.xy_to_vector3(x, y, z)
		--return go.get_world_position(url) + vmath.vector3((x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, z or 0)
		return go.get_world_position(url) + vmath.vector3((TILE_SIZE / 2) + ((x - 1) * TILE_SIZE), (TILE_SIZE / 2) + ((y - 1) * TILE_SIZE), z or 0)
	end

	function instance.lowestcost(x, y)
		local l = instance.layout
		local current = l[x][y]
		local n = l[x][y + 1]
		local s = l[x][y - 1]
		local e = l[x + 1][y]
		local w = l[x - 1][y]
		local nodes = {
			current, n, s, e, w
		}
		local lowest_cost = nil
		for _,node in pairs(nodes) do
			if not lowest_cost or lowest_cost.cost > node.cost then
				lowest_cost = node
			end
		end
		return lowest_cost
	end
	
	instance.clear()
	
	M.current = instance
	
	return instance
end


return M