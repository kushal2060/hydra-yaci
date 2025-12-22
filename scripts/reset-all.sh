#!/bin/bash

# Reset All Script
# Stops all services and cleans all generated data

set -e

echo "--------------------------------------------"
echo "Resetting Yaci-Hydra Project"
echo "--------------------------------------------"
echo ""
echo "  WARNING: This will:"
echo "  - Stop all Hydra nodes"
echo "  - Delete all keys and wallets"
echo "  - Delete all node data and logs"
echo "  - Keep Hydra binary and config files"
echo ""

read -p "Are you sure you want to reset? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Reset cancelled."
    exit 0
fi

echo ""
echo "Step 1: Stopping Hydra nodes..."
bash scripts/4-stop-hydra-nodes.sh

echo ""
echo "Step 2: Cleaning Hydra node data..."
rm -rf hydra-nodes/alice/{keys,persistence,logs}/*
rm -rf hydra-nodes/bob/{keys,persistence,logs}/*
rm -rf hydra-nodes/carol/{keys,persistence,logs}/*
echo "  ✓ Hydra node data cleaned"

echo ""
echo "Step 3: Cleaning wallet data..."
rm -rf data/wallets/*
rm -rf data/transactions/*
echo "  ✓ Wallet data cleaned"

echo ""
echo "Step 4: Cleaning logs..."
rm -rf logs/*
echo "  ✓ Logs cleaned"

echo ""
echo "---------------------------------------------"
echo "✓ Reset complete!"
echo "---------------------------------------------"
echo ""
echo "To start fresh:"
echo "  1. npm run keys:generate"
echo "  2. npm run wallets:fund"
echo "  3. npm run hydra:start"
echo ""
echo "Note: Yaci DevKit data is NOT affected."
echo "To reset Yaci: devkit stop && devkit start"