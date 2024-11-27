local Welding = {}

function Welding:WeldParts(Part0: BasePart, Part1: BasePart): Weld
	local Weld = Instance.new("WeldConstraint", Part1)
	Weld.Part0 = Part0
	Weld.Part1 = Part1
	
	return Weld
end

function Welding:WeldChildren(Config)
	local Parent = Config.Parent
	local Main: BasePart = Config.Main or Parent
	local Ignore = Config.Ignore

	for _, Child: BasePart in next, Parent:GetChildren() do
		if table.find(Ignore, Child) then continue end
		if table.find(Ignore, Child.Name) then continue end
		if not Child:IsA("BasePart") then continue end

		Child.Anchored = false
		self:WeldParts(Main, Child)
	end
end

return Welding
