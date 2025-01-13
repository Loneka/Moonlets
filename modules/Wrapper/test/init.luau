local MyWrapper = require(script.MyWrapper)

local _GetAllTypeTest = MyWrapper:GetAll()
local _WrapTypeTest = MyWrapper:Wrap(Instance.new("Part"))

local Thread = task.spawn(function()
	-- while task.wait(1) do
	-- 	for Count = 1, 10000 do
	-- 		local Test = Wrapper(function(Instance)
	-- 			assert(Instance:IsA("BasePart"), "not a BasePart")

	-- 			local Object = {
	-- 				Instance = Instance,
	-- 			}

	-- 			local ColorRandomizer = task.spawn(function()
	-- 				while task.wait(0.25) do
	-- 					Instance.Color = Color3.fromHSV(
	-- 						math.random(0, 1000) / 1000,
	-- 						math.random(0, 1000) / 1000,
	-- 						math.random(0, 1000) / 1000
	-- 					)
	-- 				end
	-- 			end)

	-- 			function Object:Destroy()
	-- 				task.cancel(ColorRandomizer)
	-- 			end

	-- 			return Object, function()
	-- 				Object:Destroy()
	-- 			end
	-- 		end)

	-- 		Test:Tag(tostring(Count))

	-- 		Test:Destroy()
	-- 		Test = nil
	-- 	end
	-- end
end)

return function()
	MyWrapper:Destroy()
	task.cancel(Thread)
end
