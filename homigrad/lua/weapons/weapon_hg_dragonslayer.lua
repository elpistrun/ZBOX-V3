if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Slayer"
SWEP.Instructions = "Kazoo's gift. No other information available for this weapon."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.WorldModel = "models/berserk/dragonslayer/dragonslayer.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_l4d2/c_kf2_katana.mdl"
SWEP.WorldModelExchange = "models/berserk/dragonslayer/dragonslayer.mdl"
SWEP.ViewModel = ""

SWEP.NoHolster = true

SWEP.HoldType = "slam"

SWEP.DamageType = DMG_SLASH

SWEP.HoldPos = Vector(-7.5,0,-2.5)

SWEP.AttackTime = 0.8
SWEP.AnimTime1 = 2.5
SWEP.WaitTime1 = 1.5
SWEP.ViewPunch1 = Angle(1,2,0)



SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(0,0,0)

SWEP.basebone = 46
SWEP.modelscale = 0.65


SWEP.weaponPos = Vector(0.6,-6,-12)
SWEP.weaponAng = Angle(-3,85,-5)

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 125

SWEP.BleedMultiplier = 6

SWEP.PenetrationPrimary = 15

SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 6

SWEP.StaminaPrimary = 85

SWEP.AttackLen1 = 125

-- Blocking configuration
SWEP.BlockHoldPos = Vector(-8, 1, -10)
SWEP.BlockHoldAng = Angle(-15, 2, -55)
SWEP.BlockSound = "physics/metal/metal_solid_impact_bullet3.wav"

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "deploy",
    ["attack"] = "swing_l",

}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_viz_hmcd_katana.png")
	SWEP.IconOverride = "vgui/wep_viz_hmcd_katana.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true


SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = "weapons/knife/knife_hit1.wav"
SWEP.DeploySnd = "slayerequip.mp3"

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackSwing = "slayerswing.mp3"

function SWEP:Initialize()
	if self.BaseClass and self.BaseClass.Initialize then self.BaseClass.Initialize(self) end
	self:SetHoldType(self.HoldType)

	if SERVER then
		timer.Simple(0, function()
			if not IsValid(self) then return end
			if IsValid(self:GetOwner()) then return end

			local pos = self:GetPos()
			
			local ed = EffectData()
			ed:SetOrigin(pos)
			ed:SetStart(pos + Vector(0, 0, 2000))
			ed:SetFlags(1)
			util.Effect("ffvlightningbolt", ed, true, true)

			sound.Play("weapons/turibulum/shoot1.wav", pos, 140, 100, 1)

			self.SpawnSound = CreateSound(self, "thebeginning.mp3")
			self.SpawnSound:SetSoundLevel(95)
			self.SpawnSound:PlayEx(1, 100)
			self.SpawnSound:SetDSP(14)
		end)
	end
end

function SWEP:Equip(newOwner)
	if SERVER and self.SpawnSound then
		self.SpawnSound:Stop()
		self.SpawnSound = nil
	end
	if self.BaseClass and self.BaseClass.Equip then self.BaseClass.Equip(self, newOwner) end
end

function SWEP:OnRemove()
	if SERVER and self.SpawnSound then
		self.SpawnSound:Stop()
		self.SpawnSound = nil
	end
	if self.BaseClass and self.BaseClass.OnRemove then self.BaseClass.OnRemove(self) end
end

function SWEP:CanSecondaryAttack()
    return false
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "snd_jack_hmcd_knifehit.wav"
    self.AttackHitFlesh = "stab_gib" .. math.random(1, 3) .. ".wav"
    return true
end

local function GetHandMatrixEnt(self)
    local owner = self:GetOwner()
    if not IsValid(owner) then return nil end
    local ent = hg and hg.GetCurrentCharacter and hg.GetCurrentCharacter(owner) or owner
    return ent
end

