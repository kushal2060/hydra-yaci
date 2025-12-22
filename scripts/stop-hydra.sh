#!/bin/bash

#hydar node stop garne script

set -e

echo "Stopping Hydra nodes...."

PARTICIPANTS=("alice" "bob" "carol")

for participant in "${PARTICIPANTS[@]}"; do
    PID_FILE="hydra-nodes/$participant/hydra-node.pid"

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        
        if ps -p $PID > /dev/null 2>&1; then
            echo "Stopping $participant (PID: $PID)..."
            kill $PID
            
            # Wait for graceful shutdown
            for i in {1..10}; do
                if ! ps -p $PID > /dev/null 2>&1; then
                    echo "  ✓ $participant stopped"
                    rm "$PID_FILE"
                    break
                fi
                sleep 1
            done

            # Force kill if still running
            if ps -p $PID > /dev/null 2>&1; then
                echo "  Force killing $participant..."
                kill -9 $PID
                rm "$PID_FILE"
            fi
        else
            echo "$participant is not running (stale PID file)"
            rm "$PID_FILE"
        fi
    else
        echo "$participant: No PID file found (not running)"
    fi
    echo ""
done

echo "All Hydra nodes stopped."