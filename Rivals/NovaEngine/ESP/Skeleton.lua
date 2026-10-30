local Camera = workspace.CurrentCamera

-- lidhjet e kockave për Roblox R6 dhe R15
local R6_CONNECTIONS = {
    {"Head",        "Torso"},
    {"Torso",       "Left Arm"},
    {"Torso",       "Right Arm"},
    {"Torso",       "Left Leg"},
    {"Torso",       "Right Leg"},
}

local R15_CONNECTIONS = {
    {"Head",            "UpperTorso"},
    {"UpperTorso",      "LowerTorso"},
    {"UpperTorso",      "LeftUpperArm"},
    {"LeftUpperArm",    "LeftLowerArm"},
    {"LeftLowerArm",    "LeftHand"},
    {"UpperTorso",      "RightUpperArm"},
    {"RightUpperArm",   "RightLowerArm"},
    {"RightLowerArm",   "RightHand"},
    {"LowerTorso",      "LeftUpperLeg"},
    {"LeftUpperLeg",    "LeftLowerLeg"},
    {"LeftLowerLeg",    "LeftFoot"},
    {"LowerTorso",      "RightUpperLeg"},
    {"RightUpperLeg",   "RightLowerLeg"},
    {"RightLowerLeg",   "RightFoot"},
}

local function Build()
    local skeletons = {}  -- [player] = { lines = {Line,...} }

    local function getConnections(char)
        if char:FindFirstChild("UpperTorso") then
            return R15_CONNECTIONS
        end
        return R6_CONNECTIONS
    end

    local function GetOrCreate(player, char)
        if skeletons[player] then return skeletons[player] end
        local conns  = getConnections(char)
        local entry  = { lines = {}, connections = conns }
        for i = 1, #conns do
            local line        = Drawing.new("Line")
            line.Thickness    = 1
            line.Transparency = 0.2
            line.Visible      = false
            entry.lines[i]    = line
        end
        skeletons[player] = entry
        return entry
    end

    local function Update(player, char, config, inRange)
        local entry = GetOrCreate(player, char)
        if not config.ShowSkeleton or not inRange then
            for _, line in ipairs(entry.lines) do line.Visible = false end
            return
        end
        for i, conn in ipairs(entry.connections) do
            local partA = char:FindFirstChild(conn[1])
            local partB = char:FindFirstChild(conn[2])
            local line  = entry.lines[i]
            if partA and partB then
                local posA, onA = Camera:WorldToViewportPoint(partA.Position)
                local posB, onB = Camera:WorldToViewportPoint(partB.Position)
                if onA and onB then
                    line.From    = Vector2.new(posA.X, posA.Y)
                    line.To      = Vector2.new(posB.X, posB.Y)
                    line.Color   = config.SkeletonColor
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end

    local function Hide(player)
        if skeletons[player] then
            for _, line in ipairs(skeletons[player].lines) do
                line.Visible = false
            end
        end
    end

    local function Cleanup(player)
        if skeletons[player] then
            for _, line in ipairs(skeletons[player].lines) do
                pcall(function() line:Remove() end)
            end
            skeletons[player] = nil
        end
    end

    local function CleanupAll()
        for player in pairs(skeletons) do
            Cleanup(player)
        end
    end

    return {
        Update     = Update,
        Hide       = Hide,
        Cleanup    = Cleanup,
        CleanupAll = CleanupAll,
    }
end

return Build