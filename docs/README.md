# Lyrarium Symbolic Documentation

Welcome to the documentation for Lyrarium Symbolic, a multi-environment music synthesis platform.

## 🏗️ Architecture
- [Project Overview](overview.md) - High-level summary of the suite and available stations.
- [Architecture v2](architecture-v2.md) - Overview of the project structure and synthesis pipelines.

## 📖 Guides
- [Termux Installation](guides/Termux.md) - How to run Lyrarium on Android via Termux.
- [Development Journey](development-journey.md) - The history and evolution of this project.

## 🛠️ Post-Mortems (Issue Resolutions)
- [Live Edit Implementation](post-mortems/post-mortem-live-edit.md) - Solving the file watching and process management challenges.
- [Play-Retro Fix](post-mortems/post-mortem-playretro-fix.md) - Debugging MML synthesis issues.

## 🎼 Project Sub-directories
- `abc_midi_old` / `abc_midi_rofi`: ABC notation to MIDI synthesis.
- `mml_retro_old` / `mml_retro_rofi`: MML to NES/Retro soundchip synthesis.
- `tui_go`: Golang-based terminal interface (experimental).
- `tui_python`: Python-based terminal interface (experimental).