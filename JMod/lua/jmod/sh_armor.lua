player_manager.AddValidModel("JMod_HazMat", "models/bloocobalt/splinter cell/chemsuit_cod.mdl")
player_manager.AddValidHands("JMod_HazMat", "models/bloocobalt/splinter cell/chemsuit_v.mdl", 0, "00000000")

-- default armor data
JMod.DEFAULT_ARMOR = {
	items = {},
	speedFrac = nil,
	effects = {},
	mskmat = nil,
	sndlop = nil,
	blackvision = nil,
	suited = false,
	bodygroups = nil,
	totalWeight = 0
}

--[[ ArmorSlots

	-- if damage is locational (bullets):

	HITGROUP_HEAD
		eyes (1/2 of hit if hit is from front)
		mouthnose (1/2 of hit if hit is from front)
		ears (nonprotective: receives damage but doesn't protect, 1/4)
		head (if hit angle isn't from front)
	HITGROUP_CHEST
		chest (all of HITGROUP_CHEST)
		back (all of HITGROUP_CHEST if hit is from back)
	HITGROUP_STOMACH
		abdomen (all of HITGROUP_STOMACH)
	HITGROUP_LEFTLEG
		leftthigh (1/2)
		leftcalf (1/2)
	HITGROUP_RIGHTLEG
		rightthigh (1/2)
		rightcalf (1/2)
	HITGROUP_RIGHTARM
		rightbicep (1/2)
		rightforearm (1/2)
	HITGROUP_LEFTARM
		leftbicep (1/2)
		leftforearm (1/2)
	
--]]
-- support third-party backup armor repair recipes
JMod.BackupArmorRepairRecipes = JMod.BackupArmorRepairRecipes or {}

JMod.LocationalDmgTypes = {DMG_BULLET, DMG_BUCKSHOT, DMG_AIRBOAT, DMG_SNIPER}

--JMod.FullBodyScalingDamageTypes={DMG_ACID, DMG_POISON}
JMod.FullBodyDmgTypes = {DMG_CRUSH, DMG_SLASH, DMG_BURN, DMG_VEHICLE, DMG_BLAST, DMG_CLUB, DMG_PLASMA, DMG_ACID, DMG_POISON}

JMod.BiologicalDmgTypes = {DMG_NERVEGAS, DMG_RADIATION}

JMod.PiercingDmgTypes = {DMG_BULLET, DMG_BUCKSHOT, DMG_AIRBOAT, DMG_SNIPER, DMG_SLASH}

JMod.BodyPartHealthMults = {
	--skintight -- HITGROUP_HEAD
	eyes = .05,
	mouthnose = .05,
	ears = 0,
	head = .18,
	-- HITGROUP_CHEST
	chest = .25,
	back = 0,
	-- HITGROUP_STOMACH
	abdomen = .1,
	pelvis = .05,
	waist = 0,
	-- HITGROUP_LEFTLEG
	leftthigh = .04,
	leftcalf = .04,
	-- HITGROUP_RIGHTLEG
	rightthigh = .04,
	rightcalf = .04,
	-- HITGROUP_RIGHTARM
	rightshoulder = .04,
	rightforearm = .04,
	-- HITGROUP_LEFTARM
	leftshoulder = .04,
	leftforearm = .04
}

JMod.ArmorSlotNiceNames = {
	eyes = "Eyes",
	mouthnose = "Mouth & Nose",
	ears = "Ears",
	head = "Head",
	chest = "Chest",
	back = "Back",
	abdomen = "Abdomen",
	pelvis = "Pelvis",
	waist = "Waist",
	leftthigh = "Left Thigh",
	leftcalf = "Left Calf",
	rightthigh = "Right Thigh",
	rightcalf = "Right Calf",
	rightshoulder = "Right Shoulder",
	rightforearm = "Right Forearm",
	leftshoulder = "Left Shoulder",
	leftforearm = "Left Forearm"
}

-- only used if JMod.Config.QoL.RealisticLocationalDamage is true
JMod.BodyPartDamageMults = {
	[HITGROUP_HEAD] = 10,
	[HITGROUP_CHEST] = 1,
	[HITGROUP_GENERIC] = 1,
	[HITGROUP_STOMACH] = .5,
	[HITGROUP_GEAR] = .5,
	[HITGROUP_LEFTARM] = .2,
	[HITGROUP_RIGHTARM] = .2,
	[HITGROUP_LEFTLEG] = .2,
	[HITGROUP_RIGHTLEG] = .2
}

local BasicArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .999,
	[DMG_CLUB] = .99,
	[DMG_SLASH] = .99,
	[DMG_BULLET] = .98,
	[DMG_BLAST] = .95,
	[DMG_SNIPER] = .9,
	[DMG_AIRBOAT] = .85,
	[DMG_CRUSH] = .75,
	[DMG_VEHICLE] = .65,
	[DMG_BURN] = .65,
	[DMG_PLASMA] = .65,
	[DMG_ACID] = .55
}

local PoorArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .6,
	[DMG_CLUB] = .6,
	[DMG_SLASH] = .6,
	[DMG_BULLET] = .2,
	[DMG_BLAST] = .2,
	[DMG_SNIPER] = .1,
	[DMG_AIRBOAT] = .2,
	[DMG_CRUSH] = .3,
	[DMG_VEHICLE] = .2,
	[DMG_BURN] = .2,
	[DMG_PLASMA] = .1,
	[DMG_ACID] = .1
}

local NonArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .05,
	[DMG_BLAST] = .05,
	[DMG_BULLET] = .05,
	[DMG_SNIPER] = .05,
	[DMG_AIRBOAT] = .05,
	[DMG_CLUB] = .05,
	[DMG_SLASH] = .05,
	[DMG_CRUSH] = .05,
	[DMG_VEHICLE] = .05,
	[DMG_BURN] = .05,
	[DMG_PLASMA] = .05,
	[DMG_ACID] = .05
}

-- keep in mind that all armor model names must be all lower-case
JMod.ArmorTable = {
	["Parachute"] = {
		PrintName = "Parachute",
		mdl = "models/jessev92/resliber/weapons/parachute_backpack_closed_w.mdl",
		clr = {
			r = 83,
			g = 83,
			b = 55
		},
		slots = {
			back = .8
		},
		eff = {
			parachute = {mdl = "models/jessev92/bf2/parachute.mdl", offset = 50, drag = 3}
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1, 1, 1),
		pos = Vector(-3, -50, 0),
		ang = Angle(-90, 0, 90),
		wgt = 30,
		dur = 100,
		ent = "ent_jack_gmod_ezarmor_parachute"
	},
	["Flamethrower-Tank"] = {
		PrintName = "Flamethrower Tank",
		mdl = "models/weapons/sanic/w_m2_static.mdl",
		clr = {
			r = 255,
			g = 255,
			b = 255
		},
		clrForced = true,
		slots = {
			back = 1
		},
		chrg = {
			fuel = 100,
			gas = 100,
		},
		eff = {
			weapon = "wep_jack_gmod_ezflamethrower",
			explosive = true
		},
		bdg = {
			[1] = 0
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1, 1, 1),
		pos = Vector(0.1, -10.1, -0.5),
		ang = Angle(90, 180, -90),
		wgt = 30,
		dur = 50,
		ent = "ent_jack_gmod_ezarmor_flametank"
	}
}

-- Dynamically generate armor ents
function JMod.GenerateArmorEntities(tbl)
	for class, info in pairs(tbl) do
		if info.noent then continue end
		local armorent = {}
		armorent.Base = "ent_jack_gmod_ezarmor"
		armorent.PrintName = info.PrintName or class
		if info.Spawnable == nil then
			armorent.Spawnable = true
		else
			armorent.Spawnable = info.Spawnable
		end
		armorent.AdminOnly = info.AdminOnly or false
		armorent.Category = info.Category or "JMod - EZ Misc."
		armorent.ArmorName = class
		armorent.ModelScale = info.gayPhysics and nil or info.entsiz -- or math.max(info.siz.x, info.siz.y, info.siz.z)
		scripted_ents.Register(armorent, info.ent)
	end
end

JMod.GenerateArmorEntities(JMod.ArmorTable)

-- support third-party additions to the jmod armor table
local function LoadAdditionalArmor()
	if JMod.AdditionalArmorTable then
		table.Merge(JMod.ArmorTable, JMod.AdditionalArmorTable)
		JMod.GenerateArmorEntities(JMod.AdditionalArmorTable)
	end
end

hook.Add("Initialize", "JMod_LoadAdditionalArmor", LoadAdditionalArmor)

