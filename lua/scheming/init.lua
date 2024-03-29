local Config = require("scheming.config")
local Commands = require("scheming.commands")
local View = require("scheming.view")
local Loader = require("scheming.loader")
local Fs = require("scheming.fs")

---@class PartialWindowConfig
---@field height number?
---@field width number?
---@field show_border boolean?
---@field border "single" | "double" | "rounded"?
---@field show_title boolean?
---@field title string?
---@field title_align "left" | "center" | "right"?

---@class PartialMappings
---@field cancel string[]?
---@field select string[]?
---@field toggle string[]?

---@class PartialConfig
---@field schemes string[] | table | SchemeConfig
---@field layout "bottom" | "float"?
---@field window PartialWindowConfig?
---@field enable_preview boolean?
---@field mappings PartialMappings?
---@field sorting SchemingSorting?
---@field override_hl table<string, vim.api.keyset.highlight>?

---@class Scheming
---@field config SchemingConfig
---@field commands SchemingCommands
---@field view SchemingView
---@field loader SchemingLoader
---@field fs SchemingFs
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
			loader = Loader:new(),
			fs = Fs:new(),
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
	self.commands:create_global_keymaps()
	local scheme_config = self.fs:config_read()
	local scheme_name = scheme_config.config.package_name and scheme_config.config.package_name or scheme_config.scheme
	self.loader:setup_scheme(scheme_name, scheme_config.config)
	self.loader:apply_scheme(scheme_config.scheme)
	self.loader:apply_override_hl()
	return self
end

return Scheming
