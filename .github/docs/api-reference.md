# API Reference

Complete API reference for Hydra-Yaci, including WebSocket API, example scripts, and NPM commands.

## Table of Contents

- [NPM Scripts API](#npm-scripts-api)
- [WebSocket API](#websocket-api)
- [Example Scripts](#example-scripts)
- [REST API (Yaci DevKit)](#rest-api-yaci-devkit)
- [Lucid Evolution API](#lucid-evolution-api)
- [Monitoring API](#monitoring-api)

## NPM Scripts API

### Prerequisites and Setup

#### `npm run prerequisites`

Check system requirements and prerequisites.

**Usage:**
```bash
npm run prerequisites
```

**Checks:**
- Node.js installation and version
- npm installation
- Docker installation
- curl and jq utilities
- Yaci DevKit status
- Port availability (4001-4003, 5001-5003, 6001-6003)

**Exit Codes:**
- `0` - All checks passed
- `1` - One or more checks failed

---

#### `npm run setup`

Setup project directories and download Hydra binaries.

**Usage:**
```bash
npm run setup
```

**Actions:**
- Creates `hydra-nodes` directory structure
- Downloads Hydra node binaries (if supported)
- Creates Docker wrapper scripts
- Sets up configuration files

---

### Key Management

#### `npm run keys:generate`

Generate cryptographic keys for all participants.

**Usage:**
```bash
npm run keys:generate
```

**Generates:**
- Hydra protocol signing and verification keys
- Cardano payment signing and verification keys
- Cardano addresses

**Output Location:**
- `hydra-nodes/alice/keys/`
- `hydra-nodes/bob/keys/`
- `hydra-nodes/carol/keys/`

---

### Wallet Management

#### `npm run wallets:fund`

Fund participant wallets using Yaci DevKit.

**Usage:**
```bash
npm run wallets:fund
```

**Amount:**
- Configured by `INITIAL_FUNDS` in `.env`
- Default: 1000 ADA

**Requirements:**
- Yaci DevKit running
- Keys already generated
- Yaci node created and started

---

### Hydra Node Management

#### `npm run hydra:start`

Start all Hydra nodes (Alice, Bob, Carol).

**Usage:**
```bash
npm run hydra:start
```

**Starts:**
- 3 Docker containers
- WebSocket API on ports 4001, 4002, 4003
- P2P networking on ports 5001, 5002, 5003
- Monitoring on ports 6001, 6002, 6003

**Requirements:**
- Docker running
- Keys generated
- Wallets funded
- Hydra scripts published

---

#### `npm run hydra:stop`

Stop all Hydra nodes.

**Usage:**
```bash
npm run hydra:stop
```

**Actions:**
- Stops Docker containers
- Preserves state and keys
- Closes network connections

---

### Maintenance

#### `npm run reset`

Reset all state and keys.

**Usage:**
```bash
npm run reset
```

**Warning:** This deletes all generated keys and state!

**Deletes:**
- All participant keys
- Generated addresses
- Hydra node state
- Transaction history

---

### Examples

#### `npm run example:status`

Check Yaci DevKit status and blockchain information.

**Usage:**
```bash
npm run example:status
```

**Output:**
- Current epoch
- Block count
- Transaction count
- Latest block information
- Network magic

---

#### `npm run example:addresses`

Generate and display participant addresses.

**Usage:**
```bash
npm run example:addresses
```

**Output:**
- Alice's address
- Bob's address
- Carol's address

---

#### `npm run example:fund`

Fund wallets from Yaci faucet.

**Usage:**
```bash
npm run example:fund
```

**Amount:**
- Configured in script
- Default: 1000 ADA per wallet

---

#### `npm run example:open`

Open a Hydra head.

**Usage:**
```bash
npm run example:open
```

**Actions:**
1. Connects to Hydra nodes
2. Sends Init message
3. Waits for initialization
4. Returns head ID

---

#### `npm run example:workflow`

Run complete Hydra workflow.

**Usage:**
```bash
npm run example:workflow
```

**Workflow:**
1. Check Yaci status
2. Generate addresses
3. Fund wallets
4. Open Hydra head
5. Commit funds
6. Send test payment
7. Close head

---

## WebSocket API

### Connection

Connect to a Hydra node's WebSocket API:

```javascript
const ws = new WebSocket('ws://localhost:4001');
```

**Endpoints:**
- Alice: `ws://localhost:4001`
- Bob: `ws://localhost:4002`
- Carol: `ws://localhost:4003`

### Client Messages (Client → Server)

#### Init

Initialize a new Hydra head.

```json
{
  "tag": "Init"
}
```

**Requirements:**
- All participants connected
- Wallets funded

**Response:** `HeadIsInitializing`

---

#### Commit

Commit UTxO to the head.

```json
{
  "tag": "Commit",
  "utxo": {
    "<tx_id>#<index>": {
      "address": "addr_test1...",
      "value": {
        "lovelace": 1000000
      }
    }
  }
}
```

**Requirements:**
- Head in initializing state
- UTxO exists in wallet

**Response:** `Committed`

---

#### NewTx

Submit a new transaction to the head.

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

**Requirements:**
- Head is open
- Valid transaction CBOR

**Response:** `TxValid` or `TxInvalid`

---

#### Close

Close the Hydra head.

```json
{
  "tag": "Close"
}
```

**Requirements:**
- Head is open

**Response:** `HeadIsClosed`

---

#### Abort

Abort head initialization.

```json
{
  "tag": "Abort"
}
```

**Requirements:**
- Head is initializing
- Not all participants committed

**Response:** `HeadIsAborted`

---

### Server Messages (Server → Client)

#### Greetings

First message when connecting.

```json
{
  "tag": "Greetings",
  "me": {
    "vkey": "a5c2e70fe94108c2cb1c559942f0152525ae2350f6dc7ce631b3c5313aff7932"
  },
  "headStatus": "Idle",
  "hydraNodeVersion": "1.2.0",
  "hydraHeadId": null,
  "snapshotUtxo": {},
  "networkInfo": {
    "networkConnected": true,
    "peersInfo": {
      "host.docker.internal:5001": true,
      "host.docker.internal:5002": true
    }
  }
}
```

---

#### HeadIsInitializing

Head initialization started.

```json
{
  "tag": "HeadIsInitializing",
  "headId": "4ea01a230b166e43748e28b9ecc729dcfca925038be66d7f9a3238b8",
  "parties": [
    {"vkey": "a2a080fd6497ffba122fc8450b74e0732ae760952d52d3be144469472ee231fc"},
    {"vkey": "8f6f9e73f34cf65a8471c76f50aacafae66401a6fab3bd918fc67a7de8b43df1"},
    {"vkey": "a5c2e70fe94108c2cb1c559942f0152525ae2350f6dc7ce631b3c5313aff7932"}
  ]
}
```

---

#### Committed

Participant committed funds.

```json
{
  "tag": "Committed",
  "party": {
    "vkey": "a5c2e70fe94108c2cb1c559942f0152525ae2350f6dc7ce631b3c5313aff7932"
  },
  "utxo": {
    "<tx_id>#<index>": {
      "address": "addr_test1...",
      "value": {"lovelace": 1000000}
    }
  }
}
```

---

#### HeadIsOpen

Head successfully opened.

```json
{
  "tag": "HeadIsOpen",
  "utxo": {
    "<tx_id>#<index>": {
      "address": "addr_test1...",
      "value": {"lovelace": 3000000}
    }
  }
}
```

---

#### TxValid

Transaction confirmed valid.

```json
{
  "tag": "TxValid",
  "transaction": {
    "type": "Tx ConwayEra",
    "cborHex": "..."
  },
  "utxo": {...}
}
```

---

#### TxInvalid

Transaction rejected.

```json
{
  "tag": "TxInvalid",
  "transaction": {...},
  "validationError": {
    "reason": "MissingInput",
    "utxo": "<tx_id>#<index>"
  }
}
```

---

#### SnapshotConfirmed

Snapshot confirmed by all parties.

```json
{
  "tag": "SnapshotConfirmed",
  "snapshot": {
    "snapshotNumber": 1,
    "utxo": {...},
    "confirmedTransactions": [...]
  }
}
```

---

#### HeadIsClosed

Head closed on-chain.

```json
{
  "tag": "HeadIsClosed",
  "snapshotNumber": 5,
  "contestationDeadline": "2024-01-15T12:00:00Z"
}
```

---

#### HeadIsFinalized

Head finalized and funds distributed.

```json
{
  "tag": "HeadIsFinalized",
  "utxo": {
    "<tx_id>#<index>": {
      "address": "addr_test1...",
      "value": {"lovelace": 1500000}
    }
  }
}
```

---

## Example Scripts

### check-yaci.js

Check Yaci DevKit status.

**Usage:**
```bash
node examples/check-yaci.js
```

**Output:**
- Connection status
- Epoch information
- Block information
- Network details

---

### generate-address.js

Generate Cardano addresses from keys.

**Usage:**
```bash
node examples/generate-address.js
```

**Output:**
- Alice's address
- Bob's address
- Carol's address

---

### fund-from-faucet.js

Fund wallets from Yaci faucet.

**Usage:**
```bash
node examples/fund-from-faucet.js
```

**Parameters:**
- Uses addresses from generated keys
- Amount from environment or default

---

### open-hydra-head.js

Open a Hydra head.

**Usage:**
```bash
node examples/open-hydra-head.js
```

**Flow:**
1. Connect to all nodes
2. Send Init
3. Wait for HeadIsInitializing
4. Display head ID

---

### commit-fund.js

Commit funds to head.

**Usage:**
```bash
node examples/commit-fund.js
```

**Parameters:**
- UTxO to commit
- Amount to commit

---

### send-payment.js

Send payment within Hydra head.

**Usage:**
```bash
node examples/send-payment.js
```

**Parameters:**
- Recipient address
- Amount in lovelace

---

### close-head.js

Close the Hydra head.

**Usage:**
```bash
node examples/close-head.js
```

**Flow:**
1. Connect to node
2. Send Close
3. Wait for HeadIsClosed
4. Wait for HeadIsFinalized

---

## REST API (Yaci DevKit)

### Base URL

```
http://localhost:8080/api/v1
```

### Endpoints

#### GET /epochs/latest

Get latest epoch information.

**Response:**
```json
{
  "epoch": 0,
  "blkCount": 45,
  "txCount": 0,
  "startTime": 1704364800,
  "endTime": null
}
```

---

#### GET /blocks/latest

Get latest block.

**Response:**
```json
{
  "number": 45,
  "hash": "abc123...",
  "time": 1704364845,
  "epoch": 0,
  "slot": 900
}
```

---

#### GET /addresses/{address}

Get address information and balance.

**Response:**
```json
{
  "address": "addr_test1...",
  "balance": {
    "lovelace": 1000000000
  },
  "utxos": [...]
}
```

---

#### POST /transactions

Submit a transaction.

**Request:**
```json
{
  "cborHex": "84a500818258..."
}
```

**Response:**
```json
{
  "txHash": "def456..."
}
```

---

## Lucid Evolution API

### Initialize Lucid

```javascript
import { Lucid } from '@lucid-evolution/lucid';
import { Blockfrost } from '@lucid-evolution/provider';

const lucid = await Lucid.new(
  new Blockfrost('http://localhost:8080/api/v1'),
  'Custom'
);
```

### Build Transaction

```javascript
const tx = await lucid
  .newTx()
  .payToAddress('addr_test1...', { lovelace: 1000000n })
  .complete();

const signedTx = await tx.sign().complete();
const txHash = await signedTx.submit();
```

### Query UTxOs

```javascript
const utxos = await lucid.utxosAt('addr_test1...');
```

### Get Wallet Address

```javascript
const address = await lucid.wallet.address();
```

---

## Monitoring API

### Prometheus Metrics

**Endpoints:**
- Alice: `http://localhost:6001/metrics`
- Bob: `http://localhost:6002/metrics`
- Carol: `http://localhost:6003/metrics`

### Key Metrics

#### hydra_head_status

Current head status (0=Idle, 1=Initializing, 2=Open, 3=Closed).

```
hydra_head_status 2.0
```

#### hydra_snapshot_number

Current snapshot number.

```
hydra_snapshot_number 5.0
```

#### hydra_tx_confirmation_time_seconds

Transaction confirmation time.

```
hydra_tx_confirmation_time_seconds_bucket{le="0.1"} 10
```

#### hydra_connected_peers

Number of connected peers.

```
hydra_connected_peers 2.0
```

---

## Error Codes

### WebSocket Errors

| Code | Message | Description |
|------|---------|-------------|
| 1000 | Normal closure | Clean shutdown |
| 1001 | Going away | Node shutting down |
| 1006 | Abnormal closure | Connection lost |

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad request |
| 404 | Not found |
| 500 | Internal server error |
| 503 | Service unavailable |

---

## Type Definitions

### UTxO

```typescript
type UTxO = {
  [key: string]: {
    address: string;
    value: {
      lovelace: number;
      [assetId: string]: number;
    };
    datum?: string;
    datumHash?: string;
    scriptRef?: string;
  };
};
```

### Party

```typescript
type Party = {
  vkey: string;
};
```

### Transaction

```typescript
type Transaction = {
  type: "Tx ConwayEra" | "Tx BabbageEra";
  description: string;
  cborHex: string;
};
```

### HeadStatus

```typescript
type HeadStatus = 
  | "Idle"
  | "Initializing"
  | "Open"
  | "Closed"
  | "Final";
```

---

## Rate Limits

- **WebSocket**: No rate limit
- **Yaci API**: 100 requests/second
- **Prometheus**: 1 request/second recommended

---

## Best Practices

1. **Always handle WebSocket reconnection**
2. **Validate transaction CBOR before submitting**
3. **Wait for SnapshotConfirmed before assuming finality**
4. **Monitor Prometheus metrics for performance**
5. **Use proper error handling for all API calls**

---

## Additional Resources

- [Hydra Protocol Specification](https://hydra.family/head-protocol/)
- [Yaci DevKit API Docs](https://devkit.yaci.xyz/api)
- [Lucid Evolution Docs](https://github.com/lucid-evolution/lucid)
- [Cardano Developer Portal](https://developers.cardano.org/)

---

Need more examples? Check the [Usage Guide](usage.md) or [example scripts](https://github.com/kushal2060/hydra-yaci/tree/main/examples).
