--!nonstrict
-- NovaEngine/ESP/Skeleton.lua
-- Show Skeleton: joint-to-joint lines. R15 first, R6 fallback.

local R15_PAIRS = {
	{ "Head", "UpperTorso" },
	{ "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" },
	{ "LeftUpperArm", "LeftLowerArm" },
	{ "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" },
	{ "RightUpperArm", "RightLowerArm" },
	{ "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" },
	{ "LeftUpperLeg", "LeftLowerLeg" },
	{ "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" },
	{ "RightUpperLeg", "RightLowerLeg" },
	{ "RightLowerLeg", "RightFoot" },
}

local R6_PAIRS = {
	{ "Head", "Torso" },
	{ "Torso", "Left Arm" },
	{ "Torso", "Right Arm" },
	{ "Torso", "Left Leg" },
	{ "Torso", "Right Leg" },
}

local MAX_BONES = #R15_PAIRS

local Skeleton = {}
Skeleton.__index = Skeleton

function Skeleton.new(gui, shared, config)
	local self = setmetatable({}, Skeleton)
	self._gui = gui
	self._shared = shared
	self._config = config
	self._items = {}
	return self
end

function Skeleton:_item(player)
	local item = self._items[player]
	if item then
		return item
	end

	local bones = {}
	for i = 1, MAX_BONES do
		local bone = self._shared.create("Frame", {
			Name = "Bone" .. i,
			BackgroundColor3 = self._config.Color,
			BorderSizePixel = 0,
			Visible = false,
		})
		bone.Parent = self._gui
		bones[i] = bone
	end

	item = { bones = bones }
	self._items[player] = item
	return item
end

function Skeleton:Update(player, ctx)
	if not ctx then
		self:Hide(player)
		return
	end

	local item = self:_item(player)
	local character = ctx.character
	local camera = ctx.camera
	local pairsList = character:FindFirstChild("UpperTorso") and R15_PAIRS or R6_PAIRS
	local used = 0

	for i, pair in ipairs(pairsList) do
		local bone = item.bones[i]
		local aPart = character:FindFirstChild(pair[1])
		local bPart = character:FindFirstChild(pair[2])
		local a = aPart and self._shared.project(camera, aPart.Position)
		local b = bPart and self._shared.project(camera, bPart.Position)
		if a and b then
			self._shared.setLine(bone, a, b, ctx.color, 1.5)
			used = i
		else
			bone.Visible = false
		end
	end

	for i = used + 1, MAX_BONES do
		item.bones[i].Visible = false
	end
end

function Skeleton:Hide(player)
	local item = self._items[player]
	if item then
		for _, bone in ipairs(item.bones) do
			bone.Visible = false
		end
	end
end

function Skeleton:SetColor(color)
	for _, item in pairs(self._items) do
		for _, bone in ipairs(item.bones) do
			bone.BackgroundColor3 = color
		end
	end
end

function Skeleton:Remove(player)
	local item = self._items[player]
	if item then
		for _, bone in ipairs(item.bones) do
			bone:Destroy()
		end
		self._items[player] = nil
	end
end

function Skeleton:Destroy()
	for _, item in pairs(self._items) do
		for _, bone in ipairs(item.bones) do
			bone:Destroy()
		end
	end
	self._items = {}
end

return Skeleton
