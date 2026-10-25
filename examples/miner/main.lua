local count = legacy.get("stone") or 0

legacy.on("break", function(name, block)
    if block.id ~= 1 then
        return
    end
    count = count + 1
    legacy.set("stone", count)
    if count % 10 == 0 then
        legacy.message("*", "Mining Challenge: " .. count .. " stone blocks mined!")
    end
end)

legacy.command("progress", function(name, args)
    legacy.message(name, "Shared mining progress: " .. count .. " stone blocks")
end)

legacy.command("trade", function(name, args)
    local slots = legacy.inventory(name)
    if not slots then
        return
    end
    local room = false
    for slot = 1, 36 do
        local item = slots[slot]
        if not item then
            room = true
            break
        end
    end
    if not room then
        legacy.message(name, "Keep one inventory slot empty before trading")
        return
    end
    if legacy.take(name, 4, 16) ~= 16 then
        legacy.message(name, "Bring 16 plain cobblestone to trade for one apple")
        return
    end
    local sent, left = legacy.give(name, 260, 1)
    if sent == 1 then
        legacy.message(name, "Traded 16 cobblestone for one apple")
    else
        legacy.give(name, 4, 16)
        legacy.message(name, "Reward could not fit; attempted to return your cobblestone")
    end
end)
