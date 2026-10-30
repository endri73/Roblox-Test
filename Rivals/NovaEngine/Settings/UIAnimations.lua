local UIAnimationsModule = {}
local TweenService = game:GetService("TweenService")

function UIAnimationsModule.Tween(obj, props, duration, Config)
    if not Config.UIAnimations or Config.PerformanceMode then
        for k, v in pairs(props) do obj[k] = v end
        return
    end
    TweenService:Create(obj, TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

return UIAnimationsModule