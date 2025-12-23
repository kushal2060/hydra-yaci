#!/bin/bash
#hydra ko keys generate garne script
#each particpiant ko hydra head protocol keys generate garne and 
#cardano payments keys for layer 1
set -e

source .env

echo  "Generating keys for hydra participants"

PARTICIPANTS=("alice" "bob" "carol")

for participant in "${PARTICIPANTS[@]}"; do
    echo "Generating keys for $participant"

    KEY_DIR="hydra-nodes/$participant/keys"

    #hydra keys for head protocol
    echo "Generating Hydra head protocol keys"
    ./bin/hydra-node gen-hydra-key \
        --output-file "$KEY_DIR/hydra"

    #cardano keys
    echo "Generating Cardano payment keys"
    cardano-cli address key-gen \
        --verification-key-file "$KEY_DIR/cardano.vk" \
        --signing-key-file "$KEY_DIR/cardano.sk" 2>/dev/null || {

            #if no cardano-cli found
            echo " (using hydra-nodes cardano cli) "
            ./bin/cardano-cli address key-gen \
                --verification-key-file "$KEY_DIR/cardano.vk" \
                --signing-key-file "$KEY_DIR/cardano.sk"
    }

    #cardano address
    echo "Generating Cardano address"
    cardano-cli address build \
        --payment-verification-key-file "$KEY_DIR/cardano.vk" \
        --testnet-magic $NETWORK_MAGIC \
        --out-file "$KEY_DIR/cardano.addr" 2>/dev/null || {
        
        ./bin/cardano-cli address build \
            --payment-verification-key-file "$KEY_DIR/cardano.vk" \
            --testnet-magic $NETWORK_MAGIC \
            --out-file "$KEY_DIR/cardano.addr"
    }

    #display
    ADDRESS=$(cat "$KEY_DIR/cardano.addr")
    echo "Address: $ADDRESS"

    cat > "data/wallets/{$participant}-wallet.json" << EOF #node js le consume garna milne format ma

{
  "name": "$participant",
  "address": "$ADDRESS",
  "hydraKey": "$KEY_DIR/hydra.vk",
  "cardanoKey": "$KEY_DIR/cardano.vk",
  "createdAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

    echo "Keys generated for $participant"
    echo "-----------------------------------"
done

echo "All keys generated successfully"
echo "Generated keys fro: "
for participant in "${PARTICIPANTS[@]}"; do
    ADDR=$(cat "hydra-nodes/$participant/keys/cardano.addr")
    echo "  $participant: $ADDR"
done
echo ""
echo "Next step: Fund these addresses"
echo "  npm run wallets:fund"

