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
        # Use pgid to kill the entire background group
        local pgid=$(ps -o pgid= -p $PLAYER_PID | tr -d ' ')
        if [ -n "$pgid" ] && [[ "$pgid" =~ ^[0-9]+$ ]]; then
            kill -- -"$pgid" 2>/dev/null
        fi
        PLAYER_PID=0
    fi
}

# --- Action: Play (Invisible) ---
do_play() {
    local file="$1"
    cleanup_player
    COMPILE_BIN=${MML_COMPILE_BIN:-compile-mml}
    # setsid ensures we have a separate PGID we can kill later
    setsid bash -c "cd '$MML_DIR' && '$COMPILE_BIN' '$file'" >/dev/null 2>&1 &
    PLAYER_PID=$!
}

# --- Action: Live Edit (In-Place) ---
do_edit_neovim() {
    local file="$1"
    cleanup_player
    WATCH_BIN=${MML_WATCH_BIN:-watch-mml}
    setsid bash -c "cd '$MML_DIR' && '$WATCH_BIN' '$file'" >/dev/null 2>&1 &
    PLAYER_PID=$!
    "$EDITOR" "$MML_DIR/$file"
}

# --- Action: Create New ---
do_create() {
    local name
    name=$(rofi -dmenu -i -p "Enter new filename (no extension):")
    [ -z "$name" ] && return
    local full_path="$MML_DIR/$name.mml"
    if [ ! -f "$full_path" ]; then
        cat <<EOF > "$full_path"
; Title: $name
A t120 l4 o4 @01 v15
A c e g > c < g e c
EOF
    fi
    "$EDITOR" "$full_path"
}

# --- Action: Rename ---
do_rename() {
    local file="$1"
    local old_path="$MML_DIR/$file"
    local new_name
    new_name=$(rofi -dmenu -i -p "Rename $file to:" -filter "${file%.mml}")
    if [ -n "$new_name" ]; then
        [[ "$new_name" != *.mml ]] && new_name="${new_name}.mml"
        mv "$old_path" "$MML_DIR/$new_name"
        notify-send "MML Station" "Renamed to $new_name"
    fi
}

# --- Action: Delete ---
do_delete() {
    local file="$1"
    local path="$MML_DIR/$file"
    local confirm
    confirm=$(echo -e "No\nYes" | rofi -dmenu -i -p "Delete $file?" -mesg "Are you sure?")
    if [[ "$confirm" == "Yes" ]]; then
        rm "$path"
        notify-send "MML Station" "Deleted $file"
    fi
}

# --- Menus ---
select_file_smart() {
    find "$MML_DIR" -type f -name "*.mml" -printf "%P\n" | \
        rofi -dmenu -i -p "$1" \
        -kb-custom-1 "Control+s" \
        -kb-custom-2 "Control+r" \
        -kb-custom-3 "Control+x" \
        -kb-custom-4 "Control+t" \
        -mesg "Enter: Play (BG) | Ctrl+s: Edit | Ctrl+t: New | Ctrl+r: Rename"
}

smart_jukebox_retro() {
    while true; do
        local file
        file=$(select_file_smart "📻 Smart MML Jukebox:")
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
    choice=$(echo -e "📝 Edit MML\n✨ Create New MML\n⬅️ Back" | $MENU_LAUNCHER "MML Tools:")
    case "$choice" in
        *Edit*)    
            local file
            file=$(find "$MML_DIR" -type f -name "*.mml" -printf "%P\n" | $MENU_LAUNCHER "Select MML to Edit:")
            [ -n "$file" ] && "$EDITOR" "$MML_DIR/$file"
            ;;
        *Create*)  do_create ;;
        *)         return ;;
    esac
}

while true; do
    choice=$(echo -e "🎵 Smart Jukebox (Play/Edit)\n🛠️ Tools & Management\n❌ Exit" | $MENU_LAUNCHER "MML Station:")
    case "$choice" in
        *"Smart Jukebox"*)     smart_jukebox_retro ;;
        *"Tools"*)             launch_tools ;;
        *"Exit"*)              cleanup_player; exit 0 ;;
        *)                     cleanup_player; exit 0 ;;
    esac
done
