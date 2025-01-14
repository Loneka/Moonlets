local Workspace = game:GetService("Workspace")

local Instantiate = require(script.Parent)

local TestBrick = Instantiate "Part" {
	Color = Color3.fromHSV(math.random(0, 1000) / 1000, math.random(0, 1000) / 1000, math.random(0, 1000) / 1000),
	Position = Vector3.new(0, 20, 0),
	Parent = Workspace,

	Children = {
		Instantiate "ProximityPrompt" {
			RequiresLineOfSight = false,
		},
	},
}

Instantiate(TestBrick) {
	Name = "TestBrick",

	Children = {
		Instantiate "Fire" {
			Heat = function()
				return math.random(1, 100)
			end,
		},
	},
}

return function() end
