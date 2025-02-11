local TableUtil = require(script.Parent.TableUtil)
local DeepEquals = require(script.DeepEquals)

local function CopyIfTable(Value)
	if typeof(Value) == "table" then
		return TableUtil.Copy(Value, true)
	else
		return Value
	end
end

local function Equals(A, B)
	if (typeof(A) == "table") and (typeof(B) == "table") then
		return DeepEquals(A, B)
	else
		return A == B
	end
end

local function ProcessObserver(Observer, OldValue, NewValue, Force: boolean?)
	if Observer.Specifier ~= nil then
		local SpecificValue, NewSpecificValue = Observer.Specifier(OldValue), Observer.Specifier(NewValue)

		if (not Force) and Equals(SpecificValue, NewSpecificValue) then
			return
		end

		Observer.Callback(SpecificValue, NewSpecificValue)
	else
		Observer.Callback(OldValue, NewValue)
	end
end

local function NewStator(DefaultValue, Updaters)
	local Stator = {
		Value = DefaultValue,
		Updaters = Updaters,
		Observers = {},
	}

	function Stator:Observe(Callback, Specifier: ((any) -> any)?)
		local Value = Stator:Get()
		local Observer = {
			Callback = Callback,
			Specifier = Specifier,
		}

		table.insert(Stator.Observers, Observer)

		ProcessObserver(Observer, Value, Value)

		return function()
			local Index = table.find(Stator.Observers, Observer)
			if Index ~= nil then
				table.remove(Stator.Observers, Index)
			end
		end
	end

	function Stator:Update(Updater)
		local Value = Stator:Get()
		local NewValue = Updater(CopyIfTable(Value))

		Stator.Value = NewValue

		for _, Observer in ipairs(Stator.Observers) do
			ProcessObserver(Observer, Value, NewValue)
		end
	end

	function Stator:Get()
		return CopyIfTable(Stator.Value)
	end

	return Stator
end

return NewStator
