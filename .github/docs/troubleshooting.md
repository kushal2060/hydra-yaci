# Troubleshooting Guide

This guide helps you diagnose and fix common issues with Hydra-Yaci.

## Quick Diagnostics

### Run Health Check

```bash
# Check all prerequisites
npm run prerequisites

# Check Yaci status
npm run example:status

# Check Docker
docker ps

# Check ports
lsof -i :4001
lsof -i :4002
lsof -i :4003
```

## Common Issues

### 1. Yaci DevKit Not Running

#### Symptoms
```
Error: connect ECONNREFUSED 127.0.0.1:8080
```

#### Diagnosis
```bash
# Check if Yaci is running
curl http://localhost:8080/api/v1/epochs/latest

# Check Yaci process
ps aux | grep yaci
```

#### Solution
```bash
# Start Yaci DevKit
devkit start

# Or restart if already running
devkit stop
devkit start

# Verify it's running
curl http://localhost:8080/api/v1/epochs/latest
```

#### Alternative: Wrong URL
Check your `.env` file:
```bash
# Should be:
YACI_API_URL=http://localhost:8080/api/v1

# Not:
YACI_API_URL=http://localhost:8080  # Missing /api/v1
```

### 2. Port Already in Use

#### Symptoms
```
Error: Port 4001 is already in use
Error: bind: address already in use
```

#### Diagnosis
```bash
# Find what's using the port
lsof -i :4001
# or on Linux
netstat -tulpn | grep 4001
```

#### Solution

**Option 1: Kill the process**
```bash
# Find the PID
lsof -i :4001
# Kill it
kill -9 <PID>
```

**Option 2: Stop old Hydra containers**
```bash
npm run hydra:stop

# Or force remove
docker rm -f hydra-alice hydra-bob hydra-carol
```

**Option 3: Use different ports**

Edit `.env`:
```bash
HYDRA_API_PORT_ALICE=14001
HYDRA_API_PORT_BOB=14002
HYDRA_API_PORT_CAROL=14003
```

### 3. Docker Connection Issues

#### Symptoms
```
Error: Cannot connect to the Docker daemon
Error: docker: command not found
```

#### Diagnosis
```bash
# Check if Docker is running
docker ps

# Check Docker service status (Linux)
systemctl status docker
```

#### Solution

**macOS:**
```bash
# Start Docker Desktop
open /Applications/Docker.app

# Wait for it to start, then verify
docker ps
```

**Linux:**
```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

**Windows (WSL2):**
```bash
# Ensure Docker Desktop is running
# Check WSL integration in Docker Desktop settings
```

### 4. Keys Not Generated

#### Symptoms
```
Error: ENOENT: no such file or directory, open 'hydra-nodes/alice/keys/cardano.sk'
```

#### Diagnosis
```bash
# Check if keys directory exists
ls -la hydra-nodes/alice/keys/
```

#### Solution
```bash
# Generate keys
npm run keys:generate

# If that fails, check Docker
docker run --rm ghcr.io/cardano-scaling/hydra-node:1.2.0 --version

# Manual key generation
mkdir -p hydra-nodes/alice/keys
docker run --rm -v "$PWD:/work" \
  ghcr.io/cardano-scaling/hydra-node:1.2.0 \
  gen-hydra-key --output-file /work/hydra-nodes/alice/keys/hydra
