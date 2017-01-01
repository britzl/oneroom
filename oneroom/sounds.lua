local M = {}

function M.no_ammo()
	msg.post("game:/sounds#noammo", "play_sound")
end

function M.fire_bullet()
	msg.post("game:/sounds#fire", "play_sound")
end

function M.pickup()
	msg.post("game:/sounds#pickup", "play_sound")
end

function M.explosion()
	msg.post("game:/sounds#explosion", "play_sound")
end




return M