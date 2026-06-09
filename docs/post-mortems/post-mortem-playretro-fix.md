author: gemini
---
# Post-Mortem: Debugging the `playretro` MML Compilation & Playback Pipeline

**Date:** June 9, 2026  
**Status:** Resolved  
**Component:** `mml-dashboard.sh` / `retroSoundship` Flake

## Executive Summary
The `playretro` option in the MML Dashboard was failing due to a combination of legacy tool constraints (`nesasm`) and environment-specific player limitations (`mpv`). The pipeline was refactored to use a wrapper-based assembly strategy and a specialized chiptune player (`zxtune123`), resulting in a robust and functional compilation-to-playback workflow.

## The Problem
Users reported that the "Play Retro MML" option in `./mml-dashboard.sh` did not work. Investigation revealed two distinct failure points:

1.  **Compilation Failure:** `nesasm` (v2.51) was failing to find included files and rejecting assembly directives.
2.  **Playback Failure:** Once compilation was manually fixed, `mpv` failed to recognize the resulting `.nsf` (NES Sound Format) files.

---

## Technical Root Cause Analysis

### 1. The `nesasm` Bottleneck
The `ppmck` toolchain relies on `nesasm` to assemble the final binary. Several legacy behaviors were identified:
*   **Indentation Sensitivity:** `nesasm` requires assembly directives (like `.include`, `.org`, `.db`) to be indented. Any text starting at column 0 is treated as a label.
*   **Missing `-I` Support:** Despite common documentation, the version of `nesasm` provided in the environment did not support the `-I` (include path) flag.
*   **Entry Point Context:** The `ppmck.asm` driver expects `define.inc` and song data (`.h` files) to be in the same directory or accessible via relative paths.

### 2. The Playback Gap
`mpv` typically plays NSF files via `libgme` (Game Music Emulator). However:
*   The `mpv` build in the Nix environment was not linked against `libgme`.
*   `nesasm` outputs a `.nes` file by default, even when generating NSF payloads. Renaming was necessary but insufficient without a compatible demuxer.

---

## The Solution

### Phase 1: Refactoring the Assembly Process
Instead of attempting to pass include flags, we transitioned to a **Wrapper + Symlink** strategy:
1.  **Dynamic Wrapper:** The script now generates a `local_master.asm` on-the-fly.
    ```assembly
     .include "ppmck.asm"
     .include "songname.h"
    ```
    *Note the leading space for indentation.*
2.  **Local Symlinks:** Temporary symlinks to the Nix Store's `nes_include` bank are created in the local directory:
    *   `./ppmck.asm` -> Pointing to the master driver.
    *   `./ppmck/` -> Pointing to the driver's internal includes.
3.  **Raw Flag:** Used the `-raw` flag to ensure `nesasm` produced a pure NSF payload without an iNES header.

### Phase 2: Switching to `zxtune`
`zxtune` was identified as a superior alternative for this environment:
*   It has native, built-in support for NSF/NSFE via its own plugins.
*   It provides a CLI player (`zxtune123`) with a spectrum analyzer and metadata display.
*   **Action:** Updated `retroSoundship/flake.nix` to include `pkgs.zxtune` and updated `mml-dashboard.sh` to invoke `zxtune123`.

---

## Lessons Learned
1.  **Legacy Tools Require Precision:** When working with 8-bit toolchains like `nesasm`, never assume modern CLI conventions (like include paths) apply.
2.  **Verify Nix Store Asset Layouts:** Finding the `INCLUDE_DIR` via `$(which ppmckc)/../nes_include` was key to making the script portable across different Nix Store hashes.
3.  **Environment-Specific Dependencies:** Just because a player *can* support a format doesn't mean the specific build in the environment *does*. Always check `mpv --demuxer=help` or verbose logs.

## Verification
Compilation and playback were verified for `theexecutioner.mml`. The resulting `theexecutioner.nsf` (8KB) plays correctly with full visualization in `zxtune123`.
