#!/usr/bin/env bash

# --- Configuration ---
MML_DIR="$PWD/mml_files"
MENU_LAUNCHER="rofi -dmenu -i -p"
[ -z "$EDITOR" ] && EDITOR="nvim"

mkdir -p "$MML_DIR"
PLAYER_PID=0

# --- Helper: Sound Cleanup ---
cleanup_player() {
    if [ "$PLAYER_PID" -ne 0 ]; then
        kill -- -$(ps -o pgid= -p $PLAYER_PID | tr -d ' ') 2>/dev/null
        PLAYER_PID=0
    fi
}

# --- Action: Play ---
play_retro() {
    local file
    file=$(find "$MML_DIR" -type f -name "*.mml" -printf "%P\n" | $MENU_LAUNCHER "Select MML to Compile & Play:")
    if [ -n "$file" ]; then
        cleanup_player
        COMPILE_BIN=${MML_COMPILE_BIN:-compile-mml}
        (cd "$MML_DIR" && "$COMPILE_BIN" "$file") >/dev/null 2>&1 &
        PLAYER_PID=$!
    fi
}

# --- Action: Watch ---
watch_retro() {
    local file
    file=$(find "$MML_DIR" -type f -name "*.mml" -printf "%P\n" | $MENU_LAUNCHER "Select MML to WATCH (Live Edit):")
    if [ -n "$file" ]; then
        cleanup_player
        WATCH_BIN=${MML_WATCH_BIN:-watch-mml}
        (cd "$MML_DIR" && "$WATCH_BIN" "$file") >/dev/null 2>&1 &
        PLAYER_PID=$!
        
        "$EDITOR" "$MML_DIR/$file"
        
        cleanup_player
    fi
}

# --- Action: Edit ---
edit_mml() {
    local file
    file=$(find "$MML_DIR" -type f -name "*.mml" -printf "%P\n" | $MENU_LAUNCHER "Select MML to Edit:")
    [ -n "$file" ] && "$EDITOR" "$MML_DIR/$file"
}

# --- Main Runner ---
while true; do
    choice=$(echo -e "🎵 Play Retro MML\n👁️ Watch & Edit (Live)\n📝 Edit MML\n❌ Exit" | $MENU_LAUNCHER "MML Station (Classic):")

    case "$choice" in
        *"Play Retro"*)        play_retro ;;
        *"Watch"*)             watch_retro ;;
        *"Edit MML"*)          edit_mml ;;
        *)                     cleanup_player; exit 0 ;;
    esac
done
