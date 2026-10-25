# Installing mods

## Requirements

- Windows 10/11, 64-bit.
- The custom Minecraft Legacy PC build with **Legacy Mods | Lua API 1** in Dev Tools.
- A mod containing `mod.json` and `main.lua`.

If Dev Tools has no Mods tab, your EXE predates the loader. Downloading these examples alone cannot add the loader to an unmodified game. This guide repository does not host the Minecraft executable.

## Install an example without coding

1. On this repository's home page choose **Code → Download ZIP**.
2. Extract the ZIP in File Explorer.
3. Start Minecraft and open Dev Tools with **`;`**.
4. Select **Mods → Open mods folder**.
5. Copy `examples/hello` into that folder. Copy the `hello` folder itself, not the whole repository.
6. Host or load a world. The Mods tab should show **Hello Legacy / Active: Loaded**.
7. Open Minecraft chat using your normal chat binding and enter `/mod hello:hello`.

Expected result: the game prints a greeting and increments a saved counter. This example does not change blocks or inventory.

The default folder is:

```text
%LOCALAPPDATA%\MinecraftLegacy\mods
```

Paste that path into File Explorer's address bar. Do not install mods in the EXE folder, `Windows64/GameHDD`, `.minecraft/mods`, or a world save directory.

## Optional installer

Open PowerShell in the extracted repository and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\install.ps1 -mod hello
```

The installer only copies a bundled example to AppData. If the destination exists, it stops instead of replacing your edits. Manual installation works without changing PowerShell execution settings.

## Disable, update, remove

- Disable: create an empty file named `disabled` with no extension inside the mod folder, or set `"enabled": false` in its manifest. Reload mods.
- Update: save/close the world, back up the mod folder and its data file, then replace the mod's files. Keep the same manifest ID to retain saved mod data.
- Remove: move the mod folder out of `mods`, then reload. The loader retains its `moddata/<id>.json` file so reinstalling can restore progress.
- Reload: select **Dev Tools → Mods → Reload mods** while hosting. It runs unload handlers, saves data, closes all mod states, rescans folders, and creates new states. Existing players receive join callbacks again. Module locals and tick counters reset.

Reload is a development convenience. It does not undo blocks, items, flight permissions, or other changes a mod already made. Test world-changing mods on a copy of a world first.

## Package a mod

Share a ZIP containing one top-level mod folder with `mod.json` and `main.lua`. Users extract that folder into `mods`. The loader reads folders; it does not execute ZIP files or auto-extract archives. Keep all script code in `main.lua` for API 1. `require` and filesystem access are unavailable.

Only install mods whose behavior you trust. The scripting environment excludes OS/file/network APIs, but installed gameplay mods can intentionally change a hosted world through the supported API.
