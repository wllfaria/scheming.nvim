local Config = require("scheming.config"):get()

---@class SchemingView
---@field is_open boolean
---@field win number
---@field buf number
local View = {}
View.__index = View

function View:new()
	return setmetatable({
		is_open = false,
	}, View)
end

function View:toggle()
	if Config.layout == "bottom" then
		self:open_bottom()
	end
end

function View:open_bottom()
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
		self:open(options)
	else
		self:close()
	end
end

function View:open(options)
	if not self.is_open then
		vim.cmd([[highlight FloatBorder guibg=NONE ctermbg=NONE]])
		self.buf = vim.api.nvim_create_buf(false, true)
		self.win = vim.api.nvim_open_win(self.buf, true, options)
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
		self.win = nil
		self.buf = nil
		self.is_open = false
	end
end

return View
