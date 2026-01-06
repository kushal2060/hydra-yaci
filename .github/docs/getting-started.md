# Getting Started

This guide will help you get up and running with Hydra-Yaci in under 30 minutes.

## What is Hydra-Yaci?

Hydra-Yaci is a development environment that combines:

- **Yaci DevKit**: A fast, local Cardano blockchain for development
- **Hydra Protocol**: Cardano's Layer 2 scaling solution
- **Payment Channels**: Instant, low-cost transactions between participants

Think of it as a complete sandbox for building and testing Cardano Layer 2 applications.

## What You'll Build

By the end of this guide, you'll have:

1. ✅ A running Yaci DevKit local blockchain
2. ✅ Three Hydra nodes (for Alice, Bob, and Carol)
3. ✅ Generated keys and funded wallets
4. ✅ An open Hydra head for instant payments
5. ✅ Sent your first Hydra payment

## Prerequisites

Before starting, make sure you have these tools installed:

### Required Software

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Node.js | v18.0.0 | JavaScript runtime |
| npm | v9.0.0 | Package manager |
| Docker | Latest | Container runtime |
| Yaci DevKit | Latest | Local Cardano network |
| curl | Any | HTTP client |
| jq | Any | JSON processor |

### System Requirements

- **OS**: Linux, macOS, or Windows (with WSL2)
- **RAM**: 8GB minimum, 16GB recommended
- **Disk Space**: 5GB free space
- **CPU**: Multi-core processor recommended

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/kushal2060/hydra-yaci
cd hydra-yaci
```

### 2. Install Dependencies

```bash
npm install
```

This installs:
- Lucid Evolution (Cardano library)
- WebSocket client
- CLI utilities (chalk, dotenv, axios)

### 3. Check Prerequisites

Run the prerequisite checker to verify your environment:

```bash
npm run prerequisites
```

You should see output like:

```
✓ node is installed
  Version: v20.x.x
✓ npm is installed
✓ curl is installed
✓ jq is installed
✓ docker is installed
✓ Yaci DevKit is running
  Current Epoch: 0
✓ Port 4001 is available
✓ Port 4002 is available
✓ Port 4003 is available
✓ Port 5001 is available
✓ Port 5002 is available
✓ Port 5003 is available
✓ All prerequisites met!
```

If any checks fail, install the missing tools before continuing.

### 4. Start Yaci DevKit

If Yaci DevKit is not running, start it in a separate terminal:

```bash
devkit start
```

Wait for the output:
```
Yaci DevKit started successfully!
API available at: http://localhost:8080
```

**Optional**: Create and start a local node:
```bash
create-node -o --start
```

### 5. Configure Environment

Copy the example environment file:

```bash
cp .env.example .env
```

The default configuration works for most setups. Key settings:

```bash
# Yaci DevKit connection
YACI_API_URL=http://localhost:8080/api/v1
YACI_OGMIOS_URL=ws://localhost:1337

# Network magic (Yaci default)
NETWORK_MAGIC=42

# Hydra version
HYDRA_VERSION=1.2.0

# Participant ports (Alice, Bob, Carol)
HYDRA_API_PORT_ALICE=4001
HYDRA_API_PORT_BOB=4002
HYDRA_API_PORT_CAROL=4003
```

### 6. Setup Project

Run the setup script to prepare directories and download Hydra binaries:

```bash
npm run setup
```

This will:
- Create necessary directories
- Download Hydra node binaries (if applicable)
- Set up Docker wrappers

**Note for macOS/Windows**: If binary downloads fail, the project will use Docker images instead. This is normal and expected.

### 7. Verify Yaci Connection

Test the connection to Yaci DevKit:

```bash
npm run example:status
```

Expected output:

```
==================================================
Checking yaci status...
==================================================

connecting to Yaci DevKit...
URL: http://localhost:8080/api/v1

Fetching blockchain info...
Yaci devkit is running!

Blockchain Information:
  Current Epoch: 0
  Blocks: 45
  Transactions: 0

Latest Block:
  Block Number: 45
  Block Hash: abcd1234...
  Time: 2024-01-15T10:30:00Z

Network:
  Network Magic: 42
  Network ID: 0

