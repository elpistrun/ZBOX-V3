ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "FPV Drone"
ENT.Category = "FPV Drones"
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.Model = "models/kamik/ardrone.mdl"

if SERVER then
    AddCSLuaFile("cl_init.lua")
    AddCSLuaFile("shared.lua")
end