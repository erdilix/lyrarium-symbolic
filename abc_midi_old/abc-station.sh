#!/usr/bin/env bash

# --- Configuration ---
ABC_DIR="$PWD/abc_files"
MENU_LAUNCHER="rofi -dmenu -i -p"

# Smart Editor Detection
if [ -n "$EDITOR" ]; then
    EDITOR_CMD="$EDITOR"
elif command -v nvim >/dev/null 2>&1; then
    EDITOR_CMD="nvim"
else
    EDITOR_CMD="${NIX_EDITOR:-nvim}"
fi

mkdir -p "$ABC_DIR"
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
play_midi() {
    local file
    file=$(find "$ABC_DIR" -type f -name "*.abc" -printf "%P\n" | $MENU_LAUNCHER "Select ABC to Compile & Play:")
    if [ -n "$file" ]; then
        cleanup_player
        COMPILE_BIN=${ABC_COMPILE_BIN:-compile-abc}
        (cd "$ABC_DIR" && exec setsid "$COMPILE_BIN" "$file" >/dev/null 2>&1) &
        PLAYER_PID=$!
    fi
}

# --- Action: Watch ---
watch_midi() {
    local file
    file=$(find "$ABC_DIR" -type f -name "*.abc" -printf "%P\n" | $MENU_LAUNCHER "Select ABC to WATCH (Live Edit):")
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

        WATCH_BIN=${ABC_WATCH_BIN:-watch-abc}
        if [ -n "$term_cmd" ]; then
            # Pop up a separate window for the watcher/player logs
            (exec setsid "$term_cmd" -e sh -c "cd \"$ABC_DIR\" && exec \"$WATCH_BIN\" \"$file\"") &
        else
            # Fallback to background if no terminal detected
            (cd "$ABC_DIR" && exec setsid "$WATCH_BIN" "$file") &
        fi
        PLAYER_PID=$!
        
        "$EDITOR_CMD" "$ABC_DIR/$file"
        
        cleanup_player
    fi
}

# --- Action: Create ---
do_create() {
    local name
    name=$(rofi -dmenu -i -p "Enter new filename (no extension):")
    [ -z "$name" ] && return
    local full_path="$ABC_DIR/$name.abc"
    if [ ! -f "$full_path" ]; then
        cat <<EOF > "$full_path"
X: 1
T: $name
M: 4/4
L: 1/8
K: C
CDEF GABc |
EOF
    fi
    "$EDITOR_CMD" "$full_path"
}

# --- Action: Edit ---
edit_abc() {
    local file
    file=$(find "$ABC_DIR" -type f -name "*.abc" -printf "%P\n" | $MENU_LAUNCHER "Select ABC to Edit:")
    [ -n "$file" ] && "$EDITOR_CMD" "$ABC_DIR/$file"
}

# --- Main Runner ---
while true; do
    choice=$(echo -e "🎹 Play MIDI\n👁️ Watch & Edit (Live)\n📝 Edit ABC\n✨ Create New ABC\n❌ Exit" | $MENU_LAUNCHER "ABC Station (Classic):")

    case "$choice" in
        *"Play MIDI"*)        play_midi ;;
        *"Watch"*)            watch_midi ;;
        *"Edit ABC"*)         edit_abc ;;
        *"Create New"*)       do_create ;;
        *)                    cleanup_player; exit 0 ;;
    esac
done
