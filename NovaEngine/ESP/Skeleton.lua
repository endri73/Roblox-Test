local Camera = workspace.CurrentCamera

local R6_CONNECTIONS = {
    {"Head","Torso"},
    {"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}
local R15_CONNECTIONS = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local function Build()
    local skeletons = {}

    local function getConns(char)
        return char:FindFirstChild("UpperTorso") and R15_CONNECTIONS or R6_CONNECTIONS
    end

    local function GetOrCreate(player, char)
        if skeletons[player] then return skeletons[player] end
        local conns = getConns(char)
        local entry = { lines = {}, connections = conns }
        for i = 1, #conns do
            local line        = Drawing.new("Line")
            line.Thickness    = 1.5
            line.Transparency = 0      -- e plotë
            line.Visible      = false
            entry.lines[i]    = line
        end
        skeletons[player] = entry
        return entry
    end

    local function Update(player, char, config, inRange)
        local entry = GetOrCreate(player, char)
        if not config.ShowSkeleton or not inRange then
            for _, l in ipairs(entry.lines) do l.Visible = false end
            return
        end
        for i, conn in ipairs(entry.connections) do
            local pA = char:FindFirstChild(conn[1])
            local pB = char:FindFirstChild(conn[2])
            local ln = entry.lines[i]
            if pA and pB then
                local sA, oA = Camera:WorldToViewportPoint(pA.Position)
                local sB, oB = Camera:WorldToViewportPoint(pB.Position)
                if oA and oB then
                    ln.From    = Vector2.new(sA.X, sA.Y)
                    ln.To      = Vector2.new(sB.X, sB.Y)
                    ln.Color   = config.SkeletonColor or config.ESPColor or Color3.fromRGB(108,92,231)
                    ln.Visible = true
                else
                    ln.Visible = false
                end
            else
                ln.Visible = false
            end
        end
    end

    local function Hide(player)
        if skeletons[player] then
            for _, l in ipairs(skeletons[player].lines) do l.Visible = false end
        end
    end

    local function Cleanup(player)
        if skeletons[player] then
            for _, l in ipairs(skeletons[player].lines) do
                pcall(function() l:Remove() end)
            end
            skeletons[player] = nil
        end
    end

    local function CleanupAll()
        for p in pairs(skeletons) do Cleanup(p) end
    end

    return { Update = Update, Hide = Hide, Cleanup = Cleanup, CleanupAll = CleanupAll }
end

return Build