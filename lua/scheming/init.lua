local Config = require("scheming.config")

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
			config = Config:with_default(),
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
	self.config:merge(config)
	self.config:create_user_commands()
	return self
end

Scheming.setup({})
vim.keymap.set("n", "<leader>sct", "<cmd>SchemingToggle<CR>", { noremap = true, silent = true })

return Scheming
