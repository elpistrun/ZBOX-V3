if(SERVER)then 
	AddCSLuaFile() 
end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Commander's Orders"
SWEP.Instructions = "Press LMB to call an airstrike to designated location."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 25
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/ichat/w_radio.mdl"
SWEP.WorldModelReal = "models/weapons/ichat/c_radio.mdl"

SWEP.AnimList = {
    ["deploy"] = { "draw", 1, false },
    ["fire"] = { "fire", 1, false },
    ["idle"] = { "idle", 1, true }
}

if(CLIENT)then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_walkietalkie")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_walkietalkie.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 5
SWEP.SlotPos = 5
SWEP.WorkWithFake = true

SWEP.HoldPos = Vector(2, -4, 4)
SWEP.HoldAng = Angle(25, 5, 15)

if(SERVER)then
    
    local function AS_GetPlaneHeightAt(pos)
        local tr = util.TraceLine({start = pos, endpos = pos + Vector(0,0,100000), mask = MASK_SOLID_BRUSHONLY})
        local worldTop = (tr.HitPos.z - 100)
        return math.min(worldTop, pos.z + 2200)
    end

    function CallAirstrike(target)
        local delay = math.Rand(5, 7)
        timer.Simple(delay, function()
            local h = AS_GetPlaneHeightAt(target)
            local minB, maxB = game.GetWorld():GetModelBounds()
            local axis = math.random(1,2)
            local startPos, endPos
            if axis == 1 then
                startPos = Vector(minB.x - 3500, target.y, h)
                endPos = Vector(maxB.x + 3500, target.y, h)
            else
                startPos = Vector(target.x, minB.y - 3500, h)
                endPos = Vector(target.x, maxB.y + 3500, h)
            end
            local dirNorm = (endPos - startPos):GetNormalized()
            endPos = endPos + dirNorm * 2500
            local plane = ents.Create("prop_dynamic")
            if not IsValid(plane) then return end
            plane:SetModel("models/xqm/jetbody3_s3.mdl")
            plane:SetPos(startPos)
            local dir = endPos - startPos
            local ang = dir:Angle()
            ang:RotateAroundAxis(ang:Up(), 90)
            plane:SetAngles(ang)
            plane:Spawn()
            plane:Activate()
            util.ScreenShake(target, 1, 2, 6, 99999)
            local shakeTimer = "AS_JetShake_" .. plane:EntIndex()
            timer.Create(shakeTimer, 0.4, 0, function()
                if not IsValid(plane) then timer.Remove(shakeTimer) return end
                for _, e in ipairs(ents.GetAll()) do
                    local phys = e:GetPhysicsObject()
                    if IsValid(phys) and phys:IsMotionEnabled() then
                        phys:ApplyForceCenter(VectorRand() * 15)
                    end
                end
            end)
            local speed = 800 * 12.0
            local dist = startPos:Distance(endPos)
            local dur = dist / speed
            local startTime = CurTime()
            local hn = "AS_AirstrikePlane_" .. plane:EntIndex()
            hook.Add("Think", hn, function()
                if not IsValid(plane) then hook.Remove("Think", hn) return end
                local tBase = (CurTime() - startTime) / dur
                local accelStart = 0.8
                local accelFactor = 1.7
                local t
                if tBase > accelStart then
                    local tail = tBase - accelStart
                    t = math.min(1, accelStart + tail * accelFactor)
                else
                    t = tBase
                end
                if tBase >= 1 then plane:Remove() hook.Remove("Think", hn) timer.Remove(shakeTimer) return end
                local p = LerpVector(t, startPos, endPos)
                plane:SetPos(p)
            end)
            local dropT
            if axis == 1 then
                dropT = math.Clamp((target.x - startPos.x) / (endPos.x - startPos.x), 0, 1)
            else
                dropT = math.Clamp((target.y - startPos.y) / (endPos.y - startPos.y), 0, 1)
            end
            timer.Simple(dur * dropT, function()
                if not IsValid(plane) then return end
                for _, p in ipairs(player.GetAll()) do
                    if IsValid(p) then p:EmitSound("jetflybyclose.ogg", 80, 100, 1) end
                end
                local bombClass = "ent_jack_gmod_ezbomb"
                if math.random() < 0.1 then
                    bombClass = "ent_jack_gmod_ezbigbomb"
                end
                local bomb = ents.Create(bombClass)
                if not IsValid(bomb) then return end
                bomb:SetPos(plane:GetPos() + Vector(0,0,-60))
                bomb:Spawn()
                bomb:Activate()
                if bomb.Arm then
                    bomb:Arm()
                elseif bomb.SetState then
                    bomb:SetState(1)
                end
            end)
        end)
    end

    function SWEP:PrimaryAttack()
        if self:GetNextPrimaryFire() > CurTime() then return end
        self:SetNextPrimaryFire(CurTime() + 10)

        local owner = self:GetOwner()
        local tr = owner:GetEyeTrace()
        
        -- Play confirmation sound to owner
        owner:EmitSound("airstrikecallin.ogg", 75, 100, 0.8)
        
        -- Play global sound
        for _, p in ipairs(player.GetAll()) do
            if IsValid(p) then p:EmitSound("jetflybylong.wav", 80, 100, 1) end
        end

        CallAirstrike(tr.HitPos)
        
        self:PlayAnim("fire")
    end

    function SWEP:SecondaryAttack()
    end
    
    function SWEP:Reload()
    end

    function SWEP:RagdollFunc(pos, angles, ragdoll)
		shadowControl = shadowControl or hg.ShadowControl
		local fakeGun = ragdoll.fakeGun
		shadowControl(ragdoll, 5, 0.001, angles, 500, 30, pos, 500, 50)
	end
end

if(CLIENT)then
	function SWEP:DrawHUD()
		if(GetViewEntity() ~= LocalPlayer())then 
			return 
		end

		if(LocalPlayer():InVehicle())then 
			return 
		end
	end
end
