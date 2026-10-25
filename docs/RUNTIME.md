# Runtime, execution, and limits

## Loading

The loader is compiled into the custom PC game. It starts while hosting a world, after the server has loaded its levels. It reads direct child folders of `%LOCALAPPDATA%\MinecraftLegacy\mods` in sorted path order. It considers at most 64 mod folders. Manifest ID conflicts reject the later folder. Each mod has its own Lua state and cannot directly access another mod's globals.

A folder needs `mod.json` (up to 16384 bytes) and UTF-8 `main.lua` (up to 1048576 bytes). Scripts are loaded in text mode; compiled Lua bytecode is rejected. A `disabled` marker file or manifest `enabled: false` prevents execution. Unsupported API versions, malformed manifests, and invalid saved data are shown as inactive errors in Dev Tools.

API 1 loads a single script file. Dependency management, automatic mod downloads, multi-file `require`, archive loading, and a shared cross-mod module registry are not implemented. Unknown manifest fields are ignored by the runtime, although the supplied schema highlights them as potential mistakes.

## Scheduling

All Lua states are owned by the server thread. The renderer only reads status snapshots and requests reloads. Network chat and player block hooks enqueue bounded notifications; they do not execute Lua on the rendering or network threads. The queue holds at most 64 pending notifications globally. Excess events can be dropped; do not use these events as an exact financial or item-ownership ledger.

Each event callback has a 50000-instruction budget and approximately 10 ms deadline, checked every 1000 Lua instructions. Initial script execution has 200000 instructions and approximately 25 ms. Native Lua library operations and engine calls are synchronous and are not preempted mid-call; avoid expensive string/pattern operations and huge world edits even within these limits. This is resource limiting, not a hard real-time guarantee.

Each callback can call API methods at most 128 times. A mod has at most 32 named commands and one handler per event. Each Lua state has a 16 MiB allocator limit. Memory/instruction/type errors disable the affected mod. Other mods continue. A disabled mod resumes only after a successful reload.

Host game operations, player lists, and dimensions are not Java objects. Lua receives copies and numeric IDs. Do not retain player snapshots expecting them to update. Query again after world events. Avoid keeping assumptions about player presence between callbacks.

## Exposed Lua environment

Lua 5.4.8 is embedded. Basic language operations and `math`, `string`, `table`, and `utf8` are available. Base features such as `pairs`, `ipairs`, `type`, `assert`, `error`, `tonumber`, `tostring`, and `select` are available.

The following are intentionally absent: `io`, `os`, `package`, `require`, `debug`, `coroutine`, `load`, `loadfile`, `dofile`, `collectgarbage`, `pcall`, `xpcall`, `print`, `setmetatable`, `getmetatable`, and `string.dump`. Error recovery and coroutines are not exposed because scripts must not bypass execution limits or keep execution alive across callbacks. Use `legacy.log` for diagnostics and API return values for expected missing players/chunks.

There is no raw filesystem, process-launch, HTTP, socket, native-library, or FFI API. This reduces accidental host access, but the loader is not a security boundary against engine bugs and mods can change hosted worlds through the supported gameplay API.

## Persistence

Mod data is written separately from worlds. Reload and world shutdown save dirty values, then close states. The loader stages writes through `<id>.json.tmp`; normal Windows file replacement is attempted during periodic flush, with a copy fallback if needed. Keep your own backups for valuable progress. File-system failures appear in mod status/logs; forced shutdown may skip persistence.

Storage values should remain small. Use stable keys. Changing a manifest ID creates a new data namespace and does not migrate the old file. Removing a mod does not delete its data. Changing a mod does not undo gameplay changes already applied to a world.

## Multiplayer

The host's loader controls the hosted server. Guests do not need the Lua scripts to see vanilla block, inventory, chat, time, or ability changes sent by normal game packets. API 1 does not synchronize custom textures/UI/content registries. A guest's local mods do not gain control over a remote host.

Only host-originated `/mod` command packets are queued as mod commands. Event handlers intentionally can respond to ordinary guest chat, joins, breaks, and interactions. Check the player's name and your own rules before granting rewards. There is no built-in roles/permissions system for mod-defined commands or API-level user identity stronger than the current player name.
