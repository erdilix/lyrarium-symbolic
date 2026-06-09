author: gemini
---
# Architecture v2: Standalone Music Stations

## Overview
The project has been refactored into four independent, standalone repositories. Each directory is a complete Nix project that can be executed on any Linux machine using `nix run .`.

## The 4 Independent Projects

### 1. Retro MML Station (`/mml_retro_rofi`)
*   **Purpose:** Legacy NES (MML) development.
*   **Keys:** `Enter` to Play, `Ctrl+s` to Live Edit via Neovim, `Ctrl+t` for New MML.

### 2. ABC MIDI Station (`/abc_midi_rofi`)
*   **Purpose:** Text-to-MIDI (ABC) development.
*   **Keys:** `Enter` to Play, `Ctrl+s` to Live Edit, `Ctrl+t` for New ABC.

### 3. ABC Python TUI (`/tui_python`)
*   **Tech Stack:** Python, Textual.
*   **Features:** Modern `rmpc`-inspired dashboard with sidebar library.

### 4. ABC Go TUI (`/tui_go`)
*   **Tech Stack:** Go, Bubbletea.
*   **Features:** Minimalist, high-performance terminal interface.

## 🚀 Terminal Independence (No Ghostty Required)
The suite has been refactored to work on **any Linux machine**:
*   **In-Place Editing:** All tools now launch your editor (`nvim`) directly in your **current terminal window**. No more mandatory Ghostty popups.
*   **Headless Playback:** Music compilation and playback now happen as truly headless background processes.
*   **Headless Watchers:** The "Live Edit" watcher runs silently in the background, re-playing your music instantly on save without needing a second terminal window.

## Portability & Independence
*   **Self-Contained:** Each flake bundles its own audio drivers, compilers, and headless players.
*   **CWD-Aware:** Tools detect the current working directory and manage files locally.
*   **GitHub Ready:** Each folder is structured as a root-level repository.
