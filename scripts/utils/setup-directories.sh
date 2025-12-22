#!/bin/bash

# Setup Directories Script
# Creates all required folder structure

set -e

echo "-------------------------------------"
echo "Setting up project directories folder haru..."
echo "-------------------------------------"
echo ""

# Create main directories
echo "Creating directory structure..."

# Hydra nodes directories
mkdir -p hydra-nodes/alice/keys
mkdir -p hydra-nodes/alice/persistence
mkdir -p hydra-nodes/alice/logs

mkdir -p hydra-nodes/bob/keys
mkdir -p hydra-nodes/bob/persistence
mkdir -p hydra-nodes/bob/logs

mkdir -p hydra-nodes/carol/keys
mkdir -p hydra-nodes/carol/persistence
mkdir -p hydra-nodes/carol/logs

echo "✓ Created hydra-nodes structure (alice, bob, carol)"

# Data directories
mkdir -p data/wallets
mkdir -p data/transactions

echo "✓ Created data directories (wallets, transactions)"

# Binary directory
mkdir -p bin

echo "✓ Created bin directory for Hydra binaries"

# Logs directory
mkdir -p logs

echo "✓ Created logs directory"

# Config directories
mkdir -p config/hydra
mkdir -p config/network

echo "✓ Created config directories"

# Create .gitkeep files to preserve empty directories in git
touch hydra-nodes/.gitkeep
touch data/.gitkeep
touch bin/.gitkeep
touch logs/.gitkeep
touch config/.gitkeep

echo "✓ Added .gitkeep files for git"

# Set proper permissions for security
echo ""
echo "Setting secure permissions..."

# Key directories should only be accessible by owner
chmod 700 hydra-nodes/alice/keys
chmod 700 hydra-nodes/bob/keys
chmod 700 hydra-nodes/carol/keys

echo "✓ Set secure permissions on key directories (700 - owner only)"

# Make sure parent directories have proper permissions
chmod 755 hydra-nodes
chmod 755 data
chmod 755 bin
chmod 755 logs
chmod 755 config

echo "✓ Set standard permissions on parent directories (755)"

echo ""
echo "-------------------------------------"
echo "Directory setup complete!"
echo "-------------------------------------"
echo ""
