#!/usr/bin/env bash

# --- Configuration ---
MML_DIR="$PWD/mml_files"
MENU_LAUNCHER="rofi -dmenu -i -p"

# Smart Editor Detection
if [ -n "$EDITOR" ]; then
    EDITOR_CMD="$EDITOR"
elif command -v nvim >/dev/null 2>&1; then
    EDITOR_CMD="nvim"
else
    EDITOR_CMD="${NIX_EDITOR:-nvim}"
fi

mkdir -p "$MML_DIR"
PLAYER_PID=0

# --- Helper: Sound Cleanup ---
cleanup_player() {
    if [ "$PLAYER_PID" -ne 0 ]; then
        # Find PGID and kill group, but ONLY if it's not our own group!
        local pgid
        pgid=$(ps -o pgid= -p $PLAYER_PID | tr -d ' ')
        local my_pgid
        my_pgid=$(ps -o pgid= -p $$ | tr -d ' ')

        if [ -n "$pgid" ] && [[ "$pgid" =~ ^[0-9]+$ ]] && [ "$pgid" != "$my_pgid" ]; then
            kill -- -"$pgid" 2>/dev/null
        else
            kill "$PLAYER_PID" 2>/dev/null
        fi
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
        (cd "$MML_DIR" && exec setsid "$COMPILE_BIN" "$file" >/dev/null 2>&1) &
        PLAYER_PID=$!
    fi
}

# --- Action: Watch ---
watch_retro() {
    local file
    file=$(find "$MML_DIR" -type f -name "*.mml" -printf "%P\n" | $MENU_LAUNCHER "Select MML to WATCH (Live Edit):")
    if [ -n "$file" ]; then
        cleanup_player

        # Terminal detection for the popup watcher
        local term_cmd=""
        for term in "$TERMINAL" x-terminal-emulator ghostty alacritty kitty wezterm foot xterm; do
            if [ -n "$term" ] && command -v "$term" >/dev/null 2>&1; then
                term_cmd="$term"
                break
            fi
        done

        WATCH_BIN=${MML_WATCH_BIN:-watch-mml}
        if [ -n "$term_cmd" ]; then
            # Pop up a separate window for the watcher/player logs
            (exec setsid "$term_cmd" -e sh -c "cd \"$MML_DIR\" && exec \"$WATCH_BIN\" \"$file\"") &
        else
            # Fallback to background if no terminal detected
            (cd "$MML_DIR" && exec setsid "$WATCH_BIN" "$file") &
        fi
        PLAYER_PID=$!
        
        "$EDITOR_CMD" "$MML_DIR/$file"
        
        cleanup_player
    fi
}

# --- Action: Edit ---
edit_mml() {
    local file
    file=$(find "$MML_DIR" -type f -name "*.mml" -printf "%P\n" | $MENU_LAUNCHER "Select MML to Edit:")
    [ -n "$file" ] && "$EDITOR_CMD" "$MML_DIR/$file"
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
