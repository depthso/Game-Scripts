--[[
  !! Installation guide
  
  Put this script under the sign/button's model
  The script will search for a ClickDetector

  Change the ItemID variable to be the id of the UGC

  - Depso
]]

--// Configuation
local ItemID = 00000
-- local MiniumTime = 1200
-- local MiniumStage = 12

--// Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

--// Modules
-- local Depso = workspace.Depso
-- local Modules = Depso.Modules
-- local Leaderstats = require(Modules.Leaderstats)

local Sign = script.Parent
local ClickDetector = Sign:FindFirstChild("ClickDetector", true)

ClickDetector.MouseClick:Connect(function(Player)
	-- local Stage = Leaderstats:GetValue(Player, "Stage")
	-- local Time = Leaderstats:GetValue(Player, "Time")
	
	--// Checks
	-- if Time < MiniumTime then return end
	-- if Stage < MiniumStage then return end
	
	MarketplaceService:PromptPurchase(Player, ItemID)	
end)

