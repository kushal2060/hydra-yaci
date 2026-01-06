# Usage Guide

This guide covers how to use Hydra-Yaci for developing Layer 2 payment applications on Cardano.

## Overview

Hydra-Yaci provides a complete workflow for:

1. Generating cryptographic keys
2. Funding participant wallets
3. Starting Hydra nodes
4. Opening Hydra heads
5. Committing funds to heads
6. Sending instant payments
7. Closing Hydra heads
8. Monitoring the system

## NPM Scripts Reference

Quick reference of all available commands:

```bash
npm run prerequisites      # Check system requirements
npm run setup             # Setup project directories and binaries
npm run keys:generate     # Generate participant keys
npm run wallets:fund      # Fund participant wallets
npm run hydra:start       # Start all Hydra nodes
npm run hydra:stop        # Stop all Hydra nodes
npm run reset             # Reset all state and keys
npm run example:status    # Check Yaci DevKit status
npm run example:addresses # Generate and display addresses
npm run example:fund      # Fund from faucet
npm run example:open      # Open a Hydra head
npm run example:workflow  # Run complete workflow
```

## Workflow: Creating Your First Hydra Head

### Step 1: Generate Keys

Generate cryptographic keys for all participants:

```bash
npm run keys:generate
```

This creates keys in `hydra-nodes/{participant}/keys/`:

```
hydra-nodes/
├── alice/keys/
│   ├── cardano.sk       # Cardano signing key
│   ├── cardano.vk       # Cardano verification key
│   ├── hydra.sk         # Hydra signing key
│   └── hydra.vk         # Hydra verification key
├── bob/keys/
└── carol/keys/
```

**Output Example**:
```
Generating keys for alice...
  ✓ Hydra keys generated
  ✓ Cardano keys generated
  ✓ Address: addr_test1vq2kn3z4agl8...

Generating keys for bob...
  ✓ Hydra keys generated
  ✓ Cardano keys generated
  ✓ Address: addr_test1vr8hx7m9pcw5...

Generating keys for carol...
  ✓ Hydra keys generated
  ✓ Cardano keys generated
  ✓ Address: addr_test1vs9mp2x5vjh8...
```

### Step 2: Fund Wallets

Fund participant wallets using Yaci DevKit:

```bash
npm run wallets:fund
```

**Manual Funding** (alternative):

Using Yaci CLI:
```bash
# In Yaci CLI
topup addr_test1vq2kn3z4agl8... 1000
topup addr_test1vr8hx7m9pcw5... 1000
topup addr_test1vs9mp2x5vjh8... 1000
```

**Verify Funding**:
```bash
node examples/check-yaci.js
```

### Step 3: Publish Hydra Scripts

Publish Hydra protocol scripts to the blockchain:

```bash
./bin/hydra-node publish-scripts \
  --testnet-magic 42 \
  --node-socket /clusters/nodes/default/node/node.sock \
  --cardano-signing-key hydra-nodes/alice/keys/cardano.sk
```

**Copy the output transaction IDs** and add them to `.env`:

```bash
# Example output:
# νInitial: 0319848a47b887b565a08ddff6b61e2e19fff35072d6e0b57028bfb63577ddba
# νCommit: d46e139e4ffd649d5972e8db11ac68a4a373eca74747b2643f6d305dd0661d9f
# νHead: d044154a3dd15ea53edc23f84a0306611249f8f74025ae7cc60aedb0a99e1971

# Add to .env:
HYDRA_SCRIPTS_TX_ID="0319848a...,d46e139e...,d044154a..."
```

### Step 4: Start Hydra Nodes

Start all three Hydra nodes:

```bash
npm run hydra:start
```

This starts Docker containers for Alice, Bob, and Carol.

**Verify nodes are running**:
```bash
docker ps
```

Expected output:
```
CONTAINER ID   IMAGE                                    STATUS
abc123...      ghcr.io/cardano-scaling/hydra-node:1.2.0 Up 10 seconds
def456...      ghcr.io/cardano-scaling/hydra-node:1.2.0 Up 10 seconds
ghi789...      ghcr.io/cardano-scaling/hydra-node:1.2.0 Up 10 seconds
```

**Check logs**:
```bash
# Alice's logs
docker logs hydra-alice

# Bob's logs
docker logs hydra-bob

# Carol's logs
docker logs hydra-carol
```

### Step 5: Open a Hydra Head

Use the WebSocket API to open a head:

```bash
node examples/open-hydra-head.js
```

Or manually via WebSocket client:

**Connect to WebSocket**:
```
ws://localhost:4001
```

**Send Init message**:
```json
{
  "tag": "Init"
}
```

**Expected Response**:
```json
{
  "tag": "HeadIsInitializing",
  "headId": "4ea01a230b166e43748e28b9ecc729dcfca925038be66d7f9a3238b8",
  "parties": [...]
}
```

