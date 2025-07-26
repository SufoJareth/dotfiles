#!/bin/bash

# Set destination directory
INSTALL_DIR="/home/sufojareth/Drives/Linux Games/HorizonXI"
DOWNLOAD_DIR="$HOME/Downloads"

# Fetch latest release info from GitHub
echo "🔎 Fetching latest HorizonXI Launcher release info..."
RELEASE_INFO=$(curl -s https://api.github.com/repos/HorizonFFXI/HorizonXI-Launcher-Binaries/releases/latest)

# Extract version tag and asset URL
VERSION=$(echo "$RELEASE_INFO" | grep -oP '"tag_name": "\K(.*)(?=")')
ASSET_URL=$(echo "$RELEASE_INFO" | grep -oP '"browser_download_url": "\K(.*?Setup\.exe)(?=")')

# Sanity check
if [[ -z "$ASSET_URL" || -z "$VERSION" ]]; then
  echo "❌ Failed to fetch the latest release. Exiting."
  exit 1
fi

echo "✅ Latest version found: $VERSION"
echo "🌐 Download URL: $ASSET_URL"

# Define file paths
SETUP_EXE_NAME="HorizonXI-Launcher-${VERSION}.Setup.exe"
SETUP_EXE_PATH="$DOWNLOAD_DIR/$SETUP_EXE_NAME"

# Remove old installer if it exists
rm -f "$SETUP_EXE_PATH"

# Download the latest installer
echo "⬇️  Downloading installer..."
wget -q --show-progress -P "$DOWNLOAD_DIR" "$ASSET_URL"

# Check if install directory exists
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "📁 Installation directory not found. Creating: $INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
else
  echo "📂 Installation directory exists: $INSTALL_DIR"
fi

# Copy installer and extract
cp "$SETUP_EXE_PATH" "$INSTALL_DIR/installer.exe"

cd "$INSTALL_DIR" || exit

echo "📦 Extracting installer..."
7z x -y installer.exe

echo "📦 Extracting .nupkg..."
NUPKG_FILE=$(ls | grep -i 'HorizonXI_Launcher-.*\.nupkg' | head -n 1)
if [[ -f "$NUPKG_FILE" ]]; then
  7z x -y "$NUPKG_FILE"
else
  echo "❌ .nupkg file not found after extraction!"
  exit 1
fi

echo ""
echo "🎉 ✅ HorizonXI Launcher updated successfully to version $VERSION!"

