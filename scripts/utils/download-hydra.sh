#!/bin/bash

#hydra ko binaries donwload garne script

set -e

source .env 2>/dev/null 
HYDRA_VERSION="${HYDRA_VERSION:-1.2.0}"

echo "Downloading Hydra node binary"

#os
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

echo "Detected system: $OS $ARCH"

case $ARCH in
    x86_64)
        ARCH="x86_64"
        ;;
    arm64|aarch64)
        ARCH="aarch64"
        ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        echo "Supported: x86_64, arm64/aarch64"
        exit 1
        ;;
esac

#os names
case $OS in
    linux)
        PLATFORM="linux"
        ;;
    darwin)
        PLATFORM="macos"
        ;;
    *)
        echo "Error: Unsupported OS: $OS"
        echo "Supported: Linux, macOS"
        exit 1
        ;;
esac
case "$OS-$ARCH" in
  darwin-aarch64)
    BINARY_NAME="hydra-aarch64-darwin-${HYDRA_VERSION}.zip"
    ;;
  linux-x86_64)
    BINARY_NAME="hydra-x86_64-linux-${HYDRA_VERSION}.zip"
    ;;
  *)
    echo "Unsupported OS/ARCH: $OS $ARCH"
    exit 1
    ;;
esac


DOWNLOAD_URL="https://github.com/cardano-scaling/hydra/releases/download/${HYDRA_VERSION}/${BINARY_NAME}"

echo "Version: ${HYDRA_VERSION}"
echo "Platform: ${PLATFORM}"
echo "Architecture: ${ARCH}"
echo ""

# Check if already downloaded
if [ -f "bin/hydra-node" ]; then
    echo "Hydra node binary already exists in bin/"
    read -p "Do you want to re-download? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping download."
        exit 0
    fi
    rm -f bin/hydra-node
fi

echo "Downloading from:"
echo "$DOWNLOAD_URL"
echo ""

# Download with progress bar
cd bin
if ! curl -L -o "$BINARY_NAME" --progress-bar "$DOWNLOAD_URL"; then
    echo ""
    echo "Error: Failed to download Hydra binary"
    echo ""
    echo "Please check:"
    echo "  1. Your internet connection"
    echo "  2. The Hydra version in .env (currently: ${HYDRA_VERSION})"
    echo "  3. Available releases: https://github.com/cardano-scaling/hydra/releases"
    exit 1
fi

echo ""
echo "Extracting..."
unzip -q "$BINARY_NAME"

# binary executable
chmod +x hydra-node

# Clean up zip file
rm "$BINARY_NAME"

cd ..

echo ""
echo "✓ Hydra node binary downloaded successfully!"
echo "  Location: $(pwd)/bin/hydra-node"
echo ""


echo "Verifying binary..."
if ./bin/hydra-node --version; then
    echo ""
    echo "--------------------------------------------"
    echo "✓ Hydra setup complete!"
    echo "--------------------------------------------"
else
    echo "Error: Binary verification failed"
    exit 1
fi



