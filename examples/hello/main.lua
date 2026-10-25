legacy.on("load", function(tick)
    legacy.log("Hello Legacy is ready")
end)

legacy.on("join", function(name)
    legacy.message(name, "Hello Legacy loaded! Try /mod hello:hello")
end)

legacy.command("hello", function(name, args)
    local val = (legacy.get("greetings") or 0) + 1
    legacy.set("greetings", val)
    legacy.message(name, "Hello from a Lua mod, " .. name .. "! Greeting #" .. val)
end)
