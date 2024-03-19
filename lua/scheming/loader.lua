local Config = require("scheming.config")
local Fs = require("scheming.fs")

---@class SchemingLoader
---@field fs SchemingFs
local Loader = {}
Loader.__index = Loader

local instance = nil

function Loader:new()
	if not instance then
		---@type SchemingLoader
		local default = {
			fs = Fs:new(),
		}
		instance = setmetatable(default, Loader)
	end
	return instance
end

---@param scheme_name string
---@param scheme_config string | table | SchemeConfig
function Loader:setup_scheme(scheme_name, scheme_config)
	if not scheme_name then
		return
	end
	if scheme_config then
		local ok, package = pcall(require, scheme_name)
		if not ok then
			self:scheme_not_found(scheme_name)
			return
		end
		package.setup(scheme_config)
	else
		local ok, package = pcall(require, scheme_name)
		if not ok then
			self:scheme_not_found(scheme_name)
			return
		end
		package.setup({})
	end
	self:apply_scheme(scheme_name)
end

function Loader:scheme_not_found(scheme_name)
	vim.api.nvim_err_writeln(
		"Scheming: Scheme not found: `" .. scheme_name .. "`. Hint: did you forget to install the package?"
	)
end

function Loader:apply_scheme(scheme_name)
	vim.cmd("silent! colorscheme " .. scheme_name)
end

return Loader
