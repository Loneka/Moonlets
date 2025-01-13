local Wrapper = require(script.Parent.Parent)

local MyWrapper = Wrapper(function(Instance)
	assert(Instance:IsA("BasePart"), "not a BasePart")

	local Object = {
		Instance = Instance,
	}

	local ColorRandomizer = task.spawn(function()
		while task.wait(0.25) do
			Instance.Color =
				Color3.fromHSV(math.random(0, 1000) / 1000, math.random(0, 1000) / 1000, math.random(0, 1000) / 1000)
		end
	end)

	function Object:Destroy()
		task.cancel(ColorRandomizer)
	end

	return Object, function()
		Object:Destroy()
	end
end)

MyWrapper:Tag("WrapperTest")

return MyWrapper
