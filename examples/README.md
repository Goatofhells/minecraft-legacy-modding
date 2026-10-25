# Example mods

Copy a single example folder to `%LOCALAPPDATA%\MinecraftLegacy\mods`, then host a world or reload mods. These mods are original Lua scripts licensed under MIT. They do not need the game source or a compiler.

| Folder | Behavior | Commands |
|---|---|---|
| `hello` | Greets joining players and saves a global greeting count | `/mod hello:hello` |
| `builder` | Creates a small glass platform only in air; controls time/weather | `/mod builder:platform`, `/mod builder:day`, `/mod builder:clear` |
| `miner` | Counts successful stone breaks across all players/worlds; trades plain cobblestone for apples | `/mod miner:progress`, `/mod miner:trade` |

Only `hello` is installed by default with the custom PC update. The others are opt-in demonstrations. Builder changes your world; uninstalling it does not remove previously placed glass. Miner uses global per-mod storage, so progress carries across worlds intentionally. Its trade requires an empty main-inventory slot and uses all-or-nothing item removal.

The block event counter counts what the server reports; API 1 queues can drop excess notifications. Do not treat the example as an anti-cheat or exact accounting system.
