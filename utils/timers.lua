local timer = require "ludobits.m.timer"

local M = {}

local timers = {}

local function url_to_key(url)
	return (url.socket or "") .. hash_to_hex(url.path or hash("")) .. hash_to_hex(url.fragment or hash(""))
end

function M.once(seconds, callback)
	local key = url_to_key(msg.url())
	timers[key] = timers[key] or {}
	table.insert(timers[key], timer.once(seconds, callback))
end


function M.every(seconds, callback)
	local key = url_to_key(msg.url())
	timers[key] = timers[key] or {}
	table.insert(timers[key], timer.every(seconds, callback))
end

function M.stop()
	local key = url_to_key(msg.url())
	timers[key] = {}
end

function M.update(dt)
	local key = url_to_key(msg.url())
	if not timers[key] then
		return
	end
	
	for _,t in pairs(timers[key]) do
		t.update(dt)
	end
end

return M