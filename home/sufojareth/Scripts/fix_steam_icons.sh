#!/bin/bash

# Directory containing .desktop files
DESKTOP_DIR="$HOME/.local/share/applications"

# Path to your fix script
FIX_SCRIPT="./fix_single_desktop.sh"  # adjust this path if needed

# Check if the fix script exists
if [[ ! -f "$FIX_SCRIPT" ]]; then
    echo "Fix script not found at $FIX_SCRIPT"
    exit 1
fi

# Loop over each .desktop file
for file in "$DESKTOP_DIR"/*.desktop; do
    # Only process files with steam:// in Exec=
    if grep -q '^Exec=.*steam://' "$file"; then
        echo "Fixing Steam desktop file: $file"
        bash "$FIX_SCRIPT" "$file"
    else
        echo "Skipping non-Steam file: $file"
    fi
done
