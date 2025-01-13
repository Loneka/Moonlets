local CollectionService = game:GetService("CollectionService")

local function NewWrapper<Value, Destroy>(Construct: (Instance) -> (Value, Destroy))
	assert(Construct ~= nil, "Construct argument not provided")

	export type Wrap = {
		Value: Value,
		Destroy: () -> (),
	}

	local Wrapper = {
		Wraps = {},
		Tags = {},
	}

	function Wrapper:Untag(Tag: string)
		local TagEntry = Wrapper.Tags[Tag]

		if TagEntry ~= nil then
			for _, Listener in ipairs(TagEntry.Listeners) do
				Listener:Disconnect()
			end
		end

		Wrapper.Tags[Tag] = nil
	end

	function Wrapper:Tag(Tag: string)
		local TagEntry = {
			Listeners = {
				CollectionService:GetInstanceAddedSignal(Tag):Connect(function(Instance)
					Wrapper:Wrap(Instance)
				end),
				CollectionService:GetInstanceRemovedSignal(Tag):Connect(function(Instance)
					Wrapper:Unwrap(Instance)
				end),
			},
		}

		for _, Instance in ipairs(CollectionService:GetTagged(Tag)) do
			Wrapper:Wrap(Instance)
		end

		Wrapper.Tags[Tag] = TagEntry
	end

	function Wrapper:GetAll(): { Value }
		local WrapValues = {}

		for _, Wrap in pairs(Wrapper.Wraps) do
			table.insert(WrapValues, Wrap.Value)
		end

		return WrapValues
	end

	function Wrapper:Get(Instance: Instance): (Value?, Destroy?)
		local Wrap = Wrapper.Wraps[Instance]

		if Wrap ~= nil then
			return Wrap.Value, Wrap.Destroy
		else
			return nil
		end
	end

	function Wrapper:Unwrap(Instance: Instance)
		local _, Destroy = Wrapper:Get(Instance)

		if Destroy ~= nil then
			Destroy()
		end
	end

	function Wrapper:Wrap(Instance: Instance): Value
		local ExistingWrap = Wrapper:Get(Instance)

		if ExistingWrap then
			return ExistingWrap
		else
			local Value, Destroy = Construct(Instance)

			local Wrap: Wrap = {
				Value = Value,
				Destroy = function()
					Destroy()

					Wrapper.Wraps[Instance] = nil
				end,
			}
			Wrapper.Wraps[Instance] = Wrap

			return Value
		end
	end

	function Wrapper:Destroy()
		for _, Wrap in pairs(Wrapper.Wraps) do
			Wrap.Destroy()
			Wrap.Value = nil
		end

		for Tag, _ in pairs(Wrapper.Tags) do
			Wrapper:Untag(Tag)
		end

		Wrapper.Wraps = {}
	end

	return Wrapper
end

return NewWrapper
