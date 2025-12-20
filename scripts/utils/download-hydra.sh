#!/bin/bash

#hydra ko binaries donwload garne script

set -e

source .env 2>/dev/null || HYDRA_VERSION="0.19.0"

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

#binary url


