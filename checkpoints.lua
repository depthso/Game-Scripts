--[[
  !! Installation guide
  
  This script will collect parts tagged with "Checkpoints"
  	- Set in PadTag variable
  	
  By default, the stage numbers are fetched from the name of the pad, such as "1"
  	- Changable with GetStageFromPad function

  - Depso
]]

----// Configuation
local PadTag = "Checkpoints"

local SaveData = false
local DatastoreName = "PlayerStage"


--// Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CollectionService = game:GetService("CollectionService")

--// Modules
local Modules = script.Parent.Modules
local Leaderstats = require(Modules.Leaderstats)

--// Data tables
local Stages = {}
local Pads = {}
local StageStore

if SaveData then
	StageStore = DataStoreService:GetDataStore(DatastoreName)
end

local function SetStage(Player: Player, Stage: number)
	Stages[Player] = Stage or 0
	Leaderstats:SetValue(Player, "Stage", Stage)
end
local function GetStage(Player: Player): number
	return Stages[Player] or 0
end
local function GetPad(Stage: number): BasePart
	local Pad
	--// Might have not loaded
	repeat Pad = Pads[Stage] task.wait() until Pad 
	return Pads[Stage]
end
local function TeleportToStage(Player: Player, Stage: number)
	local Pad = GetPad(Stage)
	local Character = Player.Character or Player.CharacterAdded:Wait()

	local LocationCFrame = Pad:GetPivot()
	local Offset = Character:GetExtentsSize().Y / 2
	local FinalCFrame = LocationCFrame * CFrame.new(0,Offset,0)
	Character:PivotTo(FinalCFrame)
end
local function GetPlayerFromLimb(Limb: BasePart)
	local Character = Limb.Parent
	if not Character then return end

	local Player = Players:GetPlayerFromCharacter(Character)
	if Player then 
		return Player
	end
end

--// Add connections for the checkpoints
local function GetStageFromPad(Pad: BasePart): number
	local Stage = tonumber(Pad.Name)
	assert(Stage, `Unable to fetch stage number for {Pad}`)
	return Stage
end

local function PadAdded(Pad: BasePart?)
	local Stage = GetStageFromPad(Pad)
	Pads[Stage] = Pad

	Pad.Touched:Connect(function(Limb: BasePart)
		local Player = GetPlayerFromLimb(Limb)
		if Player then
			SetStage(Player, Stage)
		end
	end)
end

--// Add connections for tag members
CollectionService:GetInstanceAddedSignal(PadTag):Connect(PadAdded)
for _, Object in next, CollectionService:GetTagged(PadTag) do
	PadAdded(Object)
end

--// Datastore functions
local function Load(Player: Player)
	local Key = Player.UserId
	local Stage = StageStore:GetAsync(Key)
	SetStage(Player, Stage)
end
local function Save(Player: Player)
	local Key = Player.UserId
	local Stage = GetStage(Player)

	StageStore:SetAsync(Key, Stage)
end

Players.PlayerAdded:Connect(function(Player)
	if SaveData then
		Load(Player)
	end

	Player.CharacterAdded:Connect(function(Character)
		local Stage = GetStage(Player)
		TeleportToStage(Player, Stage)
	end)
end)

--// Save
if SaveData then
	Players.PlayerRemoving:Connect(Save)
end
