include("shared.lua")

if SERVER then
    function SWEP:Initialize()
        self.CurrentDrone = NULL
        self.InControl = false
    end

    function SWEP:Holster()
        if self.InControl and IsValid(self.CurrentDrone) then
            self:ReleaseControl()
        end
        return true
    end

    function SWEP:OnRemove()
        if self.InControl and IsValid(self.CurrentDrone) then
            self.CurrentDrone:SetDriver(NULL)
        end
    end

    function SWEP:PrimaryAttack()
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        if not IsValid(self.CurrentDrone) then
            ply:ChatPrint("No drone connected")
            return
        end

        if self.InControl then
            self:ReleaseControl()
            ply:ChatPrint("Control released")
        else
            self.CurrentDrone:SetDriver(ply)
            self.InControl = true

            net.Start("drone_controller_take_control")
            net.Send(ply)

            ply:ChatPrint("Drone control activated")
        end
    end

    function SWEP:SecondaryAttack()
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        if self.InControl then
            self:ReleaseControl()
        end

        if IsValid(self.CurrentDrone) then
            self.CurrentDrone:SetDriver(NULL)
        end

        self.CurrentDrone = NULL
        self.InControl = false
        ply:ChatPrint("Disconnected")
    end

    function SWEP:TakeControl()
        local ply = self:GetOwner()
        if not IsValid(ply) or not IsValid(self.CurrentDrone) then return end

        self.CurrentDrone:SetDriver(ply)
        self.InControl = true

        net.Start("drone_controller_take_control")
        net.Send(ply)
    end

    function SWEP:ReleaseControl()
        local ply = self:GetOwner()
        if not IsValid(ply) then return end

        if IsValid(self.CurrentDrone) and self.CurrentDrone:GetDriver() == ply then
            self.CurrentDrone:SetDriver(NULL)
            self.CurrentDrone.Throttle = 0
            self.CurrentDrone.Roll = 0
            self.CurrentDrone.Pitch = 0
            self.CurrentDrone.Yaw = 0
        end

        self.InControl = false

        net.Start("drone_controller_release_control")
        net.Send(ply)
    end
end