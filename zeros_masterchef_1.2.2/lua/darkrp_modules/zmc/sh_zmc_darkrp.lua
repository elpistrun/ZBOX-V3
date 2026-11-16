--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

TEAM_ZMC_COOK = DarkRP.createJob("Chef Cuisto", {
	color = Color(111, 150, 97, 255),
	model = {"models/player/mossman.mdl"},
	description = [[You cook food.]],
	weapons = {},
	command = "zmc_cook",
	max = 4,
	salary = 15,
	admin = 0,
	vote = false,
	category = "Citizens",
	hasLicense = false
})

DarkRP.createCategory{
	name = "Cook",
	categorises = "entities",
	startExpanded = true,
	color = Color(111, 150, 97, 255),
	canSee = function(ply) return true end,
	sortOrder = 103
}

DarkRP.createEntity("Gastank", {
	ent = "zmc_gastank",
	model = "models/zerochain/props_kitchen/zmc_gastank.mdl",
	price = 500,
	max = 5,
	cmd = "buyzmcgastank",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("Buildkit", {
	ent = "zmc_buildkit",
	model = "models/zerochain/props_kitchen/zmc_buildkit.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_buildkit",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})
/*
DarkRP.createEntity("Cookbook", {
	ent = "zmc_cookbook",
	model = "models/zerochain/props_kitchen/zmc_cookbook.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_cookbook",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})



DarkRP.createEntity("Fridge", {
	ent = "zmc_fridge",
	model = "models/zerochain/props_kitchen/zmc_fridge.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_fridge",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("Garbagebin", {
	ent = "zmc_garbagepin",
	model = "models/zerochain/props_kitchen/zmc_garbagebin.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_garbagepin",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("Mixer", {
	ent = "zmc_mixer",
	model = "models/zerochain/props_kitchen/zmc_mixer.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_mixer",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("Worktable", {
	ent = "zmc_worktable",
	model = "models/zerochain/props_kitchen/zmc_worktable.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_worktable",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})


DarkRP.createEntity("BoilPot", {
	ent = "zmc_boilpot",
	model = "models/zerochain/props_kitchen/zmc_boilpot.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_boilpot",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("Grill", {
	ent = "zmc_grill",
	model = "models/zerochain/props_kitchen/zmc_heater.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_grill",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("Oven", {
	ent = "zmc_oven",
	model = "models/zerochain/props_kitchen/zmc_heater.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_oven",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("SoupPot", {
	ent = "zmc_souppot",
	model = "models/zerochain/props_kitchen/zmc_souppot.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_souppot",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("Wok", {
	ent = "zmc_wok",
	model = "models/zerochain/props_kitchen/zmc_wok.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_wok",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})



DarkRP.createEntity("Dishtable", {
	ent = "zmc_dishtable",
	model = "models/zerochain/props_kitchen/zmc_dishtable.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_dishtable",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("Ordertable", {
	ent = "zmc_ordertable",
	model = "models/zerochain/props_kitchen/zmc_ordertable.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_ordertable",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("Customertable", {
	ent = "zmc_customertable",
	model = "models/zerochain/props_kitchen/zmc_table.mdl",
	price = 500,
	max = 2,
	cmd = "buyzmc_customertable",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})

DarkRP.createEntity("Washtable", {
	ent = "zmc_washtable",
	model = "models/zerochain/props_kitchen/zmc_washtable.mdl",
	price = 500,
	max = 1,
	cmd = "buyzmc_washtable",
	allowTools = true,
	allowed = TEAM_ZMC_COOK,
	category = "Cook"
})
*/
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
