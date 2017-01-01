local M = {}

local SMALL = hash("explosion_small")
local LARGE = hash("explosion_large")


function M.create(position, type)
	return factory.create("game#explosionfactory", position, nil, { type = type })
end


function M.small(position)
	return factory.create("game:/game#explosionfactory", position, nil, { type = SMALL })
end

function M.large(position)
	return factory.create("game:/game#explosionfactory", position, nil, { type = LARGE })
end


return M