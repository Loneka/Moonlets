local fs = require("@lune/fs")

for _, moduleName in ipairs(fs.readDir("../modules")) do
	local moduleDir = fs.readFile("../modules/" .. moduleName .. "/pesde.toml")
	print(moduleDir)
end
