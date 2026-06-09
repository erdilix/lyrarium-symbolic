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

# --- Action: Play (Invisible) ---
do_play() {
    local file="$1"
    cleanup_player
    COMPILE_BIN=${MML_COMPILE_BIN:-compile-mml}
    (cd "$MML_DIR" && exec setsid "$COMPILE_BIN" "$file" >/dev/null 2>&1) &
    PLAYER_PID=$!
}

# --- Action: Live Edit (In-Place) ---
do_edit_neovim() {
    local file="$1"
    cleanup_player
    
    # Robust terminal detection
    local term_cmd=""
    for term in "$TERMINAL" x-terminal-emulator ghostty alacritty kitty wezterm foot xterm; do
        if [ -n "$term" ] && command -v "$term" >/dev/null 2>&1; then
            term_cmd="$term"
            break
        fi
    done

    if [ -z "$term_cmd" ]; then
        notify-send "MML Station" "No terminal emulator found!"
        return
    fi

    # 1. Start the WATCHER/PLAYER in its own terminal (Visible)
    WATCH_BIN=${MML_WATCH_BIN:-watch-mml}
    (exec setsid "$term_cmd" -e sh -c "cd \"$MML_DIR\" && exec \"$WATCH_BIN\" \"$file\"") &
    PLAYER_PID=$!

    # 2. Start the EDITOR in the current or a new terminal (Blocking)
    # Use sh -c for better compatibility and to ensure the Nix environment is respected
    "$term_cmd" -e sh -c "cd \"$MML_DIR\" && exec \"$EDITOR\" \"$file\""

    # 3. Clean up the watcher terminal when Neovim exits
    cleanup_player
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

# --- Main Loop ---
while true; do
    file=$(select_file_smart "📻 Smart MML Jukebox:")
    exit_code=$?
    
    # If no file selected (and not Ctrl+t), cleanup and exit
    if [ -z "$file" ] && [ "$exit_code" -ne 13 ]; then
        cleanup_player
        exit 0
    fi

    case "$exit_code" in
        0)  do_play "$file" ;;
        10) do_edit_neovim "$file" ;;
        11) do_rename "$file" ;;
        12) do_delete "$file" ;;
        13) do_create ;;
    esac
done
