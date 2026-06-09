#!/usr/bin/env bash
file=$1
while true; do
  # Simulation of the watcher loop
  # In reality this uses 'entr'
  echo "Watching $file..." >> watch_log.txt
  # We simulate waiting for a change and running the compiler
  ./mock_compile.sh "$file"
  # In the real script, 'entr' blocks here. 
  # For this test, we'll just wait for a flag file to simulate a change.
  while [ ! -f trigger ]; do sleep 0.1; done
  rm trigger
done
