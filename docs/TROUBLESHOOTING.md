# Troubleshooting

| Symptom | Check |
|---|---|
| No Mods tab | The EXE must include the custom API 1 loader. This repository alone does not modify a stock game. |
| No mods listed | Host a world. Confirm the immediate child folder contains `mod.json` and `main.lua`; avoid an extra nested ZIP/repository folder. |
| Reload button disabled | You must host an active world. Joining someone else's server does not start the loader. |
| Disabled status | Remove the `disabled` marker or change manifest `enabled` to true. Reload. |
| Unsupported API | The manifest API number and game loader do not match. API 1 requires `"api": 1`. |
| Invalid/duplicate ID | Use 1–48 lowercase letters/digits/underscores/hyphens and a unique manifest ID. |
| Syntax or callback error | Read the mod's status and `mods.log`; line numbers refer to `main.lua`. Save the corrected file and reload. |
| Callback budget exceeded | Remove long loops. Split work across ticks and avoid busy-waits. |
| Not enough memory | Reduce large strings/tables. Each mod state is capped at 16 MiB. |
| API call budget exceeded | At most 128 API calls per callback. Process smaller batches. |
| Storage limit exceeded | Keep keys/values small; total serialized data is 64 KiB per mod. |
| Saved data error | Back up `moddata/<id>.json`. Repair valid JSON or move it aside to reset that mod's data. |
| Command does nothing | Use the exact manifest namespace, e.g. `/mod hello:hello`, in Minecraft chat. Host commands only. Check the mod is active and the command is registered. Unknown commands are ignored in API 1. |
| `require`, `io`, or `os` missing | Those libraries are not exposed. Keep API 1 code in `main.lua` and use `legacy.get/set`. |
| A Java mod won't load | `.jar`, Forge, and Fabric mods are incompatible. Port supported behavior to Lua. |
| Items not given | Check the return values, item ID, variant, and inventory space. Give never overwrites existing items. |
| Empty inventory iteration | Use `pairs` on the sparse inventory table rather than `ipairs`. |
| Chunk not loaded | Operate near connected players in an already loaded chunk. API 1 does not force chunk generation. |
| Flight did not start | The API grants permission. Double-tap the normal jump control to enter flight. |
| Block event count differs | The bounded notification queue can drop events during bursts or disconnects. Events are not an exact audit trail. |
| Progress changed across worlds | Storage is global per mod ID, not per-world. This is intentional in API 1. |

## Reporting a problem

Include the custom game build/API number, mod manifest, smallest script that reproduces it, the action taken, and the mod's error line. Remove private chat, player information, or secrets from logs before sharing. Never upload saves unless you intend to share them.

## Before updating the game

Keep mods and data in AppData, not beside the EXE. Back up `%LOCALAPPDATA%\MinecraftLegacy` when preserving important worlds. The loader does not replace worlds/settings while installing examples or reloading scripts.
