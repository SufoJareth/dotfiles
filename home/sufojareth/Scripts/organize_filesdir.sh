#!/bin/bash

# This script moves each regular file in the current directory
# into its own subdirectory, named after the file (without the extension)

for file in *; do
    # Skip if not a regular file
    [ -f "$file" ] || continue

    # Get filename without extension
    dirname="${file%.*}"

    # Create directory and move file
    mkdir -p "$dirname"
    mv "$file" "$dirname/"
done

