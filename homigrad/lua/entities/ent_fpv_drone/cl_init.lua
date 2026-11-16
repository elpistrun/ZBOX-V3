include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

function ENT:GetCameraPos()
    return self:GetPos() + self:GetForward() * 5 + self:GetUp() * 4
end

function ENT:GetCameraAng()
    return self:GetAngles()
end