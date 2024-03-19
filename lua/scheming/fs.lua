---@class SavedConfig
---@field scheme string
---@field config table

---@class SchemingFs
---@field config_file string
---@field config_dir string | string[]
---@field config_path string
local Fs = {}
Fs.__index = Fs

local instance = nil

function Fs:new()
	if not instance then
		local config_file = "scheming.json"
		local config_dir = vim.fn.stdpath("data")
		local config_path = config_dir .. "/" .. config_file

		---@type SchemingFs
		local default = {
			config_file = config_file,
			config_dir = config_dir,
			config_path = config_path,
		}
		instance = setmetatable(default, Fs)
	end
	return instance
end

---@param scheme_name string
---@param scheme_config table<string, any> | SchemeConfig
function Fs:change_scheme(scheme_name, scheme_config)
	self:config_write({
		scheme = scheme_name,
		config = scheme_config,
	})
end

---@return boolean
function Fs:config_exists()
	local ok, result = pcall(vim.fn.filereadable, self.config_path)
	if not ok then
		return false
	end
	return result == 1
end

---@return SavedConfig
function Fs:config_read()
	if not self:config_exists() then
		self:config_write({ scheme = "", config = {} })
	end
	local config_json = vim.fn.readfile(self.config_path)
	assert(type(config_json) == "table", "Scheming: Failed to read config from " .. self.config_path)
	local config = vim.fn.json_decode(config_json)
	assert(type(config) == "table", "Scheming: Failed to decode config from JSON")
	return config
end

---@param config SavedConfig
function Fs:config_write(config)
	---@type string
	local config_json = vim.fn.json_encode(config)
	assert(type(config_json) == "string", "Failed to encode config to JSON")
	local ok, _ = pcall(vim.fn.writefile, { config_json }, self.config_path)
	if not ok then
		vim.api.nvim_err_writeln("Scheming: Failed to write config to " .. self.config_path)
	end
end

return Fs
