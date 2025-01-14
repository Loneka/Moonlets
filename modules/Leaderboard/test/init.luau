local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Leaderboard = require(script.Parent)

local function HandlePlayer(Player: Player)
	Leaderboard.Set(Player, "Points", 0)

	local ValueObject = Leaderboard.GetValueObject(Player, "Points")
	if ValueObject then
		ValueObject:GetPropertyChangedSignal("Value"):Connect(function()
			print(Player, "Points", Leaderboard.Get(Player, "Points"))
		end)
	end

	task.spawn(function()
		while task.wait(1) do
			Leaderboard.Set(Player, "Points", math.random(1, 1000))
		end
	end)
end

if RunService:IsServer() then
	Players.PlayerAdded:Connect(function(Player)
		HandlePlayer(Player)
	end)

	for _, Player in ipairs(Players:GetPlayers()) do
		HandlePlayer(Player)
	end
end

return function() end
