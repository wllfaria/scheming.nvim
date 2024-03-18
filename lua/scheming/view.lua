local View = {}
View.__index = View

function View:toggle()
	print("toggled")
end

return View
