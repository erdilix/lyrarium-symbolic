# Retro MML (Smart Rofi Station)

A modern, high-speed workstation for developing NES/Famicom music using MML (Music Macro Language) and Rofi.

## Features
*   **Truly Invisible Playback:** Background music plays silently without terminal popups.
*   **Integrated Management:** Rename, Delete, or Create new MML files directly from the Jukebox.
*   **Live Edit Mode:** Integrated Neovim workflow with background watchers for real-time feedback.

## Usage
Execute directly using Nix:
```bash
nix run .
```

## Hotkeys (in Rofi)
*   **Enter:** Play song in background (Invisible).
*   **Control + s:** Open Live Edit mode (Neovim + Watcher).
*   **Control + t:** Create New MML file.
*   **Control + r:** Rename file.
*   **Control + x:** Delete file.

## Dependencies
Self-contained via Nix. Requires **Rofi**, **Ghostty**, and **PulseAudio** on the host.
