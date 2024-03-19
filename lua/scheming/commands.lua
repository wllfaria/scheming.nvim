local View = require("scheming.view")

---@class SchemingCommands
local Commands = {}
Commands.__index = Commands

function Commands:new()
	return setmetatable({}, Commands)
end

function Commands:create_user_commands()
	vim.api.nvim_create_user_command("SchemingToggle", function()
		View:new():toggle()
	end, {})
end

return Commands
