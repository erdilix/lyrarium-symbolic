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
        # Find PGID and kill group
        local pgid=$(ps -o pgid= -p $PLAYER_PID | tr -d ' ')
        if [ -n "$pgid" ] && [[ "$pgid" =~ ^[0-9]+$ ]]; then
            kill -- -"$pgid" 2>/dev/null
        fi
        PLAYER_PID=0
    fi
}

# --- Action: Play (Headless) ---
do_play() {
    local file="$1"
    cleanup_player
    COMPILE_BIN=${ABC_COMPILE_BIN:-compile-abc}
    setsid bash -c "cd '$ABC_DIR' && '$COMPILE_BIN' '$file'" >/dev/null 2>&1 &
    PLAYER_PID=$!
}

# --- Action: Live Edit (In-Place) ---
do_edit_neovim() {
    local file="$1"
    cleanup_player
    WATCH_BIN=${ABC_WATCH_BIN:-watch-abc}
    setsid bash -c "cd '$ABC_DIR' && '$WATCH_BIN' '$file'" >/dev/null 2>&1 &
    PLAYER_PID=$!
    "$EDITOR" "$ABC_DIR/$file"
}

# --- Action: Create New ---
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
CDEF GABc | cBAG FEDC |
EOF
    fi
    "$EDITOR" "$full_path"
}

# --- Action: Rename ---
do_rename() {
    local file="$1"
    local old_path="$ABC_DIR/$file"
    local new_name
    new_name=$(rofi -dmenu -i -p "Rename $file to:" -filter "${file%.abc}")
    if [ -n "$new_name" ]; then
        [[ "$new_name" != *.abc ]] && new_name="${new_name}.abc"
        mv "$old_path" "$ABC_DIR/$new_name"
        notify-send "ABC Station" "Renamed to $new_name"
    fi
}

# --- Action: Delete ---
do_delete() {
    local file="$1"
    local path="$ABC_DIR/$file"
    local confirm
    confirm=$(echo -e "No\nYes" | rofi -dmenu -i -p "Delete $file?" -mesg "Are you sure?")
    if [[ "$confirm" == "Yes" ]]; then
        rm "$path"
        notify-send "ABC Station" "Deleted $file"
    fi
}

# --- Menus ---
select_abc_smart() {
    find "$ABC_DIR" -type f -name "*.abc" -printf "%P\n" | \
        rofi -dmenu -i -p "$1" \
        -kb-custom-1 "Control+s" \
        -kb-custom-2 "Control+r" \
        -kb-custom-3 "Control+x" \
        -kb-custom-4 "Control+t" \
        -mesg "Enter: Play (BG) | Ctrl+s: Edit | Ctrl+t: New | Ctrl+r: Rename"
}

smart_jukebox_midi() {
    while true; do
        local file
        file=$(select_abc_smart "🎹 Smart ABC Jukebox:")
        local exit_code=$?
        if [ -z "$file" ] && [ "$exit_code" -ne 13 ]; then
            cleanup_player
            return
        fi
        case "$exit_code" in
            0)  do_play "$file" ;;
            10) do_edit_neovim "$file" ;;
            11) do_rename "$file" ;;
            12) do_delete "$file" ;;
            13) do_create ;;
        esac
    done
}

launch_tools() {
    local choice
    choice=$(echo -e "📝 Edit ABC\n✨ Create New ABC\n⬅️ Back" | $MENU_LAUNCHER "ABC Tools:")
    case "$choice" in
        *Edit*)    
            local file
            file=$(find "$ABC_DIR" -type f -name "*.abc" -printf "%P\n" | $MENU_LAUNCHER "Select ABC to Edit:")
            [ -n "$file" ] && "$EDITOR" "$ABC_DIR/$file"
            ;;
        *Create*)  do_create ;;
        *)         return ;;
    esac
}

while true; do
    choice=$(echo -e "🎵 Smart Jukebox (Play/Edit)\n🛠️ Tools & Management\n❌ Exit" | $MENU_LAUNCHER "ABC Station:")
    case "$choice" in
        *"Smart Jukebox"*)     smart_jukebox_midi ;;
        *"Tools"*)             launch_tools ;;
        *"Exit"*)              cleanup_player; exit 0 ;;
        *)                     cleanup_player; exit 0 ;;
    esac
done
