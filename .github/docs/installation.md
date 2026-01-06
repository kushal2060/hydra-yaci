# Installation Guide

This guide provides detailed installation instructions for all components of Hydra-Yaci.

## System Requirements

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 2 cores | 4+ cores |
| RAM | 8 GB | 16 GB |
| Storage | 5 GB free | 10 GB free |
| Network | Stable internet | High-speed connection |

### Operating System Support

- ✅ **Linux**: Ubuntu 20.04+, Debian 11+, Fedora 35+
- ✅ **macOS**: 11 (Big Sur) or later (Intel and Apple Silicon)
- ✅ **Windows**: Windows 10/11 with WSL2

## Installing Prerequisites

### 1. Node.js and npm

#### Linux (Ubuntu/Debian)

```bash
# Install Node.js v20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should be v18.0.0 or higher
npm --version   # Should be v9.0.0 or higher
```

#### macOS

Using Homebrew:

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js
brew install node@20

# Verify installation
node --version
npm --version
```

#### Windows (WSL2)

```bash
# Inside WSL2
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

### 2. Docker

#### Linux (Ubuntu/Debian)

```bash
# Remove old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Install Docker
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

#### macOS

```bash
# Download Docker Desktop for Mac
# Visit: https://www.docker.com/products/docker-desktop

# Or using Homebrew
brew install --cask docker

# Start Docker Desktop from Applications
# Verify installation
docker --version
docker compose version
```

#### Windows

1. Download Docker Desktop for Windows from [docker.com](https://www.docker.com/products/docker-desktop)
2. Run the installer
3. Enable WSL2 integration
4. Restart your computer
5. Verify in WSL2:

```bash
docker --version
docker compose version
```

### 3. Yaci DevKit

#### Install Yaci CLI

```bash
# Install globally using npm
npm install -g @bloxbean/yaci-devkit

# Verify installation
devkit --version
```

#### Initialize Yaci DevKit

```bash
# Create a new DevKit instance
devkit create

# Or use an existing directory
cd my-yaci-instance
devkit init
```

#### Start Yaci DevKit

```bash
# Start the DevKit
devkit start

# Expected output:
# Starting Yaci DevKit...
# ✓ API Server started at http://localhost:8080
# ✓ Ogmios started at ws://localhost:1337
# ✓ Kupo started at http://localhost:1442
```

#### Verify Yaci DevKit

```bash
# Check if API is responding
curl http://localhost:8080/api/v1/epochs/latest

# Expected output: JSON with epoch information
```

### 4. Command-Line Tools

#### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y curl jq git
```

#### macOS

```bash
brew install curl jq git
```

#### Windows (WSL2)

```bash
sudo apt-get update
sudo apt-get install -y curl jq git
```

## Installing Hydra-Yaci

### 1. Clone the Repository

```bash
# Clone from GitHub
git clone https://github.com/kushal2060/hydra-yaci.git
cd hydra-yaci
```

### 2. Install Node Dependencies

```bash
# Install all npm packages
npm install
```

This installs:
- `@lucid-evolution/lucid` - Cardano library
- `@lucid-evolution/provider` - Provider utilities
- `axios` - HTTP client
- `ws` - WebSocket client
- `dotenv` - Environment variable management
- `chalk` - Terminal styling

### 3. Verify Installation

```bash
# Run prerequisite checker
npm run prerequisites
```

Expected output:

```
✓ node is installed
  Version: v20.x.x
✓ npm is installed
  Version: 10.x.x
✓ curl is installed
✓ jq is installed
✓ docker is installed
  Version: 24.x.x
✓ Yaci DevKit is running
  Current Epoch: 0
✓ Port 4001 is available
✓ Port 4002 is available
✓ Port 4003 is available
✓ Port 5001 is available
✓ Port 5002 is available
✓ Port 5003 is available
✓ Port 6001 is available
✓ Port 6002 is available
✓ Port 6003 is available
✓ All prerequisites met!
```

### 4. Run Setup

```bash
# Setup directories and download Hydra binaries
npm run setup
```

This script:
- Creates `hydra-nodes` directory structure
- Downloads Hydra node binaries (v1.2.0)
- Sets up Docker wrappers
- Creates necessary configuration files

## Platform-Specific Setup

### macOS (Apple Silicon / M1/M2)

For ARM-based Macs, use the Docker-based setup:

```bash
# Run the ARM-specific setup script
bash setup-docker-hydra.sh
```

This script:
- Pulls ARM64-compatible Docker images
- Creates wrapper scripts for `hydra-node` and `cardano-cli`
- Configures Docker networking

The wrappers are located in:
- `bin/hydra-node` - Hydra node wrapper
- `bin/cardano-cli` - Cardano CLI wrapper

