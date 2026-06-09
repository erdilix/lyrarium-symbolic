# Post-Mortem: "Live Edit" Feature Implementation

**Date:** June 9, 2026
**Status:** Resolved
**Summary:** Implemented a robust "Dual-Terminal" Live Edit feature across four distinct synthesis environments (ABC/MIDI and MML/Retro).

## The Challenge
The goal was to allow users to edit music files in Neovim and have the audio re-compile and play automatically on save. The implementation faced several technical hurdles:

1.  **Neovim Atomic Saves**: Neovim replaces files on save rather than modifying them in place. This changes the file's inode, which causes simple file watchers like `entr` to lose track of the file.
2.  **Process Group Isolation**: Initial attempts at background playback caused the main script to terminate when trying to clean up background processes. This was due to the background processes sharing the same Process Group ID (PGID) as the parent script.
3.  **Visual Feedback (The "Black Box" Problem)**: Running watchers silently in the background made it impossible for the user to diagnose why audio wasn't playing (e.g., missing dependencies or syntax errors).
4.  **Terminal Pathing**: Spawning new terminal windows for watchers often reset the working directory, causing "unable to stat" errors as the watcher couldn't find the target files.

## The Solutions

### 1. Resilient Watcher Loop
Standardized a `while true` loop in the Nix flakes to wrap `entr`. Using the `-d` (directory watch) and `-r` (restart) flags ensured that even when Neovim replaces a file, the watcher re-arms itself within milliseconds.
```bash
while true; do
  echo "$file" | entr -prd compile-script "$file"
  sleep 0.1
done
```

### 2. Process Group Separation with `setsid`
Every background process (Watcher terminals and Headless players) is now launched using `setsid`. This places them in a new session and process group. The cleanup function was upgraded to safely target these specific PGIDs without killing the main station script.

### 3. Dual-Terminal Architecture
Shifted from a "headless" background approach to a "Dual-Terminal" approach. 
- **Terminal A**: Foreground Neovim editor.
- **Terminal B**: Visible "Watcher/Player" window that displays compilation logs and audio status.
This provides immediate visual confirmation of the "Live" status.

### 4. Explicit Path Injection
Ensured that all spawned terminals explicitly `cd` into the relevant data directories (`abc_files` or `mml_files`) before executing their payloads, resolving "file not found" errors.

## Lessons Learned
- **Visibility is key**: Users need to see what's happening when a process is "Live." Silence is confusing.
- **Process Management is tricky**: Always use `setsid` when spawning long-running background tasks that need to be cleaned up later.
- **Nix Pathing**: Sub-terminals may not inherit the Nix `PATH` correctly; using absolute paths for `EDITOR` and other key binaries in the flake is the safest approach.