#!/bin/bash

set -e
source .env

echo "--------------------------------------------"
echo "Funding Addresses Using Yaci CLI"
echo "--------------------------------------------"
echo ""

# Get addresses
ALICE_ADDR=$(cat hydra-nodes/alice/keys/cardano.addr)
BOB_ADDR=$(cat hydra-nodes/bob/keys/cardano.addr)
CAROL_ADDR=$(cat hydra-nodes/carol/keys/cardano.addr)

# Find Yaci CLI container
# Find Yaci CLI container (by name first, then fallback to grep)
CONTAINER=$(docker ps --filter "name=yaci-cli" --format "{{.Names}}" | head -1)

if [ -z "$CONTAINER" ]; then
  CONTAINER=$(docker ps --format '{{.Names}} {{.Image}}' | awk '/yaci-cli/ {print $1; exit}')
fi

if [ -z "$CONTAINER" ]; then
  echo "Error: Yaci DevKit not running. Start with: devkit start"
  exit 1
fi

echo "Container: $CONTAINER"
echo ""

# Function to fund an address
fund_address() {
    local NAME=$1
    local ADDR=$2
    local AMOUNT=$3
    
    echo "Funding $NAME ($ADDR)..."
    
    # Execute topup in the container
    docker exec "$CONTAINER" bash -c "
        yaci-cli <<HEREDOC
topup $ADDR $AMOUNT
exit
HEREDOC
    " 2>&1 | grep -i "success\|funded\|topup" || echo "Command sent"
    
    echo "  ✓ Topup request sent for $AMOUNT ADA"
    echo ""
}

# Fund all addresses
fund_address "Alice" "$ALICE_ADDR" 10000
sleep 3
fund_address "Bob" "$BOB_ADDR" 10000
sleep 3
fund_address "Carol" "$CAROL_ADDR" 10000

echo "Waiting for confirmations (30 seconds)..."
sleep 30

# Verify balances
echo ""
echo "Verifying balances..."
for name in alice bob carol; do
    ADDR=$(cat "hydra-nodes/$name/keys/cardano.addr")
    BALANCE=$(curl -s "$YACI_API_URL/addresses/$ADDR/balance" | jq -r '[.[].amounts[0].quantity // 0] | add')
    ADA=$(echo "scale=2; ${BALANCE:-0} / 1000000" | bc)
    echo "  $name: $ADA ADA"
done

echo ""
echo "✓ Done!"