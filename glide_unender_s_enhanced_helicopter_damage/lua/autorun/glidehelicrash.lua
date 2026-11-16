AddCSLuaFile()

game.AddParticles( "particles/building_explosion.pcf" )
PrecacheParticleSystem( "building_explosion" )

local selectedChance = CreateConVar( "glide_heli_spinout_chance", "50", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "Sets the chance out of 100 for the heli to spinout/crash when the engine is damaged enough", 1, 100 )
local tailBreakChance = CreateConVar( "glide_heli_rotorbreak_chance", "50", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "Sets the chance out of 100 for the heli to lose its tail rotor mid spinout", 1, 100 )
local rockethitAllow = CreateConVar( "glide_heli_tailhit", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "Toggles the ability for, when the tail is hit by a rocket and the engine is at low health, the helicopter to lose its tailrotor and spin out", 0, 1 )
local impactAllow = CreateConVar( "glide_heli_impact", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "Toggles the ability for the heli to explode once it collides with something while being in spinout ", 0, 1 )


hook.Add( "InitPostEntity", "PostInit", function (arguments)
    local moddedBase = scripted_ents.GetStored( "base_glide_heli" )
    local currentHeli = moddedBase.t
    local oldHandleOutOfControl = currentHeli.HandleOutOfControl
    local oldRepair = currentHeli.Repair
    local oldPhysicsCollide = currentHeli.PhysicsCollide

    print("-------->> INITITALIZING UNENDER'S ENHANCED HELI DAMAGE <<--------")

    local cvarBullet = GetConVar( "glide_bullet_damage_multiplier" )
    local cvarBlast = GetConVar( "glide_blast_damage_multiplier" )
    local cvarGlobal = GetConVar( "glide_global_damage_multiplier" )

    local controlRand = math.random( 1, 100 )
    local tailRand = math.random( 1, 100 )
    currentHeli.deniedlastHit = false 

    local function RotorDestroy( rotorTarget )
        local eff = EffectData()
        eff:SetOrigin( rotorTarget:GetPos() )
        eff:SetNormal( Vector( 0, 0, 1 ) )
        eff:SetMagnitude( 8 )
        eff:SetScale( 1 )
        eff:SetRadius( ( rotorTarget.radius / 200 ) * 50 )
        util.Effect( "cball_explode", eff )
        rotorTarget:EmitSound( "Breakable.MatMetal" )
        rotorTarget:Remove()            
    end

    local function LTESpinout ( heli, tailrotor )
        if controlRand <= selectedChance:GetInt() then
            heli:SetOutOfControl( true )
            if tailRand <= tailBreakChance:GetInt() then
                timer.Simple( math.random( 2, 5 ), function ()
                    if IsValid( tailrotor ) then
                        RotorDestroy( tailrotor )
                    end
                end)
            end                          
        end
    end

    function currentHeli:Repair()
        self:SetIsEngineOnFire( false )
        self:SetChassisHealth( self.MaxChassisHealth )
        self:SetEngineHealth( 1.0 )
        self:UpdateHealthOutputs()
        self.deniedlastHit = false
        for _, w in Glide.EntityPairs( self.wheels ) do
            w:Repair()
        end
        oldRepair( self )
    end
    
    function currentHeli:OnTakeDamage( dmginfo )
        if self.hasExploded then return end

        if self:GetIsEngineOnFire() and not self.deniedlastHit then
            LTESpinout( self, self.tailRotor )
        end

        local health = self:GetChassisHealth()
        local amount = dmginfo:GetDamage()

        if dmginfo:IsDamageType( 64 ) then 
            amount = amount * self.BlastDamageMultiplier * cvarBlast:GetFloat()
            local phys = self:GetPhysicsObject()
            if IsValid( phys ) then
                local rotorTail = self.tailRotor
                local damagePos = dmginfo:GetDamagePosition()
                local damageForce = dmginfo:GetDamageForce() * phys:GetMass() * self.BlastForceMultiplier
                phys:ApplyForceOffset( damageForce, damagePos )
                if IsValid( rotorTail ) and damagePos:Distance( rotorTail:GetPos() ) < 230 and self:GetEngineHealth() < 0.8 then
                    RotorDestroy( rotorTail )
                end
            end

        elseif dmginfo:IsDamageType( 2 ) then -- DMG_BULLET
            amount = amount * self.BulletDamageMultiplier * cvarBullet:GetFloat()
        end

        if health < amount and not self.deniedlastHit and rockethitAllow:GetBool() then
            amount = 0
            self.deniedlastHit = true 
            self:SetIsEngineOnFire( true )
            LTESpinout( self, self.tailRotor )
        else
            health = health - amount        
        end

        self:SetChassisHealth( health )
        self:TakeEngineDamage( ( amount / self.MaxChassisHealth ) * self.EngineDamageMultiplier )
        self:UpdateHealthOutputs()

        self.lastDamageAttacker = dmginfo:GetAttacker()
        self.lastDamageInflictor = dmginfo:GetInflictor()

        if health / self.MaxChassisHealth < 0.18 and self:WaterLevel() < 3 and self.CanCatchOnFire then
            self:SetIsEngineOnFire( true )
        end

        if health < 1 then
            self:Explode( self.lastDamageAttacker, self.lastDamageInflictor )
        end
    end    

    function currentHeli:PhysicsCollide( data )
        if self:GetOutOfControl() then
            local ent = data.HitEntity
            local isPlayer = IsValid( ent ) and ent:IsPlayer()

            if not isPlayer then
                if impactAllow:GetBool() then
                    local impactPos = data.HitPos
                    ParticleEffect( "building_explosion", impactPos, Angle( 0, 0, 0 ) )
                    self:Explode()
                    return
                else
                    self.deniedlastHit = true -- added this so that the second if statement in :OnTakeDamage dosent pass and have the heli constantly spin around once its on the ground, i dont think its necessary to make another self.(var) thing
                    self:SetOutOfControl( false )
                end
            end
        end
        oldPhysicsCollide( self, data )
    end

    function currentHeli:HandleOutOfControl( power, dt )
        local phys = self:GetPhysicsObject()
        local force = self:GetRight() * power * phys:GetMass() * -300 -- MODIFIED, made higher for more funny cinematic spin ( speen )
        phys:ApplyForceOffset( force * dt, self:LocalToWorld( self.TailRotorOffset ) )
    end
    
end)