function SWEP:GetWorldExchangePos()
    if CLIENT and IsValid(self.worldModel2) then
        return self.worldModel2:GetPos(), self.worldModel2:GetAngles()
    end
    local ent = GetHandMatrixEnt(self)
    if IsValid(ent) then
        local bon = ent:LookupBone("ValveBiped.Bip01_R_Hand")
        if bon then
            local mat = ent:GetBoneMatrix(bon)
            if mat then
                local pos, ang = LocalToWorld(self.weaponPos or vector_origin, self.weaponAng or angle_zero, mat:GetTranslation(), mat:GetAngles())
                return pos, ang
            end
        end
        return ent:GetPos(), ent:GetAngles()
    end
    return self:GetPos(), self:GetAngles()
end

function SWEP:Deploy()
    local ok = self.BaseClass and self.BaseClass.Deploy and self.BaseClass.Deploy(self) or true
    if SERVER then
        local owner = self:GetOwner()
        if IsValid(owner) then
            if not self._first_equip_done then
                self._first_equip_done = true
                local pos, _ = self:GetWorldExchangePos()
                sound.Play("slayerequipfirst.mp3", pos, 140, math.random(95,105), 1)
                owner:EmitSound("slayerequipfirst.mp3", 140, math.random(95,105), 1)
                local radius = 1000
                for _, ply in ipairs(ents.FindInSphere(pos, radius)) do
                    if IsValid(ply) and ply:IsPlayer() and ply ~= owner then
                        ply:ViewPunch(Angle(math.random(-6,6), math.random(-10,10), math.random(-6,6)))
                    end
                end
                local duration = 1.5
                local interval = 0.05
                local startDelay = 0.5
                local id = "dragonslayer_first_lightning_" .. self:EntIndex()
                timer.Simple(startDelay, function()
                    if not IsValid(self) or not IsValid(owner) then return end
                    timer.Create(id, interval, math.floor(duration/interval), function()
                        if not IsValid(self) or not IsValid(owner) then return end
                        local p, _ = self:GetWorldExchangePos()
                        local start = p + VectorRand() * 250 + Vector(0,0,math.random(150,300))
                        local ed = EffectData()
                        ed:SetOrigin(p)
                        ed:SetStart(start)
                        ed:SetFlags(1)
                        util.Effect("ffvlightningbolt", ed, true, true)
                    end)
                end)
                timer.Simple(startDelay + duration, function()
                    if IsValid(owner) then
                        owner:EmitSound("slayerequip.mp3", 65, math.random(95,105), 1)
                    end
                end)
            end
        end
    end
    return ok
end

SWEP.AttackTimeLength = 0.15

SWEP.AttackRads = 100

SWEP.SwingAng = -15

SWEP.MultiDmg1 = true

SWEP.BreakBoneMul = 15
SWEP.PainMultiplier = 10



SWEP.LastAxeHitSoundTime = 0
SWEP.AxeHitSoundCooldown = 0.5 

function SWEP:PrimaryAttackAdd(ent, trace)
    if SERVER and IsValid(ent) and self:IsEntSoft(ent) then
        local owner = self:GetOwner()
        if IsValid(owner) then
            local currentTime = CurTime()
            if currentTime - self.LastAxeHitSoundTime >= self.AxeHitSoundCooldown then
                owner:EmitSound("snd_jack_hmcd_axehit.wav", 50, math.random(95, 105))
                self.LastAxeHitSoundTime = currentTime
            end
        end
    end
end

SWEP.MinSensivity = 0.25

SWEP.holsteredBone = "ValveBiped.Bip01_Pelvis" -- Different attachment point
SWEP.holsteredPos = Vector(-1.1, -9, -5.3) -- Adjust position
SWEP.holsteredAng = Angle(195, 75, 230) -- Adjust rotation
SWEP.Concealed = false -- wont show up on the body
SWEP.HolsterIgnored = true -- the holster system will ignore
SWEP.Ignorebelt = true
