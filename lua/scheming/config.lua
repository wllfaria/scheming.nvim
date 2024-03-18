local View = require("scheming.view")

---@class SchemingMappings
---@field cancel string[] @field next string[]
---@field prev string[]
---@field select string[]

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
			cancel = { "q", "<C-c>" },
			next = { "<C-n>" },
			prev = { "<C-p>" },
			select = { "<CR>" },
		},
		schemes = {},
	}

	return setmetatable(default, Config)
end

function Config:merge(config)
	for k, v in pairs(config) do
		if type(v) == "table" and type(self[k]) == "table" then
			self[k] = vim.tbl_deep_extend("force", self[k], v)
		else
			self[k] = v
		end
	end
	print(vim.inspect(self))
end

function Config:create_user_commands()
	vim.api.nvim_create_user_command("SchemingToggle", function()
		View:toggle()
	end, {})
end

return Config
