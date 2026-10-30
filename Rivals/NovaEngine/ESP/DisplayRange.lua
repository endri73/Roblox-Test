local DisplayRangeModule = {}

function DisplayRangeModule.IsInRange(distance, maxRange)
    return distance <= maxRange
end

return DisplayRangeModule