# ABC Station TUI (Go Version)

A high-performance Terminal User Interface for ABC music, built with **Go** and the **Bubbletea** framework.

## Features
*   **Minimalist & Fast:** Extremely responsive navigation and playback control.
*   **Persistent Jukebox:** Switch tracks instantly without stopping the UI.
*   **REPL Experience:** Integrated watch-and-play workflow.

## Usage
Execute directly using Nix:
```bash
nix run .
```

## Hotkeys
*   **Arrow Keys / j/k:** Navigate library.
*   **Enter:** Play MIDI.
*   **e:** Live Edit mode.
*   **q:** Quit.

## Technical Details
Built using the `charmbracelet/bubbletea` and `charmbracelet/lipgloss` libraries. Packaged using `buildGoModule` in Nix.
