local FOVModule = {}
local UserInputService = game:GetService("UserInputService")

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Transparency = 0.7
fovCircle.Thickness = 1.5
fovCircle.Filled = false

function FOVModule.Update(Config, uiVisible)
    if Config.AimbotEnabled and uiVisible then
        local mousePos = UserInputService:GetMouseLocation()
        fovCircle.Position = mousePos
        fovCircle.Radius = Config.FieldOfView
        fovCircle.Color = Config.AimbotAccent
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end

function FOVModule.Destroy()
    pcall(function() fovCircle:Remove() end)
end

return FOVModule