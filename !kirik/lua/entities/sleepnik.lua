AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Cardboard"
ENT.Author = "pidor"
ENT.Category = "ZCity Other"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.Model = "models/props_junk/garbage_carboard002a.mdl"

if CLIENT then
    ENT.IconOverride = "entities/ent_jack_sleepingbag.png"
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Sleep()
        end
        
        self.UsedPlayers = {}
    end

    function ENT:Use(ply)
        if self.UsedPlayers[ply] then
            ply:PrintMessage(HUD_PRINTTALK, "you already used this sleeping bag.")
            return
        end
        
        if not IsValid(self:GetNW2Entity("sleeper_2281337")) then
            self:SetNW2Entity("sleeper_2281337", ply)
            self.UsedPlayers[ply] = true
            ply:PrintMessage(HUD_PRINTTALK, "spawn set here.")
        else
            local owner = self:GetNW2Entity("sleeper_2281337")
            if IsValid(owner) and owner ~= ply then
                ply:PrintMessage(HUD_PRINTTALK, "this sleeping bag is occupied by " .. owner:GetName())
            else
                ply:PrintMessage(HUD_PRINTTALK, "you already occupied this sleeping bag.")
            end
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        if not self.m_bApplyingDamage then
            self.m_bApplyingDamage = true
            self:TakeDamageInfo(dmginfo)
            
            if dmginfo:GetDamage() >= 10 then
                if IsValid(self:GetNW2Entity("sleeper_2281337")) then
                    self:GetNW2Entity("sleeper_2281337"):PrintMessage(HUD_PRINTTALK, "your sleeping bag has been broken!")
                end
                self:Remove()
            end
            
            self.m_bApplyingDamage = false
        end
    end

    function ENT:OnRemove()
        if IsValid(self:GetNW2Entity("sleeper_2281337")) then
            self:GetNW2Entity("sleeper_2281337"):PrintMessage(HUD_PRINTTALK, "your sleeping bag has been broken!")
        end
    end
else
    surface.CreateFont("SleepnikFont", {
        font = "Arial",
        size = 30,
        weight = 600,
        antialias = true
    })

    local sleepnikHookRegistered = false

    local function DrawSleepnikNames()
        for _, ent in ipairs(ents.FindByClass("sleepnik")) do
            if IsValid(ent:GetNW2Entity("sleeper_2281337")) then
                local owner = ent:GetNW2Entity("sleeper_2281337")
                local pos = ent:GetPos() + Vector(0, 0, 25)
                local ply = LocalPlayer()

                if IsValid(ply) then
                    local distance = ply:GetPos():Distance(pos)
                    if distance > 500 then continue end

                    local alpha = math.Clamp(500 - distance, 0, 255)
                    if alpha <= 0 then continue end

                    local ang = EyeAngles()
                    ang:RotateAroundAxis(ang:Up(), -90)
                    ang.p = 0
                    ang.r = 90

                    cam.Start3D2D(pos, ang, 0.1)
                        draw.SimpleTextOutlined(owner:Nick() .. "'s sleeping bag", "SleepnikFont", 0, 0, 
                                               Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 
                                               1, Color(0, 0, 0, alpha))
                    cam.End3D2D()
                end
            end
        end
    end

    local function RegisterSleepnikHook()
        if not sleepnikHookRegistered then
            hook.Add("PostDrawOpaqueRenderables", "DrawSleepnikNames", DrawSleepnikNames)
            sleepnikHookRegistered = true
        end
    end

    function ENT:Draw()
        self:DrawModel()
        RegisterSleepnikHook()
    end

    RegisterSleepnikHook()
end
