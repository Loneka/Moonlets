local CollectionService = game:GetService("CollectionService")

local Trove = require(script.Parent.Trove)

export type Wrap = {
	Value: any,
	Destroy: () -> (),
}

local function NewWrapper(Construct)
	assert(Construct ~= nil, "Construct argument not provided")

	local Wrapper = {
		Wraps = {},
		Trove = Trove.new(),
	}

	function Wrapper:GetAll(): { Wrap }
		local Wraps = {}

		for _, Wrap in pairs(Wrapper.Wraps) do
			table.insert(Wraps, Wrap)
		end

		return Wraps
	end

	function Wrapper:Get(Instance: Instance)
		local Wrap = Wrapper.Wraps[Instance]

		if Wrap ~= nil then
			return Wrap.Value, Wrap.Destroy
		else
			return nil
		end
	end

	function Wrapper:Tag(Tag: string)
		Wrapper.Trove:Add(CollectionService:GetInstanceAddedSignal(Wrapper.Tag):Connect(function(Instance)
			Wrapper:Wrap(Instance)
		end))

		Wrapper.Trove:Add(CollectionService:GetInstanceRemovedSignal(Wrapper.Tag):Connect(function(Instance)
			Wrapper:Unwrap(Instance)
		end))

		for _, Instance in ipairs(CollectionService:GetTagged(Tag)) do
			Wrapper:Wrap(Instance)
		end
	end

	function Wrapper:Unwrap(Instance: Instance)
		local _, Destroy = Wrapper:Get(Instance)

		if Destroy ~= nil then
			Destroy()
		end
	end

	function Wrapper:Wrap(Instance: Instance)
		local Value, Destroy = Construct(Instance)

		local Wrap = {
			Value = Value,
			Destroy = function()
				Destroy()

				Wrapper.Wraps[Instance] = nil
			end,
		}
		Wrapper.Wraps[Instance] = Wrap

		return Value, Destroy
	end

	function Wrapper:Destroy()
		Wrapper.Trove:Destroy()
	end

	return Wrapper
end

local Wrapper = NewWrapper(function(Instance)
	assert(Instance:IsA("Part"))

	local Object = {
		Instance = Instance,
	}

	Object.Instance.Transparency = 1

	function Object:Destroy()
		print("ahhh i got destroyed!!")
	end

	return Object, function()
		Object:Destroy()
	end
end)

local WrappedObject = Wrapper:Wrap(Instance.new("Part"))

return NewWrapper
