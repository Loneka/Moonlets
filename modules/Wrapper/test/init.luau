local MyWrapper = require(script.MyWrapper)

local _GetAllTypeTest = MyWrapper:GetAll()
local _WrapTypeTest = MyWrapper:Wrap(Instance.new("Part"))

return function()
	MyWrapper:Destroy()
end
