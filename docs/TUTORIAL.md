# Your first gameplay mod

No game source or compiler is required. Create a folder named `my-mod` inside `%LOCALAPPDATA%\MinecraftLegacy\mods`.

## 1. Add the manifest

Create `mod.json`:

```json
{
  "id": "my_mod",
  "name": "My First Mod",
  "version": "1.0.0",
  "api": 1,
  "enabled": true
}
```

`id` is a stable namespace, 1–48 characters using lowercase letters, digits, `_` or `-`. It must be unique across installed mods. The folder name can differ, but the manifest ID determines commands and saved data. `name` and `version` are required display strings. Keep the JSON valid: double quotes, no trailing commas, no comments. See [the schema](../schemas/mod.schema.json).

## 2. Add the script

Create `main.lua`:

```lua
legacy.on("load", function()
    legacy.log("My First Mod loaded")
end)

legacy.on("join", function(name)
    legacy.message(name, "My First Mod is active. Try /mod my_mod:day")
end)

legacy.command("day", function(name, args)
    local plr = legacy.player(name)
    if not plr then
        return
    end
    legacy.time(plr.dim, 1000)
    legacy.message(name, "Daytime set by My First Mod")
end)
```

Use **`legacy.function(...)` with a dot**, not `legacy:function(...)`. `legacy` is provided by the game. Callbacks receive player names as UTF-8 strings, not player objects. Query `legacy.player(name)` for a fresh snapshot when needed.

## 3. Load and test

Host a world, open Dev Tools, and select **Mods → Reload mods**. Check the status for your mod. Enter `/mod my_mod:day` in Minecraft chat. The current dimension's time becomes 1000 ticks.

Edit `main.lua`, save it, and reload again. A script error appears in the Mods tab and `%LOCALAPPDATA%\MinecraftLegacy\mods.log`. A failed callback disables that mod until reload; the other mods continue.

## 4. Remember progress

Use the mod's private key/value storage:

```lua
legacy.command("count", function(name, args)
    local val = (legacy.get("count") or 0) + 1
    legacy.set("count", val)
    legacy.message(name, "Saved count: " .. val)
end)
```

Storage belongs to the manifest ID and persists across worlds, restarts, and EXE updates. It is not automatically per-player or per-world. For per-player values, derive a short storage key from a player name and respect the 64-byte key limit. API 1 does not expose stable account IDs or world IDs.

## 5. Use tick events carefully

```lua
legacy.on("tick", function(tick)
    if tick % 200 ~= 0 then
        return
    end
    for _, name in ipairs(legacy.players()) do
        local plr = legacy.player(name)
        if plr and plr.y < 5 then
            legacy.message(name, "Careful near the bottom of the world")
        end
    end
end)
```

Ticks normally run at 20 per second while the server is advancing. Lag and pausing affect wall-clock timing. Keep callbacks short; do not sleep, busy-wait, or do large block loops.

## Editor setup

The repository includes `.luarc.json`, VS Code snippets, and `api/legacy.lua` type metadata for Lua Language Server autocomplete. Open the repository in VS Code and optionally install its Lua language extension. The metadata file is editor-only; do not copy it into your mod or execute it as a script. Lua syntax reference: [official Lua 5.4 manual](https://www.lua.org/manual/5.4/manual.html). The game exposes only the libraries listed in [RUNTIME.md](RUNTIME.md), not every standard Lua feature.
