#!/usr/bin/env bash
PLAYER_PID=0
cleanup_player() {
    if [ "$PLAYER_PID" -ne 0 ]; then
        # Check if we are killing ourselves!
        PGID=$(ps -o pgid= -p $PLAYER_PID | tr -d ' ')
        MY_PGID=$(ps -o pgid= -p $$ | tr -d ' ')
        echo "Watcher PGID: $PGID, Station PGID: $MY_PGID"
        if [ "$PGID" == "$MY_PGID" ]; then
            echo "ERROR: Watcher is in the SAME process group as Station!"
        else
            echo "SUCCESS: Watcher is in a different process group."
        fi
        kill -- -"$PGID" 2>/dev/null
        PLAYER_PID=0
    fi
}

# Start watcher
(exec ./mock_watch.sh test.abc >/dev/null 2>&1) &
PLAYER_PID=$!
echo "Started watcher with PID $PLAYER_PID"
sleep 0.5
cleanup_player
echo "Station script still running."
