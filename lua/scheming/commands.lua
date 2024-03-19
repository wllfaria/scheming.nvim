local View = require("scheming.view")
local Config = require("scheming.config")

---@class SchemingCommands
---@field augroup string
---@field view SchemingView
---@field config SchemingConfig
local Commands = {}
Commands.__index = Commands

local instance = nil

function Commands:new()
	if not instance then
		---@type SchemingCommands
		local default = {
			augroup = "Scheming",
			view = View:new(),
			config = Config:get(),
		}
		instance = setmetatable(default, Commands)
	end
	return instance
end

---Creates the user commands that are used to toggle the scheming selection buffer.
function Commands:create_user_commands()
	vim.api.nvim_create_user_command("SchemingToggle", function()
		local is_open = View:new():toggle()
		if is_open then
			self:create_auto_commands()
			self:create_keymaps()
		end
	end, {})
end

---Creates auto commands that are only applied to the scheming selection buffer.
function Commands:create_auto_commands()
	local view = View:new()
	vim.api.nvim_create_augroup(self.augroup, { clear = true })
	if Config:get().enable_preview then
		vim.api.nvim_create_autocmd("CursorMoved", {
			buffer = view.buf,
			group = self.augroup,
			callback = function()
				local scheme = vim.api.nvim_get_current_line()
				vim.cmd("silent! colorscheme " .. scheme)
			end,
		})
	end
	vim.api.nvim_create_autocmd("WinClosed", {
		buffer = view.buf,
		group = view.augroup,
		callback = function()
			View:new():clear()
		end,
	})
end

---Creates keymaps that are only applied to the scheming selection buffer.
function Commands:create_keymaps()
	for _, key in ipairs(self.config.mappings.cancel) do
		vim.api.nvim_buf_set_keymap(
			self.view.buf,
			"n",
			key,
			"<cmd>SchemingToggle<CR>",
			{ noremap = true, silent = true }
		)
	end
	for _, key in ipairs(self.config.mappings.select) do
		vim.api.nvim_buf_set_keymap(
			self.view.buf,
			"n",
			key,
			"<cmd>lua require('scheming.view'):new():select_scheme()<CR>",
			{ noremap = true, silent = true }
		)
	end
end

---Creates keymaps that are applied to the global vim instance.
function Commands:create_global_keymaps()
	for _, key in ipairs(self.config.mappings.toggle) do
		vim.keymap.set("n", key, "<cmd>SchemingToggle<CR>", { noremap = true, silent = true })
	end
end

return Commands
