---@class PartialConfig

---@class SchemingConfig

---@class Scheming
---@field config SchemingConfig
local Scheming = {}
Scheming.__index = Scheming

local scheming = nil

---Returns the current instance of scheming. If no instance
---exists, a new one is created.
---
---@return Scheming
function Scheming:new()
	if not scheming then
		scheming = setmetatable({
			config = {},
		}, Scheming)
	end
	return scheming
end

---Initializes scheming with the given configuration. If no
---configuration is given, the default configuration is used instead.
---
---@param config PartialConfig
---@return Scheming
function Scheming.setup(config)
	local self = Scheming:new()
	self.config = vim.tbl_deep_extend("force", self.config, config)
	return self
end

return Scheming
