legacy.command("platform", function(name, args)
    local plr = legacy.player(name)
    if not plr then
        return
    end
    local x = math.floor(plr.x)
    local y = math.floor(plr.y) - 1
    local z = math.floor(plr.z)
    if y < 0 or y > 254 then
        legacy.message(name, "Move away from the world's height limits first")
        return
    end
    local count = 0
    for dx = -1, 1 do
        for dz = -1, 1 do
            local id = legacy.block(plr.dim, x + dx, y, z + dz)
            if id == 0 and legacy.setblock(plr.dim, x + dx, y, z + dz, 20) then
                count = count + 1
            end
        end
    end
    legacy.message(name, "Placed " .. count .. " glass blocks in empty space below you")
end)

legacy.command("day", function(name, args)
    local plr = legacy.player(name)
    if plr then
        legacy.time(plr.dim, 1000)
        legacy.message(name, "Daytime set")
    end
end)

legacy.command("clear", function(name, args)
    local plr = legacy.player(name)
    if plr then
        legacy.weather(plr.dim, "clear")
        legacy.message(name, "Weather cleared")
    end
end)
