local M = {}

function M.create(factory_url, max)
	local instance = {}

	local pool = {}

	function instance.spawn(position, rotation, scale, properties)
		if #pool == max then
			pcall(go.delete, table.remove(pool, 1))
		end
		local id = factory.create(factory_url, position, rotation, properties or {}, scale)
		pool[#pool + 1] = id
	end

	function instance.delete(id)
		for i=1,#pool do
			if pool[i] == id then
				pcall(go.delete, table.remove(pool, i))
				return
			end
		end
	end

	function instance.delete_all()
		while #pool > 0 do
			pcall(go.delete, table.remove(pool))
		end
	end

	return instance
end


return M