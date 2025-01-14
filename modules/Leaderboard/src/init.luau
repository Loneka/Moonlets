local Players = game:GetService("Players")

local Instantiate = require(script.Parent.Instantiate)

local TYPE_CLASSES = {
	int = "IntValue",
	number = "NumberValue",
	string = "StringValue",
	boolean = "BoolValue",
	Instance = "ObjectValue",
	BrickColor = "BrickColorValue",
	Color3 = "Color3Value",
	Vector3 = "Vector3Value",
}

local Leaderboard = {}

function Leaderboard.Set(Player: Player, Name: string, Value: any)
	local ClassName: string? = TYPE_CLASSES[typeof(Value)]
	local Folder = Leaderboard.GetFolder(Player)
	local ObjectValue = Leaderboard.GetValueObject(Player, Name)

	assert(ClassName ~= nil, "Invalid value type")
	assert(
		(ObjectValue and (ObjectValue.ClassName == ClassName)) or true,
		"Cannot set existing value with conflicting type"
	)

	if Folder then
		if ObjectValue == nil then
			ObjectValue = Instantiate(ClassName) {
				Name = Name,
				Value = Value,
				Parent = Folder,
			}
		end

		if Value ~= nil then
			ObjectValue.Value = Value
		else
			ObjectValue:Destroy()
		end
	end
end

function Leaderboard.Get(Player: Player, Name: string): any?
	local ObjectValue = Leaderboard.GetValueObject(Player, Name)

	if ObjectValue then
		return ObjectValue.Value
	else
		return nil
	end
end

function Leaderboard.GetValueObject(Player: Player, Name: string): Instance?
	local Folder = Leaderboard.GetFolder(Player)

	if Folder then
		local ObjectValue = Folder:FindFirstChild(Name)
		if ObjectValue then
			return ObjectValue
		end
	end

	return nil
end

function Leaderboard.GetFolder(Player: Player): Folder?
	if not Player:IsDescendantOf(Players) then
		return
	end

	local ExistingFolder = Player:FindFirstChild("leaderstats")

	if ExistingFolder then
		return ExistingFolder
	else
		return Instantiate "Folder" {
			Name = "leaderstats",
			Parent = Player,
		}
	end
end

return Leaderboard
