---@class Logger
---@field file_path string
local Logger = {}
Logger.__index = Logger

local instance = nil

function Logger:new()
	if not instance then
		---@type Logger
		local default = {
			file_path = vim.fn.stdpath("data") .. "/scheming.log",
		}
		instance = setmetatable(default, self)
	end
	return instance
end

function Logger:log(message)
	local message_with_time = "- " .. os.date("%Y-%m-%d %H:%M:%S") .. ": " .. message
	local file = io.open(self.file_path, "a")
	if file then
		file:write(message_with_time .. "\n")
		file:close()
	end
end

function Logger:info(message)
	self:log("[INFO] " .. message)
end

function Logger:error(message)
	self:log("[ERROR] " .. message)
end

function Logger:debug(message)
	self:log("[DEBUG] " .. message)
end

return Logger
