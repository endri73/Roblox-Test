local DistanceModule = {}

function DistanceModule.Calculate(camera, targetPosition)
    return (targetPosition - camera.CFrame.Position).Magnitude
end

return DistanceModule