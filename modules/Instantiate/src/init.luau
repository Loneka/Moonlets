local function Instantiate(ClassOrInstance: string | Instance)
	local Object: Instance

	if typeof(ClassOrInstance) == "string" then
		Object = Instance.new(ClassOrInstance)
	elseif typeof(ClassOrInstance) == "Instance" then
		Object = ClassOrInstance
	end

	return function(Properties: { [string]: any | (typeof(Object)) -> any, Children: { Instance } })
		for Name, Value in pairs(Properties) do
			if typeof(Value) == "function" then
				Value = Value(Object)
			end

			if Name == "Children" then
				for _, Child in ipairs(Value) do
					Child.Parent = Object
				end
			else
				Object[Name] = Value
			end
		end

		return Object
	end
end

return Instantiate
