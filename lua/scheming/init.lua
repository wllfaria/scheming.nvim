local Config = require("scheming.config")
local Commands = require("scheming.commands")
local View = require("scheming.view")

---@class PartialWindowConfig
---@field height number?
---@field width number?
---@field show_border boolean?
---@field border "single" | "double" | "rounded"?
---@field show_title boolean?
---@field title string?
---@field title_align "left" | "center" | "right"?

---@class PartialConfig
---@field schemes string[] | table<string, table>?
---@field layout "bottom" | "float"?
---@field window PartialWindowConfig?

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

Scheming.setup({
	layout = "bottom",
	schemes = { "radium", "rose-pine" },
	window = {
		height = 8,
		show_border = true,
		border = "single",
	},
})
vim.keymap.set("n", "<leader>sct", "<cmd>SchemingToggle<CR>", { noremap = true, silent = true })

return Scheming
