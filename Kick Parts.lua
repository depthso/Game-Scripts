--[[
  !! Installation guide
  
  This script will collect parts tagged with "Kick Parts"
  	- Set in PartTag variable
  	
  The script will use the HD admin API to check the Player's role

  - Depso
]]

----// Configuation
local PartTag = "Kick Parts"

--// Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// HD Admin
local HDAdminSetup = ReplicatedStorage:WaitForChild("HDAdminSetup")
local HdAdminMain = require(HDAdminSetup):GetMain()
local HdAdmin = HdAdminMain:GetModule("API")

--// The kill function itself
local function Touched(Limb)
	local Character = Limb.Parent
	if not Character then return end
	
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then return end
	
	--// Admin check
	local RankId = HdAdmin:GetRank(Player)
	if RankId <= 0 then
		Player:Kick("Bozo")
	end
end

--// Add connections for parts added
local function MemberAdded(Object: BasePart?)
	if not Object:IsA("BasePart") then return end
	
	Object.Touched:Connect(Touched)
end

--// Add connections for tag members
CollectionService:GetInstanceAddedSignal(PartTag):Connect(MemberAdded)
for _, Object in next, CollectionService:GetTagged(PartTag) do
	MemberAdded(Object)
end
