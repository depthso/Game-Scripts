--[[
  !! Installation guide
  
  This script will collect parts tagged with "Kill Parts"
  	- Set in TagName variable

  - Depso
]]

----// Configuation
local TagName = "Kill Parts"

--// Services
local CollectionService = game:GetService("CollectionService")

--// The kill function itself
local function Touched(Limb)
	local Character = Limb.Parent
	if not Character then return end
	
	local Humanoid: Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end
	
	Humanoid.Health = 0
end

--// Add connections for parts added
local function MemberAdded(Object: BasePart?)
	if not Object:IsA("BasePart") then return end
	
	Object.Touched:Connect(Touched)
end

--// Add connections for tag members
CollectionService:GetInstanceAddedSignal(TagName):Connect(MemberAdded)
for _, Object in next, CollectionService:GetTagged(TagName) do
	MemberAdded(Object)
end
