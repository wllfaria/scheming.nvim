local Config = require("scheming.config")
local Commands = require("scheming.commands")
local View = require("scheming.view")

---@class PartialConfig

---@class SchemingConfig

---@class Scheming
---@field config SchemingConfig
---@field commands SchemingCommands
local Scheming = {}
Scheming.__index = Scheming

local instance = nil

---Returns the current instance of scheming. If no instance
---exists, a new one is created.
---
---@return Scheming
function Scheming:new()
	if not instance then
		instance = setmetatable({
			config = Config:with_default(),
			commands = Commands:new(),
			view = View:new(),
		}, Scheming)
	end
	return instance
end

---Initializes scheming with the given configuration. If no
---configuration is given, the default configuration is used instead.
---
---@param config PartialConfig
---@return Scheming
function Scheming.setup(config)
	local self = Scheming:new()
	self.config:merge(config)
	self.commands:create_user_commands()
	return self
end

Scheming.setup({})
vim.keymap.set("n", "<leader>sct", "<cmd>SchemingToggle<CR>", { noremap = true, silent = true })

return Scheming
