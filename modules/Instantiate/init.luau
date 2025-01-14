local function Instantiate(ClassName: string)
	local Object = Instance.new(ClassName)

	return function(Properties: { [string]: any | (Object) -> any })
		for Name, Value in pairs(Properties) do
			if typeof(Value) == "function" then
				Value = Value(Object)
			end

			Object[Name] = Value
		end

		return Object
	end
end

return Instantiate