### Step 6: Commit Funds

Each participant must commit funds to the head:

```bash
node examples/commit-fund.js
```

**Manual Commit via WebSocket**:
```json
{
  "tag": "Commit",
  "utxo": {
    "txId": "transaction-id",
    "index": 0
  }
}
```

**Wait for all participants to commit**:
```json
{
  "tag": "HeadIsOpen",
  "utxo": {...}
}
```

### Step 7: Send Payments

Once the head is open, send instant payments:

```bash
node examples/send-payment.js
```

**Manual Payment via WebSocket**:
```json
{
  "tag": "NewTx",
  "transaction": {
    "type": "Tx ConwayEra",
    "description": "",
    "cborHex": "84a500818258..."
  }
}
```

**Payment Confirmed**:
```json
{
  "tag": "TxValid",
  "transaction": {...},
  "utxo": {...}
}
```

### Step 8: Close the Head

Close the Hydra head when finished:

```bash
node examples/close-head.js
```

**Manual Close via WebSocket**:
```json
{
  "tag": "Close"
}
```

**Head Finalized**:
```json
{
  "tag": "HeadIsFinalized",
  "utxo": {...}
}
```

## Working with the Hydra TUI

### Starting the TUI

The Hydra TUI (Terminal User Interface) provides a visual interface for managing Hydra heads.

**Launch for Alice**:
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

**Launch for Bob**:
```bash
docker run --rm -it \
  --name hydra-tui-bob \
  -v "$PWD/hydra-nodes:/app/hydra-nodes" \
  --platform linux/amd64 \
  ghcr.io/cardano-scaling/hydra-tui:1.2.0 \
  --connect host.docker.internal:4002 \
  --cardano-signing-key /app/hydra-nodes/bob/keys/cardano.sk \
  --testnet-magic 42
```

**Launch for Carol**:
```bash
docker run --rm -it \
  --name hydra-tui-carol \
  -v "$PWD/hydra-nodes:/app/hydra-nodes" \
  --platform linux/amd64 \
  ghcr.io/cardano-scaling/hydra-tui:1.2.0 \
  --connect host.docker.internal:4003 \
  --cardano-signing-key /app/hydra-nodes/carol/keys/cardano.sk \
  --testnet-magic 42
```

### TUI Features

The TUI shows:

- **Network Status**: Connected peers and network health
- **Head Status**: Current state (Initializing, Open, Closed, etc.)
- **UTxO Set**: Current balances in the head
- **Transactions**: Recent transactions
- **Logs**: Real-time event logs

### TUI Controls

| Key | Action |
|-----|--------|
| `i` | Initialize head |
| `c` | Commit funds |
| `n` | Create new transaction |
| `x` | Close head |
| `q` | Quit |
| `↑↓` | Scroll logs |

## WebSocket API Usage

### Connecting to the API

Each Hydra node exposes a WebSocket API:

- **Alice**: `ws://localhost:4001`
- **Bob**: `ws://localhost:4002`
- **Carol**: `ws://localhost:4003`

### Client Examples

#### Using `wscat`

```bash
# Install wscat
npm install -g wscat

# Connect to Alice
wscat -c ws://localhost:4001

# Send a message
> {"tag": "Init"}
```

#### Using JavaScript

```javascript
import WebSocket from 'ws';

const ws = new WebSocket('ws://localhost:4001');

ws.on('open', () => {
  console.log('Connected to Hydra node');
  
  // Initialize head
  ws.send(JSON.stringify({ tag: 'Init' }));
});

ws.on('message', (data) => {
  const message = JSON.parse(data);
  console.log('Received:', message);
});
```

#### Using Python

```python
import websocket
import json

def on_message(ws, message):
    data = json.loads(message)
    print('Received:', data)

def on_open(ws):
    print('Connected')
    ws.send(json.dumps({'tag': 'Init'}))

ws = websocket.WebSocketApp(
    'ws://localhost:4001',
    on_message=on_message,
    on_open=on_open
)

ws.run_forever()
```

### Message Types

#### Client → Server Messages

**Initialize Head**:
```json
{"tag": "Init"}
```

**Commit Funds**:
```json
{
  "tag": "Commit",
  "utxo": {
    "txId": "...",
    "index": 0
  }
}
```

**Send Transaction**:
```json
{
  "tag": "NewTx",
  "transaction": {
    "type": "Tx ConwayEra",
    "cborHex": "..."
  }
}
```

**Close Head**:
```json
{"tag": "Close"}
```

**Abort Head** (during initialization):
```json
{"tag": "Abort"}
```

#### Server → Client Messages

