# Legacy Lua API 1

All calls are made through the global `legacy` table. Use dot syntax. All game operations run synchronously on the host server thread. Tables returned by the API are snapshots, not live objects: changing a Lua table does not change the game.

The API is available at script startup and in callbacks. At startup, the world exists but there may be no players yet; player-specific operations belong in `join`, commands, or ticks. Invalid argument types, out-of-range numbers, and unknown event names raise a script error and disable the mod. Expected runtime absences generally return `nil, reason` or `false`, as listed below. Check results before continuing.

## Constants

| Field | Type | Meaning |
|---|---|---|
| `legacy.api` | integer | API version, currently `1` |
| `legacy.id` | string | This mod's validated manifest ID |

## Events and commands

### `legacy.on(event, callback)`

Registers one function for an event. Registering the same event again replaces its previous handler. Returns no values. Supported events:

| Event | Callback arguments | Timing |
|---|---|---|
| `load` | `tick` | Once after `main.lua` executes; tick is `0` |
| `tick` | `tick` | Once each server tick, starting at `1` |
| `join` | `name` | Player appears in the host player list |
| `leave` | `name` | Player no longer appears; player lookup can already return nil |
| `chat` | `name, text` | A player sends ordinary, non-command Minecraft chat |
| `break` | `name, block` | A player successfully destroys a block |
| `use` | `name, block` | A player attempts a block interaction using the server's item-on-block path |
| `unload` | no arguments | Normal world close or Reload mods, while the world is still available |

`name` is the exact UTF-8 player name. `block` is a table with integer fields `dim`, `x`, `y`, `z`, `id`, `aux`, `face`. Break contains the removed block's previous ID/variant; `face` is unused and zero. Use contains the clicked block snapshot and clicked face. Use is an attempt notification: the game can subsequently reject the interaction, and it is not a guaranteed block-place event. Tooltip-only tests do not generate use events.

Queued events run on the next mod processing pass and are **notifications, not cancellable hooks**. Callback return values are ignored. Mod API `setblock` changes do not generate player break/use events. Chat from Twitch or `legacy.message` does not generate player chat events. A player who disconnects before an event is processed can have queued notifications dropped.

Execution order per mod: joins, leaves, queued chat/command/block events, then tick. Mods load in folder-name order; do not depend on cross-mod side effects. After reload, current players receive join again. Unload is best effort and is skipped for a mod already disabled by an error; no unload runs after a process crash or forced termination.

### `legacy.command(name, callback)`

Registers a command local to this mod. Name: 1–32 lowercase ASCII letters, digits, `_`, `-`. Up to 32 commands per mod. Re-registering the same name replaces its callback. Returns no values.

Invocation: `/mod <mod-id>:<command> [arguments]`. Callback arguments: `player_name, arguments_string`. The argument string contains all text after the command's first separating space, or `""` when absent. Parse arguments explicitly with Lua string functions. Commands are exact and case-sensitive. API 1 only accepts command packets from the world's host. Ordinary guest chat still reaches chat callbacks.

```lua
legacy.command("hello", function(name, args)
    legacy.message(name, args == "" and "Hello!" or args)
end)
```

## Player queries

### `legacy.players()` → `names`

Returns a 1-indexed array of currently connected player-name strings. Empty table when no players are available. Order follows the game player list and is not a stable identity.

### `legacy.player(name)` → `player` or `nil, reason`

Returns a snapshot table:

| Field | Type | Meaning |
|---|---|---|
| `x`, `y`, `z` | number | Position in blocks |
| `health` | number | Current health; normally 20 is full |
| `dim` | integer | `0` overworld, `-1` Nether, `1` End |
| `flight` | boolean | Whether the player may fly |

Unavailable players return `nil, "Player unavailable"`. No wildcard names are accepted here. Name arguments are limited to 128 bytes.

### `legacy.inventory(name)` → `slots` or `nil, reason`

Returns a sparse table indexed by **inventory slot + 1**. It contains the main inventory and hotbar, not armor or cursor-held inventory. An occupied slot contains `{id = integer, count = integer, aux = integer}`. Empty slots are absent/nil. Use `pairs(slots)` or an explicit slot loop, not `ipairs`, because holes end `ipairs` iteration. It does not expose item NBT, names, enchantments, or a writable inventory reference.

### `legacy.item(id)` → `item` or `nil`

Queries an existing registered item ID. Returns `{id = integer, stack = integer}` or nil for an unregistered ID. `stack` is that item's maximum stack size. This call does not register an item. IDs are the numeric IDs in this legacy build, not modern Java resource locations.

## Player changes

### `legacy.message(name, text)` → `boolean`

Sends a Minecraft chat packet to a player. Use `"*"` as the name to broadcast to all players in the hosted world. Maximum text length: 512 UTF-8 bytes. Embedded NUL is rejected. Returns false if the named player is unavailable; true if queued to an existing connection or broadcast. It is not a Twitch message and does not post outside Minecraft.

### `legacy.give(name, id, count = 1, aux = 0)` → `delivered, remaining` or `nil, reason`

Adds an existing registered item. Count: 1–2304. Aux/damage: 0–32767. Fills compatible non-damaged, untagged stacks first, then empty main-inventory slots. It never overwrites another item. Large requests split across slots using the item's actual maximum stack size. Returns how many were delivered and how many did not fit. Nothing drops on the ground automatically.

