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

SOCKET_PATH="${CARDANO_NODE_SOCKET_PATH}"

if [ ! -S "$SOCKET_PATH" ]; then
    echo "Error: Cardano node socket not found at $SOCKET_PATH"
   # Try to find socket
    POSSIBLE_SOCKETS=(
        "/tmp/yaci-devkit/node.socket"
        "/tmp/node.socket"
        "$HOME/.yaci-devkit/node.socket"
    )
    for sock in "${POSSIBLE_SOCKETS[@]}"; do
        if [ -S "$sock" ]; then
            SOCKET_PATH="$sock"
            echo "Found socket at: $SOCKET_PATH"
            break
        fi
    done
    
    if [ ! -S "$SOCKET_PATH" ]; then
        echo "Error: Could not find Cardano node socket"
        echo "Please check your Yaci DevKit installation"
        exit 1
    fi
fi

echo "Using node socket: $SOCKET_PATH"
echo "Network magic: $NETWORK_MAGIC"
echo ""

#start hydra

start_hydra_node() {
    local NMAE=$1
    local API_ROUT=$2
    local PEER_PORT=$3
    local MONITORING_PORT=$4

    echo "Starting Hydra node for participant: $NMAE"

    local NODE_DIR="hydra-nodes/$NMAE"
    local LOG_FILE="$NODE_DIR/logs/hydra-node.log"
    local PID_FILE="$NODE_DIR/hydra-node.pid"

    #IF RUNNIG
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            echo " $NAME is already running with PID $PID"
            return
        fi
    fi

    PEERS=""
    if [ "$NAME" != "alice" ]; then
        PEERS="$PEERS --peer ${HYDRA_HOST_ALICE}:${HYDRA_PEER_PORT_ALICE}". #connectin to each other
    fi
    if [ "$NAME" != "bob" ]; then
        PEERS="$PEERS --peer ${HYDRA_HOST_BOB}:${HYDRA_PEER_PORT_BOB}"
    fi
    if [ "$NAME" != "carol" ]; then
        PEERS="$PEERS --peer ${HYDRA_HOST_CAROL}:${HYDRA_PEER_PORT_CAROL}"
    fi

    #start node
    nohup ./bin/hydra-node \
        --node-id "$NAME" \
        --api-host 0.0.0.0 \
        --api-port $API_PORT \
        --host 0.0.0.0 \
        --port $PEER_PORT \
        --monitoring-port $MONITORING_PORT \
        --hydra-signing-key "$NODE_DIR/keys/hydra.sk" \
        --hydra-verification-key "$NODE_DIR/keys/hydra.vk" \
        --cardano-signing-key "$NODE_DIR/keys/cardano.sk" \
        --cardano-verification-key "$NODE_DIR/keys/cardano.vk" \
        --ledger-protocol-parameters config/hydra/protocol-parameters.json \
        --testnet-magic $NETWORK_MAGIC \
        --node-socket "$SOCKET_PATH" \
        --persistence-dir "$NODE_DIR/persistence" \
        $PEERS \
        > "$LOG_FILE" 2>&1 &

    local NODE_PID=$!
    echo $NODE_PID > "$PID_FILE"
    echo " Started (PID: $NODE_PID)"
    echo " API: http://localhost:$API_PORT"
    echo " Peer: localhost:$PEER_PORT"
    echo " Logs: $LOG_FILE"
    echo ""

}

#protocol parameters file
mkdir -p config/hydra
if [ ! -f config/hydra/protocol-parameters.json ]; then
    echo "Creating protocol parameters file..."
    cat > config/hydra/protocol-parameters.json <<'EOF'
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
EOF
    echo "  Created protocol parameters"
    echo ""
fi

#start nodes
start_hydra_node "alice" $HYDRA_API_PORT_ALICE $HYDRA_PEER_PORT_ALICE $HYDRA_MONITORING_PORT_ALICE
sleep 2
start_hydra_node "bob" $HYDRA_API_PORT_BOB $HYDRA_PEER_PORT_BOB $HYDRA_MONITORING_PORT_BOB
sleep 2
start_hydra_node "carol" $HYDRA_API_PORT_CAROL $HYDRA_PEER_PORT_CAROL $HYDRA_MONITORING_PORT_CAROL

echo "waiting for Hydra nodes to start..."
sleep 10

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