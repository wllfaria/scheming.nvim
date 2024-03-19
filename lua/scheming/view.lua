local Config = require("scheming.config")

---@class SchemingView
---@field is_open boolean
---@field win number
---@field buf number
---@field augroup string
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
		}, View)
	end
	return instance
end

function View:toggle()
	local layout = Config:get().layout
	if layout == "bottom" then
		self:open_bottom()
	elseif layout == "float" then
		self:open_float()
	end
end

function View:open_bottom()
	if not self.is_open then
		local config = Config:get()
		local border_size = config.window.show_border and 2 or 0
		local statusline_size = vim.o.cmdheight - 1
		-- Only show the title if the border is also shown, this is required by the API
		local show_title = config.window.show_title and config.window.show_border
		---@type vim.api.keyset.win_config
		local options = {
			relative = "editor",
			width = vim.o.columns,
			style = "minimal",
			col = 0,
			row = vim.o.lines - statusline_size - border_size - config.window.height,
			height = config.window.height,
			title = show_title and config.window.title or nil,
			title_pos = config.window.show_title and config.window.title_align or nil,
			border = config.window.show_border and config.window.border or nil,
		}
		self:create_win(options)
		self:populate_list()
		self:create_auto_commands()
		self:open()
	else
		self:close()
	end
end

function View:open_float()
	if not self.is_open then
		local config = Config:get()
		-- Only show the title if the border is also shown, this is required by the API
		local show_title = config.window.show_title and config.window.show_border
		---@type vim.api.keyset.win_config
		local options = {
			relative = "editor",
			style = "minimal",
			col = math.ceil((vim.o.columns - config.window.width) / 2),
			row = math.ceil((vim.o.lines - config.window.height) / 2 - 1),
			width = config.window.width,
			height = config.window.height,
			title = show_title and config.window.title or nil,
			title_pos = show_title and config.window.title_align or nil,
			border = config.window.show_border and config.window.border or nil,
		}
		self:create_win(options)
		self:populate_list()
		self:create_auto_commands()
		self:open()
	else
		self:close()
	end
end

function View:populate_list()
	local schemes = Config:get().schemes
	local lines = {}
	for _, v in ipairs(schemes) do
		table.insert(lines, v)
	end
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
end

function View:create_auto_commands()
	vim.api.nvim_create_augroup(self.augroup, { clear = true })
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = self.buf,
		group = self.augroup,
		callback = function()
			local scheme = vim.api.nvim_get_current_line()
			vim.cmd.colorscheme(scheme)
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		buffer = self.buf,
		group = self.augroup,
		callback = function()
			self.win = nil
			self.buf = nil
			self.is_open = false
		end,
	})
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
	end
end

return View
