# Minecraft Legacy Modding

Write and install gameplay mods for the custom **Windows 64-bit Minecraft Legacy PC build**, without downloading or compiling the game source. Mods are plain Lua 5.4 files plus a small JSON manifest.

This repository contains the API documentation, original example mods, schemas, and editor setup. It does not distribute Minecraft source, game assets, game binaries, or personal saves. You need the custom game build that includes **Dev Tools → Mods → Legacy Mods | Lua API 1**. Stock Legacy Console Edition and other PC ports do not automatically support this loader.

## Start here

1. [Install your first mod](docs/INSTALL.md).
2. [Write a mod in ten minutes](docs/TUTORIAL.md).
3. [Detailed API reference](docs/API.md).
4. [Events, execution, and limits](docs/RUNTIME.md).
5. [Troubleshooting](docs/TROUBLESHOOTING.md).
6. [Example mods](examples/README.md).

Press **`;`** or the configured **PS4 touchpad shortcut** to open Dev Tools. Select **Mods → Open mods folder**. Copy a mod folder there, host a world, and select **Reload mods** after edits.

```text
%LOCALAPPDATA%\MinecraftLegacy\mods\hello\
    mod.json
    main.lua
```

Mod data lives in `%LOCALAPPDATA%\MinecraftLegacy\moddata`, outside the EXE installation folder. Updating the game does not replace installed mods or their data.

## What can mods do?

- Register namespaced chat commands, such as `/mod builder:platform`.
- Respond to players joining, leaving, chatting, breaking blocks, and interacting with blocks.
- Run tick-based gameplay rules.
- Read players, positions, health, dimensions, inventory, and registered item stack sizes.
- Give or take existing items, heal players, teleport, and grant flight.
- Read and change loaded blocks, time, and weather.
- Send Minecraft chat messages and save small per-mod settings and progress.

Mods run on the host's server thread. Joining a remote server does not let a client mod change that server. Mod commands are host-only in API 1; event handlers can intentionally affect guests in a world you host.

## Relationship to Java modding

The workflow is similar: install separate mods, use an API, and update mods independently of game source. This is a **Lua gameplay API**, not Forge, Fabric, NeoForge, or a Java virtual machine. Existing `.jar` mods do not work. API 1 does not register new item/block IDs, entities, textures, dimensions, crafting recipes, renderer hooks, arbitrary native DLLs, or custom GUI screens. Use existing registered game content. Those features need additional engine integration and are not promised by this release.

Lua is embedded in the game; installing Lua, Java, Visual Studio, or the game source is unnecessary. An editor such as VS Code or Notepad is sufficient.

## Versioning

Set `"api": 1` in every manifest. Unsupported API versions are rejected rather than silently executed. Breaking changes will require a new API number. Example version strings belong to the mod author; the loader displays them and does not interpret semantic version ranges.

See [CHANGELOG.md](CHANGELOG.md) and [LICENSE](LICENSE). The MIT license covers this repository's original documentation, tools, and examples, not Minecraft or third-party software.
