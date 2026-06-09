author: gemini
---
# Rofi Composer (Editor-less Station)

A high-speed musical sketchpad inspired by `cliphist`. Manage and compose ABC music entirely within Rofi prompts without opening a text editor.

## Features
*   **Integrated Rofi Editor:** Edit the entire content of your music files directly within a Rofi input box—no text editor required.
*   **Auto-Kill Playback:** Background music automatically stops after 45 seconds to prevent background noise.
*   **Rapid Management:** Rename or delete files instantly.

## Usage
Execute directly using Nix:
```bash
nix run .
```

## Hotkeys (in Rofi)
*   **Enter:** Play song in background (Auto-kills after 45s).
*   **Ctrl+s:** Open Live Edit mode (Nvim).
*   **Ctrl+t:** Create New ABC file.
*   **Ctrl+r:** Rename file.
*   **Ctrl+x:** Delete file.

## Dependencies
Self-contained via Nix. Requires **Rofi**, **Ghostty**, and **PulseAudio** on the host.
