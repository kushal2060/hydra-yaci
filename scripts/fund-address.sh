#!/bin/bash

# yaci devkit bata sabbai participant lai fun garne

set -e 

source .env

echo "Funding participant addresses from yaci devkit..."

PARTICIPANTS=("alice" "bob" "carol")
FUNDING_AMOUNT=${INITIAL_FUNDS:-1000000} 

echo "funding amount per address: ${FUNDING_AMOUNT} ADA"
echo ""

for participant in "${PARTICIPANTS[@]}"; do
    echo "Fundding $participant..."

    ADDRESS=$(cat "hydra-nodes/$participant/keys/cardano.addr")
    echo "Address: $ADDRESS"

    LOVELACE=$((FUNDING_AMOUNT * 1000000))
    #yaci devkit topup api
    echo "  Requesting $LOVELACE lovelace..."

    RESPONSE=$(curl -s -X POST "$YACI_API_URL/local-cluster/api/topup" \
        -H "Content-Type: application/json" \
        -d "{\"address\": \"$ADDRESS\", \"amount\": $LOVELACE}") 

    if echo "$RESPONSE" | jq -e '.txHash' > /dev/null 2>$1; then
        TX_HASH=$(echo "$RESPONSE" | jq -r '.txHash')
        echo "  ✓ Funded! Transaction: $TX_HASH"

        #update wallet JSOn
        WALLET_FILE="data/wallets/${participant}-wallet.json"   
        jq ". + {\"fundedAt\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\", \"fundingTx\": \"$TX_HASH\", \"initialBalance\": $LOVELACE}" \
            "$WALLET_FILE" > "${WALLET_FILE}.tmp" && mv "${WALLET_FILE}.tmp" "$WALLET_FILE"

    else 
        echo "  ✗ Funding failed! Response: $RESPONSE"
        exit 1
    fi
    echo ""
    sleep 2
done

echo "waiting for transactions to be confirmed..."
sleep 30

echo ""
echo "Verifying balnces..."
echo ""

for participant in "${PARTICIPANTS[@]}"; do
    ADDRESS=$(cat "hydra-nodes/$participant/keys/cardano.addr")

    #using yaci
    BALANCE_RESPONSE=$(curl -s "$YACI_API_URL/addresses/$ADDRESS/utxos")
    if [ ! -z "$BALANCE_RESPONSE" ] && [ "$BALANCE_RESPONSE" != "[]" ]; then
        # Calculate total balance
        TOTAL_LOVELACE=$(echo "$BALANCE_RESPONSE" | jq '[.[].amounts[0].quantity] | add')
        TOTAL_ADA=$(echo "scale=6; $TOTAL_LOVELACE / 1000000" | bc)
        
        echo "  $participant: $TOTAL_ADA ADA"
        echo "    Address: $ADDRESS"
        echo "    UTXOs: $(echo "$BALANCE_RESPONSE" | jq 'length')"
    else
        echo "  $participant: 0 ADA (No UTXOs found)"
        echo "   Funding may not have completed yet"
    fi
    echo ""
done

echo "Funding process completed."