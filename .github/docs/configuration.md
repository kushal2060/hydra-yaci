# Configuration Guide

This guide covers all configuration options for Hydra-Yaci, including environment variables, network settings, and participant configuration.

## Environment Variables

### Overview

Hydra-Yaci uses a `.env` file for configuration. All settings are optional and have sensible defaults.

### Creating Your Configuration

```bash
# Copy the example file
cp .env.example .env

# Edit with your preferred editor
nano .env
# or
vim .env
```

## Configuration Sections

### 1. Yaci DevKit Configuration

Configure connection to your Yaci DevKit instance.

```bash
# Yaci DevKit API URL
YACI_API_URL=http://localhost:8080/api/v1

# Ogmios WebSocket URL (for transaction submission)
YACI_OGMIOS_URL=ws://localhost:1337
```

#### Options:

| Variable | Default | Description |
|----------|---------|-------------|
| `YACI_API_URL` | `http://localhost:8080/api/v1` | Yaci REST API endpoint |
| `YACI_OGMIOS_URL` | `ws://localhost:1337` | Ogmios WebSocket endpoint |

#### Remote Yaci Instance:

If running Yaci on a different machine:

```bash
YACI_API_URL=http://192.168.1.100:8080/api/v1
YACI_OGMIOS_URL=ws://192.168.1.100:1337
```

### 2. Network Configuration

Configure Cardano network parameters.

```bash
# Network magic number (Yaci DevKit default)
NETWORK_MAGIC=42

# Cardano node socket path (optional)
# CARDANO_NODE_SOCKET_PATH=/tmp/yaci-devkit/node.socket
```

#### Options:

| Variable | Default | Description |
|----------|---------|-------------|
| `NETWORK_MAGIC` | `42` | Network magic number (testnet identifier) |
| `CARDANO_NODE_SOCKET_PATH` | (auto) | Path to Cardano node socket |

#### Network Magic Values:

- `42` - Yaci DevKit default
- `1` - Mainnet (not recommended for development)
- `2` - Preprod testnet
- `3` - Preview testnet

### 3. Hydra Version

Specify which Hydra version to use.

```bash
# Hydra node version
HYDRA_VERSION=1.2.0
```

#### Options:

| Variable | Default | Description |
|----------|---------|-------------|
| `HYDRA_VERSION` | `1.2.0` | Hydra node Docker image version |

#### Supported Versions:

- `1.2.0` - Latest stable (recommended)
- `1.1.0` - Previous stable
- `latest` - Latest development build (not recommended)

### 4. Alice Configuration

Configure the first Hydra participant (Alice).

```bash
# Alice's host
HYDRA_HOST_ALICE=host.docker.internal

# Alice's API port (WebSocket + REST)
HYDRA_API_PORT_ALICE=4001

# Alice's peer-to-peer port
HYDRA_PEER_PORT_ALICE=5001

# Alice's monitoring port (Prometheus metrics)
HYDRA_MONITORING_PORT_ALICE=6001
```

#### Options:

| Variable | Default | Description |
|----------|---------|-------------|
| `HYDRA_HOST_ALICE` | `host.docker.internal` | Hostname/IP for Alice's node |
| `HYDRA_API_PORT_ALICE` | `4001` | API and WebSocket port |
| `HYDRA_PEER_PORT_ALICE` | `5001` | P2P communication port |
| `HYDRA_MONITORING_PORT_ALICE` | `6001` | Metrics endpoint port |

### 5. Bob Configuration

Configure the second Hydra participant (Bob).

```bash
# Bob's host
HYDRA_HOST_BOB=host.docker.internal

# Bob's API port
HYDRA_API_PORT_BOB=4002

# Bob's peer-to-peer port
HYDRA_PEER_PORT_BOB=5002

# Bob's monitoring port
HYDRA_MONITORING_PORT_BOB=6002
```

#### Options:

| Variable | Default | Description |
|----------|---------|-------------|
| `HYDRA_HOST_BOB` | `host.docker.internal` | Hostname/IP for Bob's node |
| `HYDRA_API_PORT_BOB` | `4002` | API and WebSocket port |
| `HYDRA_PEER_PORT_BOB` | `5002` | P2P communication port |
| `HYDRA_MONITORING_PORT_BOB` | `6002` | Metrics endpoint port |

### 6. Carol Configuration

Configure the third Hydra participant (Carol).

```bash
# Carol's host
HYDRA_HOST_CAROL=host.docker.internal

# Carol's API port
HYDRA_API_PORT_CAROL=4003

# Carol's peer-to-peer port
HYDRA_PEER_PORT_CAROL=5003

# Carol's monitoring port
HYDRA_MONITORING_PORT_CAROL=6003
```

#### Options:

