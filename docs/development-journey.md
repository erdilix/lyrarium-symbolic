author: gemini
---
# 🗺️ Development Journey: From Monolith to Standalone Stations

This document chronicles the evolution of the MML & ABC Music Development Suite—a journey from a single, complex bash script to a modular ecosystem of four independent Nix applications.

## 📍 Stage 1: The Monolithic Dashboard
The project began as `mml-dashboard.sh`, a large Bash script that managed everything via Rofi. While functional, it suffered from several critical issues:
*   **Bloat:** Long strings of complex compilation logic were embedded directly in the shell script.
*   **Legacy Tool Hurdles:** `nesasm` (v2.51) was found to have strict indentation requirements and no support for standard include paths (`-I`), causing frequent compilation failures.
*   **Path Fragility:** Hardcoded absolute paths meant the script only worked on one specific machine.

## 📍 Stage 2: Solving the Retro Stack
Our first major breakthrough was stabilizing the **MML/NES pipeline**:
1.  **Wrapper Strategy:** We created a dynamic `local_master.asm` on-the-fly to handle driver includes and song data with precise indentation.
2.  **Symlink Magic:** Since `nesasm` couldn't look into the Nix store, we implemented a strategy to symlink Nix-managed NES audio driver banks into the local workspace temporarily.
3.  **Playback Evolution:** We discovered that standard `mpv` builds often lack the Game Music Emulator (`libgme`) plugin. We pivoted to **`zxtune123`**, which provided a superior experience with spectrum analyzers and robust NSF support.

## 📍 Stage 3: The Architecture Refactor
The biggest turning point was the decision to split the monolith into independent "Stations."
*   **Nix-Packaged Logic:** We moved the heavy compilation bash logic out of `.sh` scripts and into **Nix binaries** (`compile-mml`, `compile-abc`).
*   **Zero-Bloat Dashboards:** By making the compilation logic part of the Nix environment, the user-facing scripts became tiny, readable UI managers.
*   **Independence:** Each directory was refactored to be a root-level repository, making them truly "GitHub-ready" with their own `README.md` and dependencies.

## 📍 Stage 4: Advanced Interfaces (TUI & Live Edit)
To provide a more "modern" feel, we expanded the suite beyond Bash:
*   **Python (Textual):** Created a sleek, `rmpc`-inspired dashboard with a sidebar library browser.
*   **Go (Bubbletea):** Built a high-performance, minimalist TUI for those who prefer speed and simplicity.
*   **The REPL Experience:** We implemented a "Live Edit" (Watch) mode using **`entr`**. By opening the editor and a background listener simultaneously, we transformed a batch-compilation process into a real-time musical feedback loop.

## 📍 Stage 5: Final Harmonization
The journey concluded with the conversion of legacy MML snippets into ABC format, ensuring that musical ideas can flow freely between the 8-bit NES world and modern high-quality MIDI synthesis across all four tools.

---

### 📝 Key Technical Accomplishments
*   **Standalone Nix Run:** All 4 tools work via `nix run .` without manual setup.
*   **Multi-Language Success:** Implemented the same logic across Bash, Python, and Go.
*   **Portable Design:** Relative path detection replaces fragile absolute host paths.
*   **Audio Robustness:** Explicitly configured PulseAudio backends and soundfont paths within the Nix closures.
