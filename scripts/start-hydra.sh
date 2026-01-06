#!/bin/bash

# yaci devkit bata sabbai participant lai hydra start garne

set -e

source .env

echo "Starting Hydra node...."

if ! curl -s http://localhost:8080/api/v1/epochs/latest > /dev/null 2>&1; then
    echo "Error: Yaci DevKit is not running!"
    echo "Please start it with: devkit start"
    exit 1
fi

#start hydra
start_hydra_node() {
    local NAME=$1
    local API_PORT=$2
    local PEER_PORT=$3
    local MONITORING_PORT=$4
    local ADVERTISED_HOST=$5  # NEW: Pass the host for this node

    echo "Starting Hydra node for participant: $NAME"

    local NODE_DIR="hydra-nodes/$NAME"
    local LOG_FILE="$NODE_DIR/logs/hydra-node.log"
    local PID_FILE="$NODE_DIR/hydra-node.pid"

    #IF RUNNING
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            echo " $NAME is already running with PID $PID"
            return
        fi
    fi

    PEERS=""
    if [ "$NAME" != "alice" ]; then
        PEERS="$PEERS --peer ${HYDRA_HOST_ALICE}:${HYDRA_PEER_PORT_ALICE}"
    fi
    if [ "$NAME" != "bob" ]; then
        PEERS="$PEERS --peer ${HYDRA_HOST_BOB}:${HYDRA_PEER_PORT_BOB}"
    fi
    if [ "$NAME" != "carol" ]; then
        PEERS="$PEERS --peer ${HYDRA_HOST_CAROL}:${HYDRA_PEER_PORT_CAROL}"
    fi

   # Only include OTHER participants' keys (not our own)
    ALL_KEYS=""
    for other_participant in alice bob carol; do
        if [ "$other_participant" != "$NAME" ]; then
            ALL_KEYS="$ALL_KEYS --hydra-verification-key hydra-nodes/$other_participant/keys/hydra.vk"
            ALL_KEYS="$ALL_KEYS --cardano-verification-key hydra-nodes/$other_participant/keys/cardano.vk"
        fi
    done

    #start node with Ogmios
    nohup ./bin/hydra-node \
        --node-id "$NAME" \
        --api-host 0.0.0.0 \
        --api-port $API_PORT \
        --listen 0.0.0.0:$PEER_PORT \
        --advertise "${ADVERTISED_HOST}:${PEER_PORT}" \
        --monitoring-port $MONITORING_PORT \
        --hydra-signing-key "$NODE_DIR/keys/hydra.sk" \
        --cardano-signing-key "$NODE_DIR/keys/cardano.sk" \
        $ALL_KEYS \
        --ledger-protocol-parameters config/hydra/protocol-parameters.json \
        --testnet-magic $NETWORK_MAGIC \
        --node-socket "$SOCKET_PATH" \
        --hydra-scripts-tx-id "$HYDRA_SCRIPTS_TX_ID" \
        --persistence-dir "$NODE_DIR/persistence" \
        $PEERS \
        > "$LOG_FILE" 2>&1 &

    local NODE_PID=$!
    echo $NODE_PID > "$PID_FILE"
    echo " Started (PID: $NODE_PID)"
    echo " API: http://localhost:$API_PORT"
    echo " Peer: $ADVERTISED_HOST:$PEER_PORT"
    echo " Logs: $LOG_FILE"
    echo ""
}

#protocol parameters file
mkdir -p config/hydra
if [ ! -f config/hydra/protocol-parameters.json ]; then
    echo "Creating protocol parameters file..."
    cat > config/hydra/protocol-parameters.json <<'EOFPARAM'
{
  "txFeePerByte": 44,
  "txFeeFixed": 155381,
  "maxBlockBodySize": 90112,
  "maxBlockHeaderSize": 1100,
  "maxTxSize": 16384,
  "minFeeRefScriptCostPerByte": 15,
  "stakeAddressDeposit": 2000000,
  "stakePoolDeposit": 500000000,
  "minPoolCost": 340000000,
  "poolRetireMaxEpoch": 18,
  "stakePoolTargetNum": 500,
  "poolPledgeInfluence": 0.3,
  "monetaryExpansion": 0.003,
  "treasuryCut": 0.2,
  "minUTxOValue": null,
  "utxoCostPerByte": 4310,
  "executionUnitPrices": {
    "priceMemory": 0.0577,
    "priceSteps": 0.0000721
  },
  "protocolVersion": {
    "major": 10,
    "minor": 0
  },
  "maxTxExecutionUnits": {
    "memory": 14000000,
    "steps": 10000000000
  },
  "maxBlockExecutionUnits": {
    "memory": 62000000,
    "steps": 40000000000
  },
  "maxValueSize": 5000,
  "collateralPercentage": 150,
  "maxCollateralInputs": 3,
  "coinsPerUTxOByte": 4310
}
EOFPARAM
    echo "  Created protocol parameters"
    echo ""
fi

#start nodes - NOW PASSING THE 5TH PARAMETER (ADVERTISED_HOST)
start_hydra_node "alice" $HYDRA_API_PORT_ALICE $HYDRA_PEER_PORT_ALICE $HYDRA_MONITORING_PORT_ALICE $HYDRA_HOST_ALICE
echo "Waiting for Alice to initialize cluster..."
sleep 5

start_hydra_node "bob" $HYDRA_API_PORT_BOB $HYDRA_PEER_PORT_BOB $HYDRA_MONITORING_PORT_BOB $HYDRA_HOST_BOB
sleep 5

start_hydra_node "carol" $HYDRA_API_PORT_CAROL $HYDRA_PEER_PORT_CAROL $HYDRA_MONITORING_PORT_CAROL $HYDRA_HOST_CAROL
echo "waiting for Hydra nodes to start..."
sleep 5

echo "Hydra nodes started successfully!"
echo "Verifying node status..."
echo ""

ALL_RUNNING=true

for node in "alice:$HYDRA_API_PORT_ALICE" "bob:$HYDRA_API_PORT_BOB" "carol:$HYDRA_API_PORT_CAROL"; do
    NAME=$(echo $node | cut -d: -f1)
    PORT=$(echo $node | cut -d: -f2)
    
    if curl -s http://localhost:$PORT > /dev/null 2>&1; then
        echo "   $NAME is responding on port $PORT"
    else
        echo "   $NAME is NOT responding on port $PORT"
        echo "   Check logs: hydra-nodes/$NAME/logs/hydra-node.log"
        cat hydra-nodes/$NAME/logs/hydra-node.log 
        ALL_RUNNING=false
    fi
done

echo ""
echo "--------------------------------------------"

if [ "$ALL_RUNNING" = true ]; then
    echo "✓ All Hydra nodes are running!"
    echo "--------------------------------------------"
    echo ""
    echo "API Endpoints:"
    echo "  Alice:  http://localhost:$HYDRA_API_PORT_ALICE"
    echo "  Bob:    http://localhost:$HYDRA_API_PORT_BOB"
    echo "  Carol:  http://localhost:$HYDRA_API_PORT_CAROL"
    echo ""
    echo "To stop nodes: npm run hydra:stop"
else
    echo " Some nodes failed to start"
    echo "--------------------------------------------"
    echo ""
    echo "Check logs in hydra-nodes/*/logs/ for details"
    exit 1
fi