| Variable | Default | Description |
|----------|---------|-------------|
| `HYDRA_HOST_CAROL` | `host.docker.internal` | Hostname/IP for Carol's node |
| `HYDRA_API_PORT_CAROL` | `4003` | API and WebSocket port |
| `HYDRA_PEER_PORT_CAROL` | `5003` | P2P communication port |
| `HYDRA_MONITORING_PORT_CAROL` | `6003` | Metrics endpoint port |

### 7. Funding Configuration

Configure initial wallet funding amounts.

```bash
# Initial funding amount in ADA
INITIAL_FUNDS=1000
```

#### Options:

| Variable | Default | Description |
|----------|---------|-------------|
| `INITIAL_FUNDS` | `1000` | Initial ADA to fund each wallet |

### 8. Hydra Scripts Configuration

Configure Hydra protocol script transaction IDs.

```bash
# Hydra scripts transaction IDs (comma-separated)
HYDRA_SCRIPTS_TX_ID="hash1,hash2,hash3"
```

#### How to Get Script IDs:

After publishing scripts, copy the transaction hashes:

```bash
./bin/hydra-node publish-scripts \
  --testnet-magic 42 \
  --node-socket /clusters/nodes/default/node/node.sock \
  --cardano-signing-key hydra-nodes/alice/keys/cardano.sk
```

Output:
```
Published scripts:
  νInitial: 0319848a47b887b565a08ddff6b61e2e19fff35072d6e0b57028bfb63577ddba
  νCommit: d46e139e4ffd649d5972e8db11ac68a4a373eca74747b2643f6d305dd0661d9f
  νHead: d044154a3dd15ea53edc23f84a0306611249f8f74025ae7cc60aedb0a99e1971
```

Add to `.env`:
```bash
HYDRA_SCRIPTS_TX_ID="0319848a...,d46e139e...,d044154a..."
```

## Advanced Configuration

### Multi-Machine Setup

Running participants on different machines:

#### Machine 1 (Alice):
```bash
# .env on Machine 1
HYDRA_HOST_ALICE=0.0.0.0
HYDRA_HOST_BOB=192.168.1.101
HYDRA_HOST_CAROL=192.168.1.102
```

#### Machine 2 (Bob):
```bash
# .env on Machine 2
HYDRA_HOST_ALICE=192.168.1.100
HYDRA_HOST_BOB=0.0.0.0
HYDRA_HOST_CAROL=192.168.1.102
```

#### Machine 3 (Carol):
```bash
# .env on Machine 3
HYDRA_HOST_ALICE=192.168.1.100
HYDRA_HOST_BOB=192.168.1.101
HYDRA_HOST_CAROL=0.0.0.0
```

### Custom Port Configuration

To avoid port conflicts, customize all ports:

```bash
# Alice - starting at 7000
HYDRA_API_PORT_ALICE=7001
HYDRA_PEER_PORT_ALICE=7002
HYDRA_MONITORING_PORT_ALICE=7003

# Bob - starting at 8000
HYDRA_API_PORT_BOB=8001
HYDRA_PEER_PORT_BOB=8002
HYDRA_MONITORING_PORT_BOB=8003

# Carol - starting at 9000
HYDRA_API_PORT_CAROL=9001
HYDRA_PEER_PORT_CAROL=9002
HYDRA_MONITORING_PORT_CAROL=9003
```

### Docker Network Configuration

For custom Docker networks:

```bash
# Create custom network
docker network create hydra-network

# Update start script to use custom network
# Edit scripts/start-hydra.sh and add:
# --network hydra-network
```

## Hydra Node Configuration

### Protocol Parameters

Edit `config/hydra/protocol-parameters.json` for Cardano protocol parameters:

```json
{
  "protocolVersion": {
    "major": 8,
    "minor": 0
  },
  "minFeeA": 44,
  "minFeeB": 155381,
  "maxBlockBodySize": 90112,
  "maxTxSize": 16384,
  "maxBlockHeaderSize": 1100,
  "keyDeposit": 2000000,
  "poolDeposit": 500000000,
  "minPoolCost": 340000000,
  "priceMem": 0.0577,
  "priceStep": 0.0000721,
  "maxTxExecutionUnits": {
    "memory": 14000000,
    "steps": 10000000000
  },
  "maxBlockExecutionUnits": {
    "memory": 62000000,
    "steps": 20000000000
  },
  "maxValueSize": 5000,
  "collateralPercentage": 150,
  "maxCollateralInputs": 3,
  "coinsPerUTxOByte": 4310
}
```

### Contestation Period

The contestation period determines how long participants have to contest a head closure.

**Default**: 600 seconds (10 minutes)

To modify, edit the start script parameters in `scripts/start-hydra.sh`:

```bash
--contestation-period 1200  # 20 minutes
```

### Deposit Period

The deposit period is the time window for participants to deposit funds into the head.

