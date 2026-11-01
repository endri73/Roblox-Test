--!nonstrict
-- NovaEngine/ESP/Shared.lua
-- Shared helpers for the ESP layers. Injected, never required.

local Shared = {}

Shared.FONT = Enum.Font.GothamMedium
Shared.FONT_BOLD = Enum.Font.GothamBold
Shared.DEFAULT_COLOR = Color3.fromRGB(126, 94, 255)

function Shared.create(class, props)
	local inst = Instance.new(class)
	for key, value in pairs(props or {}) do
		(inst :: any)[key] = value
	end
	return inst
end

-- Returns nil when the point is behind the camera or off screen.
function Shared.project(camera, position)
	local screen, onScreen = camera:WorldToViewportPoint(position)
	if not onScreen or screen.Z <= 0 then
		return nil
	end
	return Vector2.new(screen.X, screen.Y)
end

-- Draws a rotated 1px frame between two screen points.
function Shared.setLine(frame, a, b, color, thickness)
	local delta = b - a
	local length = delta.Magnitude
	if length < 1 then
		frame.Visible = false
		return
	end
	frame.Visible = true
	frame.BackgroundColor3 = color
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
	frame.Size = UDim2.fromOffset(length, thickness or 1)
	frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
end

return Shared