**Greetings** (connection established):
```json
{
  "tag": "Greetings",
  "me": {"vkey": "..."},
  "headStatus": "Idle",
  "hydraNodeVersion": "1.2.0",
  "networkInfo": {
    "networkConnected": true,
    "peersInfo": {...}
  }
}
```

**Head Initializing**:
```json
{
  "tag": "HeadIsInitializing",
  "headId": "...",
  "parties": [...]
}
```

**Committed** (funds committed):
```json
{
  "tag": "Committed",
  "party": {"vkey": "..."},
  "utxo": {...}
}
```

**Head Opened**:
```json
{
  "tag": "HeadIsOpen",
  "utxo": {...}
}
```

**Transaction Valid**:
```json
{
  "tag": "TxValid",
  "transaction": {...},
  "utxo": {...}
}
```

**Snapshot Confirmed**:
```json
{
  "tag": "SnapshotConfirmed",
  "snapshot": {
    "snapshotNumber": 1,
    "utxo": {...}
  }
}
```

**Head Closed**:
```json
{
  "tag": "HeadIsClosed",
  "snapshotNumber": 5
}
```

**Head Finalized**:
```json
{
  "tag": "HeadIsFinalized",
  "utxo": {...}
}
```

## Monitoring and Debugging

### Check Node Status

```bash
# Check if nodes are running
docker ps | grep hydra

# View logs
docker logs hydra-alice --tail 50 --follow
docker logs hydra-bob --tail 50 --follow
docker logs hydra-carol --tail 50 --follow
```

### Prometheus Metrics

Access metrics at:
- Alice: `http://localhost:6001/metrics`
- Bob: `http://localhost:6002/metrics`
- Carol: `http://localhost:6003/metrics`

### Grafana Dashboards

Start monitoring stack:

```bash
cd monitoring
docker compose -f docker-compose.monitoring.yml up -d
```

Access Grafana:
- URL: `http://localhost:3000`
- Username: `admin`
- Password: `admin`

### WebSocket Debugging

Use Postman or any WebSocket client:

1. Create a new WebSocket request
2. URL: `ws://localhost:4001`
3. Connect and view messages
4. Send custom messages

## Advanced Usage

### Multi-Head Management

Run multiple Hydra heads simultaneously:

```javascript
// Head 1: Alice, Bob
const head1 = new WebSocket('ws://localhost:4001');

// Head 2: Bob, Carol
const head2 = new WebSocket('ws://localhost:4002');

// Manage separately
head1.on('message', handleHead1Message);
head2.on('message', handleHead2Message);
```

### Custom Transaction Building

Use Lucid Evolution to build custom transactions:

```javascript
import { Lucid } from '@lucid-evolution/lucid';

const lucid = await Lucid.new();

const tx = await lucid
  .newTx()
  .payToAddress('addr_test1...', { lovelace: 1000000n })
  .complete();

// Submit to Hydra
ws.send(JSON.stringify({
  tag: 'NewTx',
  transaction: {
    type: 'Tx ConwayEra',
    cborHex: tx.toString()
  }
}));
```

### Automated Testing

Create test scripts:

```javascript
// test-hydra-flow.js
async function testHydraFlow() {
  // 1. Initialize
  await initHead();
  
  // 2. Commit
  await commitFunds();
  
  // 3. Send payments
  for (let i = 0; i < 10; i++) {
    await sendPayment(i);
  }
  
  // 4. Close
  await closeHead();
}

testHydraFlow().catch(console.error);
```

## Best Practices

### 1. Always Check Status

Before operations:
```bash
npm run example:status
```

### 2. Backup Keys

```bash
# Backup to secure location
cp -r hydra-nodes/alice/keys ~/secure-backup/
```

### 3. Monitor Logs

Keep logs running:
```bash
docker logs hydra-alice --follow &
docker logs hydra-bob --follow &
docker logs hydra-carol --follow &
```

### 4. Clean Shutdown

Always stop nodes properly:
```bash
npm run hydra:stop
```

### 5. Reset When Needed

If state becomes inconsistent:
```bash
npm run reset
npm run keys:generate
npm run wallets:fund
npm run hydra:start
```

## Common Tasks

### Check Wallet Balances

```bash
node -e "
import axios from 'axios';
const addr = 'addr_test1vq2kn...';
axios.get(\`http://localhost:8080/api/v1/addresses/\${addr}\`)
  .then(r => console.log(r.data));
"
```

### List All Running Containers

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### View Network Topology

```bash
# Check peer connections
curl http://localhost:4001 | jq '.networkInfo'
```

## Next Steps

- [Troubleshooting Guide](troubleshooting.md) - Fix common issues
- [API Reference](api-reference.md) - Complete API documentation
- [Configuration Guide](configuration.md) - Advanced configuration

---

Need help? Check the [Troubleshooting Guide](troubleshooting.md) or open an issue on GitHub.
