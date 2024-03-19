---@class SchemingMappings
---@field cancel string[]
---@field select string[]
---@field toggle string[]

---@class SchemingWindowConfig
---@field height number
---@field width number
---@field show_border boolean
---@field border "single" | "double" | "rounded"
---@field show_title boolean
---@field title string
---@field title_align "left" | "center" | "right"

---@class SchemeConfig
---@field package_name string?
---@field tag string?
---@field config table

---Main configuration for scheming.
---
---* schemes: can either be a list of strings, or a table with
---keys as the scheme names and values as a table of configuration
---
---@class SchemingConfig
---@field layout "float" | "bottom"
---@field mappings SchemingMappings
---@field schemes string[] | table | SchemeConfig
---@field window SchemingWindowConfig
---@field enable_preview boolean
---@field persist_scheme boolean
local Config = {}
Config.__index = Config

local instance = nil

---Create a new instance of SchemingConfig with default values.
---This should only be used by Scheming main package, to get
---to get the current configuration use:
---```lua
---Config:get()
---```
---
---@return SchemingConfig
function Config:with_default()
	---@type SchemingConfig
	local default = {
		layout = "bottom",
		enable_preview = true,
		persist_scheme = true,
		window = {
			height = 12,
			width = 80,
			show_border = true,
			border = "single",
			show_title = true,
			title = "Scheming",
			title_align = "center",
		},
		mappings = {
			cancel = { "q", "<C-c>" },
			select = { "<CR>" },
			toggle = {},
		},
		schemes = {},
	}
	instance = setmetatable(default, Config)
	return instance
end

---Get the current configuration values.
---
---@return SchemingConfig
function Config:get()
	if not instance then
		instance = Config:with_default()
	end
	return instance
end

function Config:merge(config)
	for k, v in pairs(config) do
		if type(v) == "table" and type(self[k]) == "table" then
			self[k] = vim.tbl_deep_extend("force", self[k], v)
		else
			self[k] = v
		end
	end
end

return Config
