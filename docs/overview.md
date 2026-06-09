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

## 🛠️ Terminal Independent
This suite no longer requires **Ghostty** or any specific terminal. All editing happens in your **existing** window, and all music playback happens silently in the background. It works on any machine with Nix and PulseAudio.
