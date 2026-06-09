writer: gemini
---
# Project Overview

A comprehensive toolkit for retro 8-bit NES composition (MML) and modern text-based MIDI synthesis (ABC). Refactored for maximum portability and terminal independence.

## 🚀 Getting Started

Every tool in this suite is powered by Nix. Navigate to a station and run it via `nix run .`.

### 🎹 The Music Stations

| Station | Format | Style | Run Command |
| :--- | :--- | :--- | :--- |
| **Retro MML Old** (`/mml_retro_old`) | MML/NES | Classic Menu | `cd mml_retro_old && nix run .` |
| **Retro MML Rofi** (`/mml_retro_rofi`) | MML/NES | Smart Jukebox | `cd mml_retro_rofi && nix run .` |
| **ABC MIDI Rofi** (`/abc_midi_rofi`) | ABC/MIDI | Smart Jukebox | `cd abc_midi_rofi && nix run .` |
| **Python TUI** (`/tui_python`) | ABC/MIDI | `rmpc` Style | `cd tui_python && nix run .` |
| **Go TUI** (`/tui_go`) | ABC/MIDI | Minimalist TUI | `cd tui_go && nix run .` |

---

## 📂 Features (Smart Stations)

*   **`Enter`**: Play song in background (Truly invisible).
*   **`Ctrl + s`**: **Live Edit** (Opens `nvim` in-place + background watcher).
*   **`Ctrl + t`**: **Create New** file (In-place).
*   **`Ctrl + r`**: Rename.
*   **`Ctrl + x`**: Delete.

## 🛠️ Portability & User Preference

Lyrarium Symbolic is designed to be "zero-dependency" via Nix while remaining deeply respectful of your personal workflow.

### 🖥️ Terminal Independent
The suite does not require a specific terminal (like Ghostty or Alacritty). When launching the **Live Edit** feature, it automatically searches for available terminal emulators on your system (checking `$TERMINAL` first, then searching for `ghostty`, `alacritty`, `kitty`, `wezterm`, `foot`, etc.).

### 📝 Smart Editor Support
The suite intelligently selects which editor to use for your music files:
1.  **User Preference (`$EDITOR`)**: If you have the `$EDITOR` environment variable set, the suite will use it (allowing you to use Emacs, Vim, Nano, etc.).
2.  **System Native (`nvim`)**: If no `$EDITOR` is set, it tries to use the `nvim` found on your actual system to ensure your personal plugins and configurations are loaded.
3.  **Nix Fallback**: If no editor is found on your system, it falls back to a guaranteed Neovim binary provided by the Nix Flake.

All editing happens in a new terminal window, and all music playback happens in a secondary "Watcher" window for real-time visual feedback. It works on any machine with Nix and PulseAudio/PipeWire.
