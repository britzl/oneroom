local M = {}

local timers = {}

local function url_to_key(url)
	return (url.socket or "") .. hash_to_hex(url.path or hash("")) .. hash_to_hex(url.fragment or hash(""))
end

function M.once(seconds, callback)
	local key = url_to_key(msg.url())
	timers[key] = timers[key] or {}
	table.insert(timers[key], timer.delay(seconds, false, callback))
end


function M.every(seconds, callback)
	local key = url_to_key(msg.url())
	timers[key] = timers[key] or {}
	table.insert(timers[key], timer.delay(seconds, true, callback))
end

function M.stop()
	local key = url_to_key(msg.url())
	timers[key] = timers[key] or {}
	while #timers[key] > 0 do
		timer.cancel(table.remove(timers[key]))
	end
end

return M