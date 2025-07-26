#!/bin/bash

# Navigate to Downloads folder
cd ~/Downloads || exit

# Find the latest Discord tarball
DISCORD_TARBALL=$(ls -t discord-*.tar.gz 2>/dev/null | head -n 1)

# Check if a tarball exists
if [[ -z "$DISCORD_TARBALL" ]]; then
    echo "No Discord tarball found in ~/Downloads."
    exit 1
fi

echo "Installing Discord from $DISCORD_TARBALL"

# Extract the latest tarball
tar -zxf "$DISCORD_TARBALL"

# Remove any existing Discord installation
sudo rm -rf /opt/Discord/

# Move the extracted folder to /opt
sudo mv Discord /opt/Discord/

# Create a symbolic link for easy access
sudo ln -sf /opt/Discord/Discord /usr/bin/discord

# Clean up Discord Install
rm -f "$DISCORD_TARBALL"

echo "Discord installation complete. Tarball removed."


# === VENCORD REINJECTION ===

echo "Reinjecting Vencord..."

TMP_DIR=$(mktemp -d)
VENCORD_BIN="$TMP_DIR/VencordInstallerCli-Linux"

# Download latest CLI binary
curl -sSL https://github.com/Vendicated/VencordInstaller/releases/latest/download/VencordInstallerCli-Linux -o "$VENCORD_BIN"
chmod +x "$VENCORD_BIN"

# Run it with headless injection
"$VENCORD_BIN" inject --headless

# Clean up Vencord Install
rm -f "$VENCORD_BIN"

echo "✅ Vencord reinstalled successfully."