✓ All checks passed!
```

### 8. Generate Keys

Generate cryptographic keys for all participants:

```bash
npm run keys:generate
```

Output:

```
Generating keys for alice...
  - Generating Hydra protocol keys...
  - Generating Cardano payment keys...
  - Generating Cardano address...
  ✓ Address: addr_test1vq2kn...
  ✓ Keys generated for alice

Generating keys for bob...
  - Generating Hydra protocol keys...
  - Generating Cardano payment keys...
  - Generating Cardano address...
  ✓ Address: addr_test1vr8hx...
  ✓ Keys generated for bob

Generating keys for carol...
  - Generating Hydra protocol keys...
  - Generating Cardano payment keys...
  - Generating Cardano address...
  ✓ Address: addr_test1vs9mp...
  ✓ Keys generated for carol

Generated keys for:
  alice: addr_test1vq2kn...
  bob: addr_test1vr8hx...
  carol: addr_test1vs9mp...
```

### 9. Fund Wallets

Fund the participant wallets using Yaci DevKit:

```bash
npm run wallets:fund
```

**Manual Funding** (if automated funding fails):

Open the Yaci CLI and run:

```bash
topup addr_test1vq2kn... 1000
topup addr_test1vr8hx... 1000
topup addr_test1vs9mp... 1000
```

Replace the addresses with your actual generated addresses.

### 10. Publish Hydra Scripts

Publish Hydra protocol scripts to the blockchain:

```bash
./bin/hydra-node publish-scripts \
  --testnet-magic 42 \
  --node-socket /clusters/nodes/default/node/node.sock \
  --cardano-signing-key hydra-nodes/alice/keys/cardano.sk
```

This outputs three transaction hashes. Copy them and add to your `.env` file:

```bash
HYDRA_SCRIPTS_TX_ID="hash1,hash2,hash3"
```

### 11. Start Hydra Nodes

Start all three Hydra nodes:

```bash
npm run hydra:start
```

This starts Docker containers for Alice, Bob, and Carol, exposing:
- **Alice**: Port 4001 (API), 5001 (P2P), 6001 (Monitoring)
- **Bob**: Port 4002 (API), 5002 (P2P), 6002 (Monitoring)
- **Carol**: Port 4003 (API), 5003 (P2P), 6003 (Monitoring)

Verify containers are running:

```bash
docker ps
```

### 12. Connect with Hydra TUI (Optional)

Launch the Hydra Terminal User Interface for visual management:

```bash
docker run --rm -it \
  --name hydra-tui-alice \
  -v "$PWD/hydra-nodes:/app/hydra-nodes" \
  --platform linux/amd64 \
  ghcr.io/cardano-scaling/hydra-tui:1.2.0 \
  --connect host.docker.internal:4001 \
  --cardano-signing-key /app/hydra-nodes/alice/keys/cardano.sk \
  --testnet-magic 42
```

You should see the Hydra TUI interface showing network status and head state.

## Next Steps

Congratulations! You now have a running Hydra development environment. Here's what to explore next:

1. **[Usage Guide](usage.md)**: Learn how to open heads and send payments
2. **[Configuration Guide](configuration.md)**: Customize your setup
3. **[API Reference](api-reference.md)**: Explore WebSocket API and examples
4. **[Troubleshooting](troubleshooting.md)**: Fix common issues

## Quick Test

Run a complete workflow to test everything:

```bash
npm run example:workflow
```

This will:
1. Check Yaci status
2. Generate addresses
3. Fund wallets
4. Open a Hydra head
5. Send a payment
6. Close the head

## Common Issues

### Yaci DevKit Not Running
```
Error: connect ECONNREFUSED 127.0.0.1:8080
```

**Solution**: Start Yaci DevKit with `devkit start`

### Port Already in Use
```
Error: Port 4001 is already in use
```

**Solution**: Stop existing Hydra nodes with `npm run hydra:stop`

### Binary Not Found (macOS/Windows)
```
Warning: Binary download failed
```

**Solution**: This is expected on ARM Macs and Windows. The project will use Docker images automatically.

### Docker Connection Issues
```
Error: Cannot connect to Docker daemon
```

**Solution**: Make sure Docker Desktop is running

## Getting Help

- Check the [Troubleshooting Guide](troubleshooting.md)
- Review [Yaci DevKit Documentation](https://devkit.yaci.xyz/)
- Open an issue on GitHub

---

Ready to dive deeper? Continue to the [Usage Guide](usage.md) to learn how to work with Hydra heads and payments.