-- support third-party integration of gas-based weapons
function JMod.GetArmorBiologicalResistance(ply, typ)
	local inhaleResist, skinResist, eyeProtect = 0, 0, 0

	if ply.EZarmor then
		for k, armorData in pairs(ply.EZarmor.items) do
			if not armorData.tgl then
				local ArmorInfo = JMod.ArmorTable[armorData.name]

				if ArmorInfo.def and (ArmorInfo.chrg and ArmorInfo.chrg.chemicals and armorData.chrg.chemicals > 0) then
					skinResist = skinResist + (ArmorInfo.def[typ] or 0) * ((ArmorInfo.slots.chest or 0) + (ArmorInfo.slots.abdomen or 0)) / 2
					inhaleResist = inhaleResist + (ArmorInfo.def[typ] or 0) * (ArmorInfo.slots.mouthnose or 0)
					eyeProtect = eyeProtect + (ArmorInfo.def[typ] or 0) * (ArmorInfo.slots.eyes or 0)
				end
			end
		end
	end

	return inhaleResist, skinResist, eyeProtect
end

function JMod.DepleteArmorChemicalCharge(ply, amt)
	local SubtractAmt = amt * JMod.Config.Armor.DegradationMult * math.Rand(.05, .15)

	if ply.EZarmor then
		for k, armorData in pairs(ply.EZarmor.items) do
			local ArmorInfo = JMod.ArmorTable[armorData.name]

			if armorData.chrg and armorData.chrg.chemicals then
				armorData.chrg.chemicals = math.max(armorData.chrg.chemicals - SubtractAmt, 0)

				if armorData.chrg.chemicals <= ArmorInfo.chrg.chemicals * .25 then
					JMod.EZarmorWarning(ply, (ArmorInfo.PrintName or armorData.name).."'s chemical charge is almost depleted!")
				end

				break
			end
		end
	end
end

hook.Add("SetupMove", "JMOD_SLEEP", function(ply, mvd, cmd)
	if not(ply:Alive()) then ply.JMod_IsSleeping = false return end
	local Time = CurTime()
	local Veh = ply:GetVehicle()
	if not((cmd:GetMouseX() < 10) and (cmd:GetMouseY() < 10) and (cmd:GetButtons() == 0) and IsValid(Veh) and IsValid(Veh:GetParent()) and Veh:GetParent().EZrespawnPoint) then
		ply.JModLastLookMoveTime = Time
	end
	if (Time - ply.JModLastLookMoveTime) > 15 then
		ply.JMod_IsSleeping = true
	else
		ply.JMod_IsSleeping = false
	end
end)

hook.Add("SetupMove", "JMOD_DISABLE_JUMP", function(ply, mvd, cmd)
	if mvd:KeyDown(IN_JUMP) and (ply.EZImmobilizationTime and (ply.EZImmobilizationTime > CurTime())) then
		local NewButtons = bit.band(mvd:GetButtons(), bit.bnot(IN_JUMP))
		mvd:SetButtons(NewButtons)
	end
end)

hook.Add("Move", "JMOD_ARMOR_MOVE", function(ply, mv)
	local origSpeed = mv:GetMaxSpeed()
	local origClientSpeed = mv:GetMaxClientSpeed()

	if not(ply.IsProne and ply:IsProne()) and ply.EZarmor then
		if ply.EZarmor.speedfrac and ply.EZarmor.speedfrac ~= 1 then
			mv:SetMaxSpeed(origSpeed * ply.EZarmor.speedfrac)
			mv:SetMaxClientSpeed(origClientSpeed * ply.EZarmor.speedfrac)
		end
		if SERVER and IsFirstTimePredicted() then
			if ply:GetNW2Bool("EZparachuting", false) and IsValid(ply.EZparachute) and ply:GetMoveType() ~= MOVETYPE_WALK then
				ply:SetNW2Bool("EZparachuting", false)
			end
		end
	end

	if ply.EZImmobilizationTime and (ply.EZImmobilizationTime > CurTime()) then
		mv:SetMaxSpeed(origSpeed * .01)
		mv:SetMaxClientSpeed(origClientSpeed * .01)
	end
end)

