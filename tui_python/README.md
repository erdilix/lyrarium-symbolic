author: gemini
---
# ABC Station TUI (Python Version)

A modern Terminal User Interface for managing and live-coding ABC notation music, built with **Python** and **Textual**.

## Features
*   **Library Browser:** Sidebar navigation of your `./abc_files` directory.
*   **Jukebox:** Non-blocking background playback.
*   **Integrated Live Edit:** Press `e` to suspend the TUI, open `nvim`, and hear your changes instantly via a background watcher.

## Usage
Execute directly using Nix:
```bash
nix run .
```

## Hotkeys
*   **Arrow Keys / Vim Keys:** Navigate the file list.
*   **Enter:** Play song.
*   **e:** Enter Live Edit mode.
*   **q:** Quit.

## Technical Details
This TUI uses the Textual framework and handles sub-process orchestration to manage the `abc2midi` and `fluidsynth` pipeline.
