local Wrapper = require(script.Parent)

local MyWrapper = Wrapper(function(Instance)
	local Object = {}

	local ColorRandomizer = task.spawn(function()
		while task.wait(0.5) do
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

return function()
	MyWrapper:Destroy()
end
