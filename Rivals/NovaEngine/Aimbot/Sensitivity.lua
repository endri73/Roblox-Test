local SensitivityModule = {}

function SensitivityModule.Apply(Config, value)
    Config.Sensitivity = math.clamp(value, 1, 100)
end

return SensitivityModule