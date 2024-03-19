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
	if Config:get().layout == "bottom" then
		self:open_bottom()
	end
end

function View:open_bottom()
	local self = View:new()
	if not self.is_open then
		local height = 12
		---@type vim.api.keyset.win_config
		local options = {
			relative = "editor",
			width = vim.o.columns,
			height = height,
			row = vim.o.lines - vim.o.cmdheight - 3 - height,
			col = 0,
			style = "minimal",
			title = "Scheming",
			title_pos = "center",
			border = "double",
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
			local line = vim.api.nvim_get_current_line()
			vim.cmd("colorscheme " .. line)
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
	vim.cmd([[highlight FloatBorder guibg=NONE ctermbg=NONE]])
end

function View:open()
	if not self.is_open then
		self.is_open = true
		vim.api.nvim_set_option_value("number", true, { win = self.win })
		vim.api.nvim_set_option_value("relativenumber", false, { win = self.win })
		vim.api.nvim_set_option_value("buftype", "nofile", { buf = self.buf })
		vim.api.nvim_set_option_value("winhl", "Normal:Normal", { win = self.win })
		vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf })
	end
end

function View:close()
	if self.is_open then
		vim.api.nvim_win_close(self.win, true)
	end
end

return View
