if(SERVER)then 
	AddCSLuaFile() 
end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Rebel's Nightmare"
SWEP.Instructions = "Press LMB to call an A-10 rapid fire to designated location."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 4
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
    local beams = {}
    local beamMat = Material("effects/laser1") 

    net.Receive("A10_AirstrikeBeam", function()
        local startPos = net.ReadVector()
        local endPos = net.ReadVector()
        table.insert(beams, {s = startPos, e = endPos, t = CurTime(), dur = 0.5})
    end)

    hook.Add("PostDrawTranslucentRenderables", "A10_DrawBeams", function()
        if #beams == 0 then return end
        render.SetMaterial(beamMat)
        local cur = CurTime()
        for i = #beams, 1, -1 do
            local b = beams[i]
            local age = cur - b.t
            if age > b.dur then
                table.remove(beams, i)
            else
                local frac = 1 - (age / b.dur)
                local alpha = 255 * frac
                local width = 80 * frac -- Thicker and fades out
                render.DrawBeam(b.s, b.e, width, 0, 1, Color(255, 255, 255, alpha))
            end
        end
    end)

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
    util.AddNetworkString("A10_AirstrikeBeam")
    
    function CallA10Airstrike(target, attacker)
        -- 5-6 seconds delay
        local delay = math.Rand(5, 6)
        timer.Simple(delay, function()
            -- Determine attack direction (Left or Right relative to random, or just random side)
            -- We'll pick a random direction for the "plane" to be firing from
            local attackAngle = math.Rand(0, 360)
            local attackDist = 4000
            local attackHeight = 4000
            local attackDir = Vector(math.cos(math.rad(attackAngle)), math.sin(math.rad(attackAngle)), 0)
            local virtualOrigin = target + attackDir * attackDist + Vector(0, 0, attackHeight)

            -- Play firing sound when beams start
            -- Play globally so everyone hears it
            local snd = "airplanefire/light_airplane_fire_0" .. math.random(1, 3) .. ".wav"
            BroadcastLua('surface.PlaySound("' .. snd .. '")')

            -- Tracers and Explosions
            local barrageDuration = 2
            local numShots = 20
            
            for i = 1, numShots do
                timer.Simple(math.Rand(0, barrageDuration), function()
                    -- Random offset around target
                    local offset = Vector(math.Rand(-150, 150), math.Rand(-150, 150), 0)
                    local hitPos = target + offset
                    
                    -- Adjust to ground
                    local tr = util.TraceLine({
                        start = hitPos + Vector(0, 0, 2000),
                        endpos = hitPos - Vector(0, 0, 2000),
                        mask = MASK_SOLID_BRUSHONLY
                    })
                    hitPos = tr.HitPos
                    
                    -- Start pos for giant beam (from the virtual attack origin with slight spread)
                    local startPos = virtualOrigin + VectorRand() * 50
                    
                    -- Giant Beam Visual (Networked)
                    net.Start("A10_AirstrikeBeam")
                    net.WriteVector(startPos)
                    net.WriteVector(hitPos)
                    net.Broadcast()
                    
                    -- Grenade Explosion
                    local bomb = ents.Create("ent_hg_grenade_m67")
                    if IsValid(bomb) then
                        bomb:SetPos(hitPos + Vector(0, 0, 10))
                        bomb:SetOwner(attacker)
                        bomb:Spawn()
                        bomb:Activate()
                        bomb:Explode()
                    end
                end)
            end
            
            -- Plane Flyby (0.9 seconds after tracers start)
            timer.Simple(0.9, function()
                local plane = ents.Create("prop_dynamic")
                if not IsValid(plane) then return end
                plane:SetModel("models/gredwitch/a10/a10_lfs.mdl")
                
                -- Disable collisions so it doesn't get stuck
                plane:SetSolid(SOLID_NONE)
                plane:SetMoveType(MOVETYPE_NONE)

                -- Flight path setup
                -- Fly perpendicular to attack dir or same? Usually same.
                -- Let's make it fly over the target area.
                local flyHeight = target.z + 1500 -- Slightly lower to be closer to beams
                local angle = attackAngle -- Fly from same direction
                local radius = 3000 -- Start closer so it's near the beams
                
                -- Spawn at the virtual origin (where beams came from) and fly towards target
                -- virtualOrigin is where the beams originate.
                local startPos = virtualOrigin
                
                -- Calculate horizontal direction to target
                local dirToTarget = (target - virtualOrigin)
                dirToTarget.z = 0 -- Flatten direction to keep plane level
                local flyDir = dirToTarget:GetNormalized()
                
                local endPos = startPos + flyDir * 8000 -- Fly far past target, maintaining height
                
                -- Make the end pos higher so it flies UP after strafing
                endPos.z = endPos.z + 4000 -- Climb up significantly at the end

                plane:SetPos(startPos)
                plane:SetAngles(flyDir:Angle())
                plane:Spawn()
                plane:Activate()
                
                -- Looping Sound
                -- CreateSound needs to be managed carefully. 
                -- Sometimes CreateSound on server doesn't network well if entity is PVS culled or something?
                -- But for a prop_dynamic it should be fine.
                -- Let's ensure the sound script is correct.
                local engineSound = CreateSound(plane, "gredwitch/a10_lfs/old/a10_max.wav")
                engineSound:SetSoundLevel(160) -- Even louder
                engineSound:Play()

                -- Movement with Swerve
                local flyDuration = 3.5 -- Increased duration for longer distance
                local startTime = CurTime()
                local swerveDir = math.random() > 0.5 and 1 or -1
                local swerveAmount = 2000 
                
                local hookName = "A10Flyby_" .. plane:EntIndex()
                hook.Add("Think", hookName, function()
                    if not IsValid(plane) then 
                        if engineSound then engineSound:Stop() end
                        hook.Remove("Think", hookName) 
                        return 
                    end
                    
                    local t = (CurTime() - startTime) / flyDuration
                    if t >= 1 then
                        if engineSound then engineSound:Stop() end
                        plane:Remove()
                        hook.Remove("Think", hookName)
                        return
                    end
                    
                    -- Linear interpolation
                    local currentPos = LerpVector(t, startPos, endPos)
                    
                    -- Swerve offset (Sine wave)
                    -- We want it to start at 0, go to max, and back to 0? Or just swerve off?
                    -- "Swerve to another direction while passing by"
                    -- Let's make it curve away.
                    local forward = (endPos - startPos):GetNormalized()
                    local right = forward:Cross(Vector(0, 0, 1))
                    
                    -- Smooth sine curve swerve
                    local swerveFactor = math.sin(t * math.pi) 
                    local swerveOffset = right * swerveFactor * swerveAmount * swerveDir
                    
                    -- Apply Upward curve at the end (pull up)
                    -- We already added height to endPos, so LerpVector handles the linear climb.
                    -- Let's add an extra exponential climb at the end?
                    local climbFactor = 0
                    if t > 0.5 then
                        climbFactor = (t - 0.5) * 2 -- 0 to 1
                        climbFactor = climbFactor * climbFactor -- Quadratic
                    end
                    local climbOffset = Vector(0, 0, climbFactor * 1000)

                    currentPos = currentPos + swerveOffset + climbOffset
                    plane:SetPos(currentPos)
                    
                    -- Calculate Angle (Look at next position)
                    local nextT = t + 0.01
                    local nextPos = LerpVector(nextT, startPos, endPos)
                    local nextSwerve = right * math.sin(nextT * math.pi) * swerveAmount * swerveDir
                    
                    local nextClimbFactor = 0
                    if nextT > 0.5 then
                        nextClimbFactor = (nextT - 0.5) * 2
                        nextClimbFactor = nextClimbFactor * nextClimbFactor
                    end
                    local nextClimbOffset = Vector(0, 0, nextClimbFactor * 1000)

                    nextPos = nextPos + nextSwerve + nextClimbOffset
                    
                    local dir = (nextPos - currentPos):GetNormalized()
                    local ang = dir:Angle()
                    
                    -- Bank angle
                    ang.r = swerveDir * 60 * swerveFactor -- Bank into the turn
                    plane:SetAngles(ang)
                    
                    plane:NextThink(CurTime())
                    return true
                end)
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
        -- for _, p in ipairs(player.GetAll()) do
        --     if IsValid(p) then p:EmitSound("airplanefire/light_airplane_fire_0" .. math.random(1, 3) .. ".wav", 100, 100, 1) end
        -- end

        CallA10Airstrike(tr.HitPos, owner)
        
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
