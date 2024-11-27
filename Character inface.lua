--[[
 - Depso
]]

local module = {}

--// Services
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local RunService = game:GetService("RunService")

local IsStudio = RunService:IsStudio()

--// This function only applies to Roblox studio
local TrackCache = {}
local function CreateAnimation(KeyframeSequence): Animation
	if not IsStudio then
		return error("Cannot create animation track outside of Studio!")
	end
	
	--// Check cache for existing animation
	local Cached = TrackCache[KeyframeSequence]
	if Cached then
		return Cached
	end

	--// Create animation from keyframes
	local CreatedId = KeyframeSequenceProvider:RegisterKeyframeSequence(KeyframeSequence)
	local Animation = Instance.new("Animation")
	Animation.AnimationId = CreatedId

	TrackCache[KeyframeSequence] = Animation
	return Animation
end

local function GetRaycastParams(Filter): RaycastParams
	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = Filter
	
	return Params
end

local Character = {}
Character.__index = Character

function Character:CharacterAdded(Character)
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid:WaitForChild("Animator")
	local Root = Character:WaitForChild("HumanoidRootPart")

	--// Asign keys
	self.Character = Character
	self.Humanoid = Humanoid
	self.Animator = Animator
	self.Root = Root
end

function Character:GetLimb(Name: string)
	local Character = self.Character
	return Character:WaitForChild(Name)
end

function Character:IsObstructed(Offset: number, Vector: string?)
	local Vector = Vector or "UpVector"
	local Offset = Offset or 0
	local Base = 2
	
	local Character = self.Character
	local Head = self:GetLimb("Head")
	
	local Params = GetRaycastParams({
		Character
	})
	
	--// Fire raycast
	local From = Head.Position
	local Direction = Head.CFrame[Vector] * (Base+Offset)
	
	return workspace:Raycast(From, Direction, Params)
end

function Character:IsOnGround(): boolean
	local Humanoid = self.Humanoid
	return Humanoid.FloorMaterial ~= Enum.Material.Air
end

function Character:IsMoving(): boolean
	local Humanoid = self.Humanoid
	return Humanoid.MoveDirection.Magnitude >= 0.1
end

function Character:SetStateEnabled(State: Enum.HumanoidStateType, Enabled: boolean)
	local Humanoid = self.Humanoid
	Humanoid:SetStateEnabled(State, Enabled)
end

function Character:SetJumpEnabled(Enabled: boolean)
	local JumpState = Enum.HumanoidStateType.Jumping
	self:SetStateEnabled(JumpState, Enabled)
end

function Character:LoadAnimation(Animation: (KeyframeSequence | Animation), Priority): AnimationTrack
	local Animator = self.Animator
	if not Animator then return end

	--// If track creation is required 
	if not Animation:IsA("Animation") then
		Animation = CreateAnimation(Animation)
	end

	local Track = Animator:LoadAnimation(Animation)
	Track.Priority = Priority or Enum.AnimationPriority.Action
	return Track
end

function Character:PlayAnimation(Animation: (KeyframeSequence | Animation), Priority): AnimationTrack
	local Track = self:LoadAnimation(Animation, Priority)
	Track:Play()
	return Track
end

function module:GetCharacter(Player: Player)
	local Real = Player.Character
	local Interface = setmetatable({}, Character)
	
	--// Connect events
	if Real then
		Interface:CharacterAdded(Real)
	end
	Player.CharacterAdded:Connect(function(New: Model)
		Interface:CharacterAdded(New)
	end)
	
	return setmetatable({},{
		__index = function(self, Key)
			--// Check if interface contains the key
			local Method = Interface[Key]
			if Method then
				return Method
			end
			
			--// Grab part from character
			return Interface:GetLimb(Key)
		end,
	})
end

return module
