local Stator = require(script.Parent)

local TestStator = Stator({ Test = 1, AnotherTest = math.random(1, 1000) }, {
	RandomizeTest = function(Value)
		Value.AnotherTest = math.random(100000, 10000000)

		return Value
	end,
})

TestStator:Observe(function(OldValue, NewValue)
	print(OldValue, NewValue)
end)

TestStator:Observe(function(OldValue, NewValue)
	print(OldValue, NewValue)
end, function(Value)
	return Value.AnotherTest
end)

TestStator:Update(TestStator.Updaters.RandomizeTest)

TestStator:Update(function()
	return {}
end)

return function() end
