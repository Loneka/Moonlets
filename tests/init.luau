local Tests = {
	BuiltIn = {},
	KillCallbacks = {},
}

function Tests:Run(ModuleScript: ModuleScript): () -> ()
	local NewModule = ModuleScript:Clone()
	NewModule.Parent = ModuleScript.Parent

	local Kill = require(NewModule)
	table.insert(Tests.KillCallbacks, Kill)

	return Kill
end

function Tests:RunAll(ModuleScripts: { ModuleScript })
	for _, Module in pairs(ModuleScripts) do
		Tests:Run(Module)
	end
end

function Tests:KillAll()
	for _, Kill in ipairs(Tests.KillCallbacks) do
		Kill()
	end

	Tests.KillCallbacks = {}
end

for _, Module in ipairs(script.Parent.Modules:GetChildren()) do
	local TestModule = Module:FindFirstChild("Test")
	if TestModule then
		Tests.BuiltIn[Module.Name] = TestModule
	end
end

return Tests