if CLIENT then
	function JMod.GetItemInSlot(armorTable, slot)
		if not (armorTable and armorTable.items) then return nil end

		for id, armorData in pairs(armorTable.items) do
			local ArmorInfo = JMod.ArmorTable[armorData.name]
			if ArmorInfo.slots[slot] then return id, armorData, ArmorInfo end
		end

		return nil
	end

	concommand.Add("jmod_ez_toggleeyes", function()
		local ply = LocalPlayer()
		if not (IsValid(ply) and ply:Alive()) then return end
		-- 2 eyes
		ply:ConCommand("jmod_ez_armoraction toggle eyes")
	end)

	local ArmorCommands = {"drop", "toggle", "repair", "recharge"}
	local ArmorNames = {"head", "eyes", "mouthnose", "ears", "leftshoulder", "leftforearm", "leftthigh", "leftcalf", "chest", "back", "waist", "pelvis", "rightshoulder", "rightforearm", "rightthigh", "rightcalf"}

	concommand.Add("jmod_ez_armoraction", function(ply, cmd, args)
		if not(IsValid(ply)) or not(ply:Alive()) then return end
		local action = args[1]
		local slot = args[2]

		if not(action) then return end

		if not isnumber(tonumber(action)) then
			action = table.KeyFromValue(ArmorCommands, action)
		end
		if slot and isnumber(tonumber(slot)) then
			slot = ArmorNames[tonumber(slot)]
		end

		if not(action) then return end
		
		if not(slot) then
			for number, slot in ipairs(ArmorNames) do
				local ItemID, ItemData, ItemInfo = JMod.GetItemInSlot(ply.EZarmor, slot)
				if ItemID then
					net.Start("JMod_Inventory")
					net.WriteInt(action, 8)
					net.WriteString(ItemID)
					net.SendToServer()
				end
			end
		else
			local ItemID, ItemData, ItemInfo = JMod.GetItemInSlot(ply.EZarmor, slot)
			if not ItemID then
				ply:PrintMessage(HUD_PRINTCENTER, "There's nothing in slot " .. slot)
			else
				net.Start("JMod_Inventory")
				net.WriteInt(action, 8)
				net.WriteString(ItemID)
				net.SendToServer()
			end
		end
	end, function(cmd, params)
		-- Normalizes the string
		params = params:Trim():lower()
		-- Splits the string into an array
		params = string.Explode('%s+',params,true)
		
		local Suggestions = {}

		if #params < 2 then
			for _, action in ipairs(ArmorCommands) do
				if string.find(action, params[1]) then
					table.insert(Suggestions, cmd .. " " .. action)
				end
			end
		else
			for _, slot in ipairs(ArmorNames) do
				if string.find(slot, params[2]) then
					table.insert(Suggestions, cmd .. " " .. params[1] .. " " .. slot)
				end
			end
		end

		return Suggestions

	end, "First argument is action, second arg is slot to apply the action to")
end

--LoadAdditionalArmor()

-- Sounds
sound.Add({	name = "JMod_ZipLine_Clip",
	channel = CHAN_BODY,
	volume	= 1.0,
	level	= 50,
	pitch	= { 90, 110 },
	sound	= { "npc/combine_soldier/zipline_clip1.ogg", "npc/combine_soldier/zipline_clip2.ogg"}
} )

sound.Add({	name = "JMod_ParaWep_Deploy",
	channel	= CHAN_BODY,
	volume	= 1.0,
	level	= 100,
	pitch	= { 105, 110 },
	--sound	= {"jessev92/parachute/deploy1.ogg","jessev92/parachute/deploy2.ogg","jessev92/parachute/deploy3.ogg","jessev92/parachute/deploy4.ogg","jessev92/parachute/deploy5.ogg"}
	sound	= {"common/null.ogg"}
})

sound.Add({	name = "JMod_BF2142_Para_Deploy",
	channel	= CHAN_BODY,
	volume	= 1.0,
	level	= 75,
	pitch	= { 105, 110 },
	sound	= {"jessev92/bf2142/vehicles/parachute_open.ogg"}
})

sound.Add({	name = "JMod_BF2_Para_Deploy",
	channel	= CHAN_BODY,
	volume	= 1.0,
	level	= 75,
	pitch	= { 105, 110 },
	sound	= {"jessev92/bf2/vehicles/parachute_deploy.ogg"}
})

sound.Add({	name = "JMod_BF2_Para_Idle",
	channel	= CHAN_STATIC,
	volume	= 1.0,
	level	= 75,
	pitch	= { 105, 110 },
	sound	= {"jessev92/bf2/vehicles/parachute_ride_loop.wav"}
})
