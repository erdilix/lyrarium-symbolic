author: gemini
---
# Architectural Overview: Lyrarium Symbolic

Lyrarium Symbolic is a modular music development suite designed for **hermetic portability** and **cross-engine consistency**. It bridges the gap between modern MIDI synthesis and 8-bit retro soundchip programming.

## 🏗️ The Three-Tier Architecture

The project is structured in three distinct layers to separate environment management, logic orchestration, and specialized tools.

### 1. The Environment Layer (Nix Flakes)
Every subdirectory (e.g., `abc_midi_rofi`, `mml_retro_old`) is a self-contained **Nix Flake**.
*   **Role**: Handles dependency resolution, path injection, and tool isolation.
*   **Portability**: Ensures that every user has the exact same versions of `abcmidi`, `fluidsynth`, or `ppmck`, regardless of their host OS.
*   **Virtual Binaries**: Flakes define "virtual" binaries (like `watch-abc` or `compile-mml`) that encapsulate complex shell logic into simple, callable commands.

### 2. The Orchestration Layer (Shell Scripts)
The `station.sh` files act as the "Brain" of each station.
*   **Role**: Manages the User Interface (Rofi or CLI menus), file I/O, and process lifecycles.
*   **Process Isolation**: Uses `setsid` and PGID-based cleanup to ensure that background audio players can be stopped safely without crashing the main application.
*   **Smart Detection**: Dynamically detects the user's preferred terminal emulator and text editor to provide a native feel.

### 3. The Synthesis Layer (Specialized Tools)
This layer contains the actual music engines.
*   **ABC MIDI**: A modern pipeline that converts text-based ABC notation into MIDI, then synthesizes it into high-quality WAV/PulseAudio streams using FluidR3 soundfonts.
*   **MML Retro**: A specialized pipeline for 8-bit NES (RP2A03) synthesis. It compiles MML into assembly, assembles it into NES binaries, and plays them via the `zxtune` engine.

## 🔄 The Live Edit Workflow

The most complex architectural feature is the "Live Edit" mechanism, which connects the three tiers:

1.  **Trigger**: User selects a file and enters Live Edit mode.
2.  **Dual-Terminal Spawn**: The orchestrator spawns two processes:
    *   **The Editor**: Launches the user's preferred editor (with Nix fallback).
    *   **The Watcher**: Launches a dedicated terminal running an `entr` loop defined in the Nix Flake.
3.  **The Watcher Loop**: 
    *   Monitors for file changes (handling Neovim's atomic save inode swaps).
    *   On save, triggers the **Synthesis Layer** to re-compile and re-play the audio immediately.
4.  **Cleanup**: When the Editor process terminates, the Orchestrator sends a SIGTERM to the Watcher's process group, ensuring a clean exit.

## 🎼 Cross-Platform Consistency

A key architectural goal is **Timing Synchronization**.
*   The system utilizes a "True Speed Match" formula (`12/8` meter and `3/8` grouped tempo) to ensure that rhythmic pulses remain identical between the MML retro engines and the ABC modern engines.
*   This allows a composer to develop a melody in one engine and trust its timing will remain accurate when ported to the other.

## 📂 Directory Map

*   `docs/`: Post-mortems, guides, and architectural deep-dives.
*   `abc_midi_*/`: ABC-to-MIDI stations (Classic and Rofi variants).
*   `mml_retro_*/`: MML-to-NES stations (Classic and Rofi variants).
*   `tui_*/`: Experimental TUI implementations in Go and Python.

---
author: gemini