**Default**: 3600 seconds (1 hour)

To modify:

```bash
--deposit-period 7200  # 2 hours
```

## Monitoring Configuration

### Prometheus

Edit `monitoring/prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'hydra-alice'
    static_configs:
      - targets: ['host.docker.internal:6001']
  
  - job_name: 'hydra-bob'
    static_configs:
      - targets: ['host.docker.internal:6002']
  
  - job_name: 'hydra-carol'
    static_configs:
      - targets: ['host.docker.internal:6003']
```

### Grafana

Grafana dashboards are pre-configured in `monitoring/grafana/dashboards/`.

To customize:

1. Access Grafana: `http://localhost:3000`
2. Default credentials: `admin` / `admin`
3. Edit dashboards or create new ones

## Security Configuration

### Key Management

Keys are stored in `hydra-nodes/{participant}/keys/`:

```
hydra-nodes/
├── alice/
│   └── keys/
│       ├── cardano.sk       # Cardano signing key
│       ├── cardano.vk       # Cardano verification key
│       ├── hydra.sk         # Hydra signing key
│       └── hydra.vk         # Hydra verification key
├── bob/
│   └── keys/
└── carol/
    └── keys/
```

**Important**: 
- Never commit keys to version control
- Keys are in `.gitignore` by default
- Backup keys securely

### File Permissions

Secure key files:

```bash
# Set restrictive permissions
chmod 600 hydra-nodes/*/keys/*.sk
chmod 644 hydra-nodes/*/keys/*.vk
```

## Validation

### Verify Configuration

```bash
# Check if configuration is valid
npm run prerequisites

# Test Yaci connection
npm run example:status
```

### Check Port Availability

```bash
# Linux/macOS
lsof -i :4001
lsof -i :4002
lsof -i :4003

# Or use the built-in checker
npm run prerequisites
```

### Validate Environment Variables

Create a validation script:

```bash
#!/bin/bash
source .env

echo "Checking environment variables..."
echo "YACI_API_URL: ${YACI_API_URL}"
echo "NETWORK_MAGIC: ${NETWORK_MAGIC}"
echo "HYDRA_VERSION: ${HYDRA_VERSION}"
echo "Alice API Port: ${HYDRA_API_PORT_ALICE}"
echo "Bob API Port: ${HYDRA_API_PORT_BOB}"
echo "Carol API Port: ${HYDRA_API_PORT_CAROL}"
```

## Configuration Examples

### Example 1: Development Setup

Minimal configuration for local development:

```bash
YACI_API_URL=http://localhost:8080/api/v1
YACI_OGMIOS_URL=ws://localhost:1337
NETWORK_MAGIC=42
HYDRA_VERSION=1.2.0
INITIAL_FUNDS=1000
```

### Example 2: Multi-Machine Production

Configuration for distributed participants:

```bash
# Network
NETWORK_MAGIC=2  # Preprod testnet
HYDRA_VERSION=1.2.0

# Remote Yaci instance
YACI_API_URL=http://yaci-server:8080/api/v1
YACI_OGMIOS_URL=ws://yaci-server:1337

# Distributed participants
HYDRA_HOST_ALICE=alice.example.com
HYDRA_HOST_BOB=bob.example.com
HYDRA_HOST_CAROL=carol.example.com

# High funding for production
INITIAL_FUNDS=10000
```

### Example 3: Testing with Custom Ports

Configuration to avoid conflicts:

```bash
YACI_API_URL=http://localhost:8080/api/v1
NETWORK_MAGIC=42

# Custom port range
HYDRA_API_PORT_ALICE=14001
HYDRA_PEER_PORT_ALICE=15001
HYDRA_MONITORING_PORT_ALICE=16001

HYDRA_API_PORT_BOB=14002
HYDRA_PEER_PORT_BOB=15002
HYDRA_MONITORING_PORT_BOB=16002

HYDRA_API_PORT_CAROL=14003
HYDRA_PEER_PORT_CAROL=15003
HYDRA_MONITORING_PORT_CAROL=16003
```

## Troubleshooting Configuration

### Configuration Not Loaded

```bash
# Ensure .env is in the project root
ls -la .env

# Check if dotenv is installed
npm list dotenv
```

### Invalid Port Numbers

Ports must be:
- Between 1024 and 65535
- Not already in use
- Different for each service

### Connection Issues

```bash
# Test Yaci connection
curl ${YACI_API_URL}/epochs/latest

# Test Hydra node API
curl http://localhost:4001
```

## Next Steps

- [Usage Guide](usage.md) - Learn how to use configured nodes
- [Troubleshooting](troubleshooting.md) - Fix configuration issues
- [API Reference](api-reference.md) - API endpoints and examples

---

Need help with configuration? Check the [Troubleshooting Guide](troubleshooting.md) or open an issue on GitHub.
