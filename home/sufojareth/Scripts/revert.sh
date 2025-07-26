#!/bin/bash

for dir in */; do
    # Skip if it's not a directory
    [ -d "$dir" ] || continue

    # Get the file inside the directory (assuming only one)
    file=$(find "$dir" -maxdepth 1 -type f | head -n 1)

    # Skip if no file found
    [ -z "$file" ] && continue

    # Move the file back to the parent directory
    mv "$file" ./

    # Remove the now-empty directory
    rmdir "$dir"
done