```

### 5. Wallet Not Funded

#### Symptoms
```
Error: Insufficient funds
Error: UTxO not found
```

#### Diagnosis
```bash
# Check wallet balance
node -e "
import axios from 'axios';
const addr = 'YOUR_ADDRESS_HERE';
axios.get(\`http://localhost:8080/api/v1/addresses/\${addr}\`)
  .then(r => console.log('Balance:', r.data.balance))
  .catch(e => console.error('Error:', e.message));
"
```

#### Solution

**Option 1: Use automated funding**
```bash
npm run wallets:fund
```

**Option 2: Manual funding via Yaci CLI**
```bash
# Get address from keys
cat hydra-nodes/alice/keys/cardano.addr

# In Yaci CLI
topup addr_test1vq2kn... 1000
```

**Option 3: Check if node is created**
```bash
# In Yaci CLI
create-node -o --start
```

### 6. Hydra Scripts Not Published

#### Symptoms
```
Error: Missing HYDRA_SCRIPTS_TX_ID in .env
Error: Script not found on chain
```

#### Diagnosis
```bash
# Check .env file
grep HYDRA_SCRIPTS_TX_ID .env
```

#### Solution
```bash
# Publish scripts
./bin/hydra-node publish-scripts \
  --testnet-magic 42 \
  --node-socket /clusters/nodes/default/node/node.sock \
  --cardano-signing-key hydra-nodes/alice/keys/cardano.sk

# Copy the three transaction hashes from output
# Add to .env:
HYDRA_SCRIPTS_TX_ID="hash1,hash2,hash3"
```

### 7. Hydra Nodes Not Starting

#### Symptoms
```
Error: Container exits immediately
Error: Hydra node crashed
```

#### Diagnosis
```bash
# Check container logs
docker logs hydra-alice

# Check if containers exist
docker ps -a | grep hydra
```

#### Solution

**Check logs for specific error**
```bash
docker logs hydra-alice --tail 50
```

**Common fixes:**

1. **Missing scripts**: Publish Hydra scripts first
2. **Wrong network magic**: Check `.env` has `NETWORK_MAGIC=42`
3. **Port conflicts**: Use different ports
4. **Missing keys**: Run `npm run keys:generate`

**Restart containers:**
```bash
npm run hydra:stop
npm run hydra:start
```

### 8. Network Disconnected in TUI

#### Symptoms
```
Network: Disconnected
Peers: 0/2 connected
```

#### Diagnosis
```bash
# Check if all nodes are running
docker ps | grep hydra

# Check network connectivity
docker exec hydra-alice ping host.docker.internal
```

#### Solution

**Verify all nodes are running:**
```bash
docker ps
# Should show 3 hydra containers
```

**Check peer ports:**
```bash
# Alice should connect to Bob and Carol
lsof -i :5001
lsof -i :5002
lsof -i :5003
```

**Restart all nodes:**
```bash
npm run hydra:stop
sleep 5
npm run hydra:start
```

**Check Docker network:**
```bash
# Ensure host.docker.internal resolves
docker exec hydra-alice getent hosts host.docker.internal
```

### 9. WebSocket Connection Failed

#### Symptoms
```
Error: WebSocket connection failed
Error: ECONNREFUSED ws://localhost:4001
```

#### Diagnosis
```bash
# Check if Hydra node is running
docker ps | grep hydra-alice

# Test HTTP endpoint
curl http://localhost:4001

# Check logs
docker logs hydra-alice --tail 20
```

#### Solution

**Verify node is running:**
```bash
docker ps
```

**Test with wscat:**
```bash
npm install -g wscat
wscat -c ws://localhost:4001
```

**Check firewall:**
```bash
# Linux
sudo ufw allow 4001

# macOS
# No action needed

# Windows
# Check Windows Firewall settings
```

### 10. Transaction Not Confirmed

#### Symptoms
```
Transaction submitted but not confirmed
No TxValid message received
```

#### Diagnosis
```bash
# Check head status
# Connect to WebSocket and check messages

# Check Yaci blockchain
curl http://localhost:8080/api/v1/blocks/latest
```

#### Solution

**Ensure head is open:**
- Head must be in "Open" state
- All participants must have committed

**Check transaction format:**
```javascript
// Transaction must be valid CBOR
{
  "tag": "NewTx",
  "transaction": {
    "type": "Tx ConwayEra",
    "cborHex": "..."  // Valid CBOR hex
  }
}
```

**Wait for snapshot:**
- Transactions are confirmed in snapshots
- Wait a few seconds for snapshot confirmation

### 11. Binary Download Failed (macOS/Windows)

#### Symptoms
```
Warning: Binary download failed
Error downloading hydra-node binary
```

#### Diagnosis
```bash
# This is expected on ARM Macs and Windows
uname -m
# If output is arm64 or aarch64, this is normal
```

#### Solution

**No action needed** - The project automatically uses Docker images instead.

Verify Docker images are available:
```bash
docker images | grep hydra-node
```

### 12. Permission Denied Errors

#### Symptoms
```
Error: EACCES: permission denied
Permission denied: hydra-nodes/alice/keys/
```

#### Diagnosis
```bash
# Check file permissions
ls -la hydra-nodes/alice/keys/
```

#### Solution

**Fix directory permissions:**
```bash
chmod 755 hydra-nodes/
chmod 755 hydra-nodes/*/
chmod 755 hydra-nodes/*/keys/
```

**Fix key permissions:**
```bash
chmod 600 hydra-nodes/*/keys/*.sk
chmod 644 hydra-nodes/*/keys/*.vk
```

**Fix ownership:**
```bash
sudo chown -R $USER:$USER hydra-nodes/
```

## Platform-Specific Issues

### macOS

#### Issue: Docker Desktop Not Starting
```bash
# Kill Docker processes
pkill -9 Docker

# Restart Docker Desktop
open /Applications/Docker.app
```

#### Issue: Rosetta on Apple Silicon
```bash
# Install Rosetta if needed
softwareupdate --install-rosetta
```

### Linux

#### Issue: Docker Permission Denied
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply changes
newgrp docker

# Or logout and login again
```

#### Issue: Node Socket Not Found
```bash
# Check if Yaci created the socket
ls -la /tmp/yaci-devkit/

# Or /clusters/nodes/default/node/
ls -la /clusters/nodes/default/node/
```

### Windows (WSL2)

#### Issue: Cannot Connect to Docker
```bash
# In Docker Desktop, enable:
# Settings → Resources → WSL Integration → Enable for your distro
```

#### Issue: Path Issues
```bash
# Use WSL paths, not Windows paths
# Good: /home/user/hydra-yaci
# Bad: /mnt/c/Users/user/hydra-yaci
```

## Debugging Techniques

### Enable Debug Logging

Add to start script:

```bash
# Edit scripts/start-hydra.sh
# Add to docker run command:
--log-level debug
```

### Monitor All Logs

```bash
# Terminal 1: Alice
docker logs hydra-alice --follow

# Terminal 2: Bob
docker logs hydra-bob --follow

# Terminal 3: Carol
docker logs hydra-carol --follow
```

### Inspect WebSocket Messages

```bash
# Use wscat
wscat -c ws://localhost:4001

# Or use browser console
const ws = new WebSocket('ws://localhost:4001');
ws.onmessage = (e) => console.log('Received:', JSON.parse(e.data));
```

### Check Prometheus Metrics

```bash
# Alice metrics
curl http://localhost:6001/metrics

# Look for:
# - hydra_head_status
# - hydra_tx_confirmation_time
# - hydra_snapshot_number
```

## Reset and Clean Start

If all else fails, start fresh:

```bash
# 1. Stop everything
npm run hydra:stop
devkit stop

# 2. Clean Docker
docker rm -f $(docker ps -aq)
docker system prune -af

# 3. Reset project
npm run reset

# 4. Start fresh
devkit start
npm run setup
npm run keys:generate
npm run wallets:fund
npm run hydra:start
```

## Getting Help

### Collect Debug Information

```bash
# System info
uname -a
node --version
npm --version
docker --version

# Yaci status
curl http://localhost:8080/api/v1/epochs/latest

# Docker status
docker ps
docker images | grep hydra

# Logs
docker logs hydra-alice --tail 50 > alice.log
docker logs hydra-bob --tail 50 > bob.log
docker logs hydra-carol --tail 50 > carol.log
```

### Where to Get Help

1. **Check this guide** - Most issues are covered here
2. **Yaci DevKit Docs** - [https://devkit.yaci.xyz/](https://devkit.yaci.xyz/)
3. **Hydra Docs** - [https://hydra.family/](https://hydra.family/)
4. **GitHub Issues** - [https://github.com/kushal2060/hydra-yaci/issues](https://github.com/kushal2060/hydra-yaci/issues)

### Reporting Issues

When reporting an issue, include:

1. Operating system and version
2. Node.js version (`node --version`)
3. Docker version (`docker --version`)
4. Error message (full stack trace)
5. Relevant logs
6. Steps to reproduce

## FAQ

### Q: Can I run only one Hydra node?

**A:** No, Hydra requires at least 2 participants. The minimum is 2 nodes, this project uses 3.

### Q: Why does binary download fail on macOS?

**A:** ARM-based Macs need ARM64 binaries. The project uses Docker images instead, which works fine.

### Q: Can I use a different number of participants?

**A:** Yes, but you need to modify the scripts. The default is 3 (Alice, Bob, Carol).

### Q: Do I need to fund all three wallets?

**A:** Yes, all participants need funds to commit to the head.

### Q: Can I run this on mainnet?

**A:** This is for development only. Do not use on mainnet without proper security review.

### Q: How do I clear all state?

**A:** Run `npm run reset` to clear all generated keys and state.

## Next Steps

- [Usage Guide](usage.md) - Learn proper usage patterns
- [API Reference](api-reference.md) - API documentation
- [Configuration Guide](configuration.md) - Configuration options

---

Still having issues? Open an issue on [GitHub](https://github.com/kushal2060/hydra-yaci/issues) with debug information.
