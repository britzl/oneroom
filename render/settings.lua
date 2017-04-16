local M = {}

M.ZOOM = 3
M.MAP_WIDTH = 1280
M.MAP_HEIGHT = 1280

M.ORIGINAL_WIDTH = tonumber(sys.get_config("display.width"))
M.ORIGINAL_HEIGHT = tonumber(sys.get_config("display.height"))

M.CURRENT_WIDTH = M.ORIGINAL_WIDTH
M.CURRENT_HEIGHT = M.ORIGINAL_HEIGHT

if window then
	window.set_listener(function(self, event, data)
		if event == window.WINDOW_EVENT_RESIZED then
			M.CURRENT_WIDTH = data.width
			M.CURRENT_HEIGHT = data.height
		end
	end)
end

return M