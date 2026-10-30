local NamesModule = {}

function NamesModule.GetText(player, Config, distance)
    local text = ""
    if Config.ShowNames then
        text = player.DisplayName
    end
    if Config.ShowDistance then
        local distText = math.floor(distance) .. "m"
        text = (text ~= "" and (text .. " [" .. distText .. "]") or distText)
    end
    return text
end

return NamesModule