### Windows (WSL2)

1. **Ensure WSL2 is enabled**:
   ```bash
   wsl --list --verbose
   ```

2. **Configure Docker Desktop**:
   - Enable WSL2 integration
   - Enable integration with your Ubuntu distribution

3. **Clone and run inside WSL2**:
   ```bash
   cd /home/your-username
   git clone https://github.com/kushal2060/hydra-yaci.git
   cd hydra-yaci
   npm install
   npm run setup
   ```

### Linux

Standard installation works on Linux. For better Docker performance:

```bash
# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group (avoid sudo)
sudo usermod -aG docker $USER
newgrp docker
```

## Docker Image Setup

### Pull Required Images

```bash
# Hydra node
docker pull ghcr.io/cardano-scaling/hydra-node:1.2.0

# Cardano CLI (if needed)
docker pull ghcr.io/blinklabs-io/cardano-node:main-arm64v8

# Hydra TUI
docker pull ghcr.io/cardano-scaling/hydra-tui:1.2.0
```

### Verify Images

```bash
docker images | grep hydra
```

Expected output:
```
ghcr.io/cardano-scaling/hydra-node    1.2.0    abc123...   2 weeks ago    500MB
ghcr.io/cardano-scaling/hydra-tui     1.2.0    def456...   2 weeks ago    100MB
```

## Environment Configuration

### Create Environment File

```bash
# Copy example configuration
cp .env.example .env
```

### Edit Configuration

Edit `.env` with your preferred settings:

```bash
# Yaci DevKit URLs
YACI_API_URL=http://localhost:8080/api/v1
YACI_OGMIOS_URL=ws://localhost:1337

# Network configuration
NETWORK_MAGIC=42

# Hydra version
HYDRA_VERSION=1.2.0

# Participant configuration
HYDRA_HOST_ALICE=host.docker.internal
HYDRA_API_PORT_ALICE=4001
HYDRA_PEER_PORT_ALICE=5001
HYDRA_MONITORING_PORT_ALICE=6001

HYDRA_HOST_BOB=host.docker.internal
HYDRA_API_PORT_BOB=4002
HYDRA_PEER_PORT_BOB=5002
HYDRA_MONITORING_PORT_BOB=6002

HYDRA_HOST_CAROL=host.docker.internal
HYDRA_API_PORT_CAROL=4003
HYDRA_PEER_PORT_CAROL=5003
HYDRA_MONITORING_PORT_CAROL=6003

# Initial funding
INITIAL_FUNDS=1000
```

## Verify Complete Installation

### Run Full Verification

```bash
# 1. Check prerequisites
npm run prerequisites

# 2. Check Yaci connection
npm run example:status

# 3. List available commands
npm run
```

### Expected Output

All checks should pass:

```
✓ All prerequisites met!
✓ Yaci DevKit is running!
✓ All checks passed!
```

## Troubleshooting Installation Issues

### Node.js Version Mismatch

```bash
# If node version is too old
# Install nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install and use Node.js v20
nvm install 20
nvm use 20
```

### Docker Permission Denied

```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# macOS: Ensure Docker Desktop is running
open /Applications/Docker.app
```

### Yaci DevKit Connection Failed

```bash
# Check if Yaci is running
curl http://localhost:8080/api/v1/epochs/latest

# If not running, start it
devkit start

# Check for port conflicts
lsof -i :8080
```

### Port Already in Use

```bash
# Find process using the port
lsof -i :4001

# Kill the process
kill -9 <PID>

# Or use different ports in .env file
```

### Binary Download Fails

This is normal on macOS ARM and Windows. The project automatically falls back to Docker images. No action needed.

## Post-Installation

After successful installation:

1. ✅ Verify all prerequisites pass
2. ✅ Ensure Yaci DevKit is running
3. ✅ Confirm Docker is operational
4. ✅ Generate keys: `npm run keys:generate`
5. ✅ Fund wallets: `npm run wallets:fund`
6. ✅ Start Hydra: `npm run hydra:start`

## Next Steps

- [Getting Started Guide](getting-started.md) - Quick start tutorial
- [Configuration Guide](configuration.md) - Detailed configuration options
- [Usage Guide](usage.md) - How to use Hydra-Yaci

## Additional Resources

- [Yaci DevKit Documentation](https://devkit.yaci.xyz/)
- [Hydra Documentation](https://hydra.family/)
- [Docker Documentation](https://docs.docker.com/)
- [Node.js Documentation](https://nodejs.org/)

---

Having installation issues? Check the [Troubleshooting Guide](troubleshooting.md) or open an issue on GitHub.
