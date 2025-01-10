local Tests = {
	BuiltIn = {},
}

function Tests.Run(ModuleScript: ModuleScript): () -> ()
	return require(ModuleScript)
end

function Tests.RunAll(ModuleScripts: { ModuleScript }): { () -> () }
	local KillCallbacks = {}

	for _, Module in pairs(ModuleScripts) do
		local Kill = require(Module)
		table.insert(KillCallbacks, Kill)
	end

	return KillCallbacks
end

function Tests.KillAll(KillCallbacks: { () -> () })
	for _, Kill in ipairs(KillCallbacks) do
		Kill()
	end
end

for _, Module in ipairs(script.Parent.Modules:GetChildren()) do
	local TestModule = Module:FindFirstChild("Test")
	if TestModule then
		Tests.BuiltIn[Module.Name] = TestModule
	end
end

return Tests
