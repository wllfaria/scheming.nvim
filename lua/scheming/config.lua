---@class SchemingMappings
---@field close string
---@field next string
---@field prev string

---Main configuration for scheming.
---
---* schemes: can either be a list of strings, or a table with
---keys as the scheme names and values as a table of configuration
---
---@class SchemingConfig
---@field layout "float" | "bottom"
---@field mappings SchemingMappings
---@field schemes string[] | table<string, table>
local Config = {}
Config.__index = Config

function Config:with_default()
	---@type SchemingConfig
	local default = {
		layout = "bottom",
		mappings = {
			close = "q",
			next = "<C-n>",
			prev = "<C-p>",
		},
		schemes = {},
	}

	return setmetatable(default, Config)
end

return Config
