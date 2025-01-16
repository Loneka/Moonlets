export type SerEnumItem = {
	EnumType: string,
	Value: number,
}

local TableUtil = require(script.Parent.TableUtil)

local EnumSerDes = {}

function EnumSerDes.DeserializeTree(Tree)
	local NewTree = TableUtil.Copy(Tree, true)

	for Key, Value in pairs(Tree) do
		if typeof(Value) == "table" then
			if (typeof(Value.EnumType) == "string") and (typeof(Value.Value) == "number") then
				local EnumItem = EnumSerDes.Deserialize(Value)
				if EnumItem ~= nil then
					NewTree[Key] = EnumItem
				end
			else
				NewTree[Key] = EnumSerDes.DeserializeTree(Value)
			end
		end
	end

	return NewTree
end

function EnumSerDes.Deserialize(SerEnumItem: SerEnumItem): EnumItem?
	local EnumObject: Enum = Enum[SerEnumItem.EnumType]

	if EnumObject then
		local EnumItems: { EnumItem } = EnumObject:GetEnumItems()

		for _, EnumItem in pairs(EnumItems) do
			if EnumItem.Value == SerEnumItem.Value then
				return EnumItem
			end
		end
	end

	return nil
end

function EnumSerDes.SerializeTree(Tree)
	local NewTree = TableUtil.Copy(Tree, true)

	for Key, Value in pairs(Tree) do
		if typeof(Value) == "EnumItem" then
			NewTree[Key] = EnumSerDes.Serialize(Value)
		elseif typeof(Value) == "table" then
			NewTree[Key] = EnumSerDes.SerializeTree(Value)
		end
	end

	return NewTree
end

function EnumSerDes.Serialize(EnumItem: EnumItem): SerEnumItem
	return {
		EnumType = tostring(EnumItem.EnumType),
		Value = EnumItem.Value,
	}
end

return EnumSerDes
