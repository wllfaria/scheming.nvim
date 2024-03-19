local Config = require("scheming.config")
local Fs = require("scheming.fs")
local Loader = require("scheming.loader")

---@class SchemingView
---@field is_open boolean
---@field win number
---@field buf number
---@field augroup string
---@field fs SchemingFs
---@field config SchemingConfig
---@field loader SchemingLoader
---@field current_scheme string
---@field has_confirmed boolean
local View = {}
View.__index = View

local instance = nil

function View:new()
	if not instance then
		instance = setmetatable({
			is_open = false,
			augroup = "Scheming",
			win = nil,
			buf = nil,
			fs = Fs:new(),
			config = Config:get(),
			loader = Loader:new(),
			has_confirmed = false,
			current_scheme = nil,
		}, View)
	end
	return instance
end

---@return boolean
function View:toggle()
	if self.is_open then
		self:cancel_selection()
		return self.is_open
	end
	self.has_confirmed = false
	self.current_scheme = self.fs:config_read().scheme
	local layout = self.config.layout
	if layout == "bottom" then
		self:open_bottom()
	elseif layout == "float" then
		self:open_float()
	end
	self:maybe_apply_initial_preview()
	return self.is_open
end

function View:open_bottom()
	local border_size = self.config.window.show_border and 2 or 0
	local statusline_size = vim.o.cmdheight + 1
	-- Only show the title if the border is also shown, this is required by the API
	local show_title = self.config.window.show_title and self.config.window.show_border
	---@type vim.api.keyset.win_config
	local options = {
		relative = "editor",
		width = vim.o.columns,
		style = "minimal",
		col = 0,
		row = vim.o.lines - statusline_size - border_size - self.config.window.height,
		height = self.config.window.height,
		title = show_title and self.config.window.title or nil,
		title_pos = self.config.window.show_title and self.config.window.title_align or nil,
		border = self.config.window.show_border and self.config.window.border or nil,
	}
	self:create_win(options)
	self:populate_list()
	self:open()
end

function View:open_float()
	-- Only show the title if the border is also shown, this is required by the API
	local show_title = self.config.window.show_title and self.config.window.show_border
	---@type vim.api.keyset.win_config
	local options = {
		relative = "editor",
		style = "minimal",
		col = math.ceil((vim.o.columns - self.config.window.width) / 2),
		row = math.ceil((vim.o.lines - self.config.window.height) / 2 - 1),
		width = self.config.window.width,
		height = self.config.window.height,
		title = show_title and self.config.window.title or nil,
		title_pos = show_title and self.config.window.title_align or nil,
		border = self.config.window.show_border and self.config.window.border or nil,
	}
	self:create_win(options)
	self:populate_list()
	self:open()
end

function View:select_scheme()
	local line, scheme_name, scheme_config = self:get_selected_scheme()
	local ok = self.loader:setup_scheme(scheme_name, scheme_config)
	if not ok then
		self:cancel_selection()
		self:close()
		return
	end
	self.loader:apply_scheme(line)
	self.fs:change_scheme(line, scheme_config)
	self.has_confirmed = true
	self:close()
end

---@return string, string, table
function View:get_selected_scheme()
	local line = vim.api.nvim_get_current_line()
	---@type string|table|SchemeConfig
	local config = self.config.schemes[line]
	if not config then
		return line, line, {}
	end
	local scheme_name = config.package_name and config.package_name or line
	local scheme_config = config.config and config.config or config
	return line, scheme_name, scheme_config
end

function View:revert_scheme()
	self.loader:apply_scheme(self.current_scheme)
end

function View:cancel_selection()
	self:close()
	self:revert_scheme()
end

function View:load_current_scheme()
	local saved_config = self.fs:config_read()
	if saved_config then
		self.loader:apply_scheme(saved_config.scheme)
	end
end

function View:maybe_apply_initial_preview()
	if self.config.enable_preview then
		local _, scheme_name, scheme_config = self:get_selected_scheme()
		local ok = self.loader:setup_scheme(scheme_name, scheme_config)
		if not ok then
			self:cancel_selection()
			self:close()
			return
		end
		self.loader:apply_scheme(scheme_name)
	end
end

function View:populate_list()
	local sorted_keys, schemes = self:sort_schemes()
	local lines = {}
	for _, key in ipairs(sorted_keys) do
		local scheme = schemes[key]
		if not scheme then
			table.insert(lines, key)
		end
		if type(scheme) == "table" then
			table.insert(lines, key)
		else
			table.insert(lines, scheme)
		end
	end
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
end

---@return string[], table
function View:sort_schemes()
	local sorted = self.config.schemes

	if self.config.sorting.order == "none" then
		return self:sort_noop(sorted, self.config.sorting.order)
	elseif self.config.sorting.by == "name" then
		return self:sort_by_name(sorted, self.config.sorting.order)
	end

	return self:sort_by_tag(sorted, self.config.sorting.order)
end

---@param schemes table
---@param order SortingOrder
---@return string[], table
function View:sort_by_name(schemes, order)
	local keys = {}

	for k in pairs(schemes) do
		table.insert(keys, k)
	end

	table.sort(keys, function(a, b)
		return (order == "asc" and a < b) or (order == "desc" and a > b)
	end)

	return keys, schemes
end

---@param schemes table
---@param order SortingOrder
---@return string[], table
function View:sort_by_tag(schemes, order)
	local keys = {}

	for key, v in pairs(schemes) do
		if type(v) == "table" then
			table.insert(keys, key)
		else
			table.insert(keys, v)
		end
	end

	table.sort(keys, function(a, b)
		local a_tag = type(schemes[a]) == "table" and schemes[a].tag or nil
		local b_tag = type(schemes[b]) == "table" and schemes[b].tag or nil

		if a_tag and b_tag then
			return (order == "asc" and a_tag < b_tag) or (order == "desc" and a_tag > b_tag)
		elseif a_tag and not b_tag then
			return order == "asc"
		elseif not a_tag and b_tag then
			return order == "desc"
		end

		return (order == "asc" and a < b) or (order == "desc" and a > b)
	end)

	return keys, schemes
end

function View:sort_noop(schemes, _)
	local keys = {}

	for k in pairs(schemes) do
		table.insert(keys, k)
	end

	return keys, schemes
end

---@param options vim.api.keyset.win_config
function View:create_win(options)
	self.buf = vim.api.nvim_create_buf(false, true)
	self.win = vim.api.nvim_open_win(self.buf, true, options)
end

function View:open()
	if not self.is_open then
		self.is_open = true
		vim.api.nvim_set_option_value("number", true, { win = self.win })
		vim.api.nvim_set_option_value("relativenumber", false, { win = self.win })
		vim.api.nvim_set_option_value("buftype", "nofile", { buf = self.buf })
		vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })
	end
end

function View:close()
	if self.is_open then
		vim.api.nvim_win_close(self.win, true)
		self:clear()
	end
end

function View:clear()
	self.is_open = false
	self.win = nil
	self.buf = nil
end

return View
