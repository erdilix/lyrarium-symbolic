#!/usr/bin/env bash

# --- Configuration ---
ABC_DIR="$PWD/abc_files"
MENU_LAUNCHER="rofi -dmenu -i -p"
[ -z "$EDITOR" ] && EDITOR="nvim"

mkdir -p "$ABC_DIR"
PLAYER_PID=0

# --- Helper: Sound Cleanup ---
cleanup_player() {
    if [ "$PLAYER_PID" -ne 0 ]; then
        kill -- -$(ps -o pgid= -p $PLAYER_PID | tr -d ' ') 2>/dev/null
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
        (cd "$ABC_DIR" && "$COMPILE_BIN" "$file") >/dev/null 2>&1 &
        PLAYER_PID=$!
    fi
}

# --- Action: Watch ---
watch_midi() {
    local file
    file=$(find "$ABC_DIR" -type f -name "*.abc" -printf "%P\n" | $MENU_LAUNCHER "Select ABC to WATCH (Live Edit):")
    if [ -n "$file" ]; then
        cleanup_player
        WATCH_BIN=${ABC_WATCH_BIN:-watch-abc}
        (cd "$ABC_DIR" && "$WATCH_BIN" "$file") >/dev/null 2>&1 &
        PLAYER_PID=$!
        
        "$EDITOR" "$ABC_DIR/$file"
        
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
    "$EDITOR" "$full_path"
}

# --- Action: Edit ---
edit_abc() {
    local file
    file=$(find "$ABC_DIR" -type f -name "*.abc" -printf "%P\n" | $MENU_LAUNCHER "Select ABC to Edit:")
    [ -n "$file" ] && "$EDITOR" "$ABC_DIR/$file"
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
