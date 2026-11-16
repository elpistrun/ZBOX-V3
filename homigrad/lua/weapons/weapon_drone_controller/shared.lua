if SERVER then
    AddCSLuaFile("cl_init.lua")
    AddCSLuaFile("shared.lua")
end

SWEP.Base = "weapon_tpik1_base"

SWEP.PrintName = "FPV Drone Controller"
SWEP.Instructions = "Control FPV Drone"
SWEP.Category = "Weapons - Drones"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1

SWEP.WorldModel = "models/nirrti/tablet/tablet_sfm.mdl"
SWEP.ViewModel = ""
SWEP.HoldType = "normal"
SWEP.Skin = 1

if CLIENT then
    SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_phone")
    SWEP.IconOverride = "vgui/wep_jack_hmcd_phone"
    SWEP.BounceWeaponIcon = false
end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.setrhik = true
SWEP.setlhik = true

SWEP.LHPos = Vector(0,-6.6,0)
SWEP.LHAng = Angle(0,0,180)

SWEP.RHPosOffset = Vector(0,0,-7.6)
SWEP.RHAngOffset = Angle(0,15,-90)

SWEP.LHPosOffset = Vector(0,0,-0.4)
SWEP.LHAngOffset = Angle(5,0,15)

SWEP.handPos = Vector(0,0,0)
SWEP.handAng = Angle(0,0,0)

SWEP.UsePistolHold = false

SWEP.offsetVec = Vector(5,-7,-1)
SWEP.offsetAng = Angle(0,90,195)

SWEP.HeadPosOffset = Vector(15,1.7,-5)
SWEP.HeadAngOffset = Angle(-90,0,-90)

SWEP.BaseBone = "ValveBiped.Bip01_Head1"

SWEP.HoldLH = "normal"
SWEP.HoldRH = "normal"
SWEP.HoldClampMax = 35
SWEP.HoldClampMin = 35