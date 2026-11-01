local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local function Build(config, espCache, Markers, Distance, Lines, Skeleton, closed)
    local player = Players.LocalPlayer

    RunService.RenderStepped:Connect(function()
        if closed() then return end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local char  = p.Character
                local alive = char
                    and char:FindFirstChild("HumanoidRootPart")
                    and char:FindFirstChild("Head")
                    and char:FindFirstChild("Humanoid")
                    and char.Humanoid.Health > 0

                if alive then
                    local hrp     = char.HumanoidRootPart
                    local dist    = Distance.GetDist(hrp)
                    local inRange = dist <= config.DisplayRange

                    if inRange then
                        local esp = espCache[p]
                        if not esp then
                            esp = {
                                Highlight = Markers.CreateHighlight(char),
                                Billboard = Instance.new("BillboardGui"),
                                NameLabel = Instance.new("TextLabel"),
                            }
                            esp.Billboard.Size        = UDim2.new(0,100,0,50)
                            esp.Billboard.StudsOffset = Vector3.new(0,2.5,0)
                            esp.Billboard.AlwaysOnTop = true
                            esp.Billboard.Parent      = char

                            esp.NameLabel.Size                   = UDim2.fromScale(1,1)
                            esp.NameLabel.BackgroundTransparency = 1
                            esp.NameLabel.TextColor3             = Color3.fromRGB(255,255,255)
                            esp.NameLabel.TextStrokeTransparency = 0
                            esp.NameLabel.TextStrokeColor3       = Color3.new(0,0,0)
                            esp.NameLabel.TextSize               = 14
                            esp.NameLabel.Font                   = Enum.Font.GothamBold
                            esp.NameLabel.Parent                 = esp.Billboard
                            espCache[p] = esp
                        end

                        -- highlight me transparency më të ulët
                        esp.Highlight.Enabled          = config.ShowMarkers
                        esp.Highlight.FillColor        = config.ESPColor or config.MarkerColor
                        esp.Highlight.OutlineColor     = config.ESPColor or config.MarkerColor
                        esp.Highlight.FillTransparency = 0.65
                        esp.Highlight.OutlineTransparency = 0

                        local label           = Distance.FormatLabel(p, dist, config)
                        esp.NameLabel.Text    = label
                        esp.NameLabel.Visible = (config.ShowNames or config.ShowDistance) and label ~= ""

                        Lines.Update(p, hrp, config, true)
                        Skeleton.Update(p, char, config, true)
                    else
                        if espCache[p] then
                            espCache[p].Highlight.Enabled = false
                            espCache[p].NameLabel.Visible  = false
                        end
                        Lines.Hide(p)
                        Skeleton.Hide(p)
                    end
                else
                    if espCache[p] then
                        espCache[p].Highlight.Enabled = false
                        espCache[p].NameLabel.Visible  = false
                    end
                    Lines.Hide(p)
                    Skeleton.Hide(p)
                end
            end
        end
    end)
end

return Build