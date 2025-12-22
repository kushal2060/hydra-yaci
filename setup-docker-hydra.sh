#!/bin/bash

# Complete Docker Setup for ARM Mac
# use this if the cardano cli kam garena ra hydra ko binary ni kam garena
#mainly for M1/M2 mac users

set -e

echo "---------------------------------------------"
echo "Setting up Hydra for ARM Mac (Docker)"
echo "---------------------------------------------"
echo ""

HYDRA_VERSION="1.2.0"

# Step 1: Pull required Docker images for ARM64
echo "Step 1: Pulling Docker images for ARM64..."
echo ""

echo "  Pulling Hydra node..."
docker pull --platform linux/arm64 ghcr.io/cardano-scaling/hydra-node:$HYDRA_VERSION

echo "  Pulling Cardano CLI..."
docker pull --platform  ghcr.io/blinklabs-io/cardano-node:main-arm64v8



echo ""
echo "✓ Docker images pulled"
echo ""

# Step 2: Create hydra-node wrapper
echo "Step 2: Creating hydra-node wrapper..."

cat > bin/hydra-node <<'EOF'
#!/bin/bash

# Hydra Node Docker Wrapper for ARM Mac

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HYDRA_VERSION="0.19.0"

docker run --rm \
  --platform linux/arm64 \
  -v "$PROJECT_ROOT/hydra-nodes:/hydra-nodes" \
  -v "$PROJECT_ROOT/config:/config" \
  -v "/tmp:/tmp" \
  --network host \
  ghcr.io/cardano-scaling/hydra-node:$HYDRA_VERSION \
  "$@"
EOF

chmod +x bin/hydra-node
echo "  ✓ Created bin/hydra-node"

# Step 3: Create cardano-cli wrapper
echo "Step 3: Creating cardano-cli wrapper..."

cat > bin/cardano-cli <<'EOF'
#!/bin/bash

# Cardano CLI Docker Wrapper for ARM Mac

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

docker run --rm \
  --platform linux/arm64 \
  -v "$PROJECT_ROOT/hydra-nodes:/hydra-nodes" \
  -v "$PROJECT_ROOT/config:/config" \
  -v "$PROJECT_ROOT/data:/data" \
  -v "/tmp:/tmp" \
  -w /hydra-nodes \
  ghcr.io/blinklabs-io/cardano-node:latest \
  "$@"
EOF

chmod +x bin/cardano-cli
echo "  ✓ Created bin/cardano-cli"

echo ""
echo "Step 4: Testing setup..."
echo ""

# Test hydra-node
echo "  Testing hydra-node..."
if ./bin/hydra-node --version 2>&1 | grep -q "hydra-node"; then
    echo "  ✓ hydra-node works!"
else
    echo "  ✗ hydra-node test failed"
    exit 1
fi

# Test cardano-cli
echo "  Testing cardano-cli..."
if ./bin/cardano-cli --version 2>&1 | grep -q "cardano-cli"; then
    echo "  ✓ cardano-cli works!"
else
    echo "  ✗ cardano-cli test failed"
    exit 1
fi

echo ""
echo "---------------------------------------------"
echo "✓ Setup complete!"
echo "---------------------------------------------"
echo ""
echo "You can now use:"
echo "  ./bin/hydra-node --version"
echo "  ./bin/cardano-cli --version"
echo "  npm run keys:generate"
echo ""