```lua
local sent, left = legacy.give(name, 264, 5)
if sent and left > 0 then
    legacy.message(name, "Make room for " .. left .. " more diamonds")
end
```

### `legacy.take(name, id, count = 1, aux = 0)` → `removed` or `nil, reason`

Consumes matching items from the main inventory. Same argument bounds as give. Ignores damaged or tagged items. If insufficient matching items exist, returns 0 and removes nothing. Otherwise removes the full requested count and returns that count. This is suitable for an all-or-nothing shop input. Do not assume a subsequent reward will fit; give reports partial delivery.

### `legacy.heal(name)` → `true` or `nil, reason`

Restores maximum health, food level 20, saturation 20, and exhaustion 0 for an available player. Does not resurrect a disconnected player or cancel death events.

### `legacy.teleport(name, x, y, z)` → `true` or `nil, reason`

Uses the server connection's normal teleport handling, retaining current yaw/pitch. Coordinates must be finite. X/Z: -30,000,000 through 30,000,000; Y: 0 through 255. The game's actual world boundaries still apply. Does not change dimension or find safe ground. True means the teleport request was issued, not that the destination is safe.

### `legacy.flight(name, enabled)` → `true` or `nil, reason`

Requires a boolean `enabled`. Updates host flight privileges and broadcasts player abilities. Enabling permits the normal double-jump flight toggle; it does not force the player into flight immediately. Disabling preserves creative mode's inherent flight permission. Changes remain until changed by the game, another mod, or an explicit call; unloading the mod does not revert permissions.

## World queries and changes

Dimensions are integer `0`, `-1`, or `1`. If the requested dimension is unavailable, these calls return `nil, "Dimension unavailable"`. Integer arguments must fit signed 32-bit range; integer-required arguments reject fractions.

### `legacy.block(dim, x, y, z)` → `id, aux` or `nil, reason`

Reads an existing loaded block. X/Z within ±30,000,000; Y from 0 through the dimension's height minus 1. Does not load/generate chunks. An unloaded chunk returns `nil, "Chunk not loaded"`. Air returns `0, 0`; zero is a valid ID and is truthy in Lua.

### `legacy.setblock(dim, x, y, z, id, aux = 0)` → `changed` or `nil, reason`

Same position bounds and loaded-chunk requirement as block. ID must be air `0` or an existing registered block ID. Aux is 0–15. Uses the game's normal block update flags `3`, notifying clients and neighboring blocks. Returns the game's change result; false can mean the requested block was already present. Does not invent block IDs or preserve a replaced block entity's data. Avoid overwriting containers and test destructive mods on a copy of a world.

### `legacy.time(dim [, ticks])` → `ticks` or `nil, reason`

Without ticks: read day time. With ticks: set the selected dimension's day time, then return it. Setter range: 0–2,147,483,647. Typical values: 1000 day, 6000 noon, 13000 night, 18000 midnight. A day is 24000 game ticks. This is day time, not the world's total age.

### `legacy.weather(dim, state)` → `true` or `nil, reason`

State is exactly `"clear"`, `"rain"`, or `"storm"`. Sets rain/thunder flags and their timers to 12000 ticks on the selected level data. Weather may not visibly render in a dimension or biome that does not support it. It does not return the previous weather.

## Saved data and logs

### `legacy.get(key)` → `value` or `nil`

Reads the mod's private stored value. Key: 1–64 UTF-8 bytes. Returns a string, finite number, boolean, or nil. No default argument; use `legacy.get("key") or default` when false is not a meaningful saved value. Prefer an explicit nil check when false matters.

### `legacy.set(key, value)`

Saves a string (up to 4096 bytes), finite number, boolean, or nil. Nil deletes the key. Tables, functions, userdata, and non-finite numbers are rejected. The entire serialized per-mod data object is limited to 65536 bytes. Oversized updates raise an error and do not commit the update.

Data location: `%LOCALAPPDATA%\MinecraftLegacy\moddata\<id>.json`. Scope is per installation profile and mod ID, shared across worlds. Dirty data flushes every 100 server ticks and on normal reload/world close. A crash before a flush can lose recent changes. Do not use this as a transaction log or secret store. Invalid/corrupted saved JSON disables the mod with an error; back it up before repairing it.

### `legacy.log(text)`

Writes a line prefixed with the mod ID to `%LOCALAPPDATA%\MinecraftLegacy\mods.log`. At most 512 bytes per call; longer text is truncated. At most 8 log lines per mod processing pass; further lines are ignored. Logs rotate after approximately 2 MiB to `mods.previous.log` on a processing pass. Use for diagnostics, not every-frame telemetry. Returns no values.

## Basic existing IDs

Check IDs with `legacy.item(id)` or the game's Dev Tools item picker. This list describes existing vanilla content; it does not reserve mod IDs.

| ID | Content |
|---|---|
| 1 | Stone |
| 3 | Dirt |
| 4 | Cobblestone |
| 5 | Wood planks, variant selects wood type |
| 20 | Glass |
| 46 | TNT |
| 50 | Torch |
| 260 | Apple |
| 264 | Diamond |
| 265 | Iron ingot |
| 266 | Gold ingot |
| 276 | Diamond sword |
| 278 | Diamond pickaxe |

API limits and failure behavior are part of the API contract. See [RUNTIME.md](RUNTIME.md) before building large or multiplayer mods.
