local function DeepCopy(Table: { any })
	local Copy = {}

	for Key, Value in pairs(Table) do
		if type(Value) == "table" then
			Copy[Key] = DeepCopy(Value)
		else
			Copy[Key] = Value
		end
	end

	return Copy
end

return DeepCopy
