#!/bin/bash
# channel-ops.sh
# Channel creation and management operations

set -e

CHANNEL_NAME="voting-channel"
ORDERER_CA="/etc/hyperledger/fabric/crypto/orderer/tls/ca.crt"

echo "=========================================="
echo "  Channel Operations"
echo "=========================================="

# Create channel
create_channel() {
    echo "Creating channel: $CHANNEL_NAME"
    docker exec fabric-cli peer channel create \
        -o orderer1.example.com:7050 \
        --tls \
        --cafile "$ORDERER_CA" \
        -c "$CHANNEL_NAME" \
        -f /etc/hyperledger/config/channel-artifacts/${CHANNEL_NAME}.tx
}

# Join channel - Org1
join_org1() {
    echo "Joining Org1 peer to channel..."
    docker exec fabric-cli peer channel join \
        -o orderer1.example.com:7050 \
        --tls \
        --cafile "$ORDERER_CA" \
        -b "${CHANNEL_NAME}.block"
}

# Join channel - Org2
join_org2() {
    echo "Joining Org2 peer to channel..."
    docker exec -e CORE_PEER_LOCALMSPID=Org2MSP \
               -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto/peer/msp \
               -e CORE_PEER_ADDRESS=peer0.org2.example.com:7051 \
               fabric-cli peer channel join \
        -o orderer2.example.com:7050 \
        --tls \
        --cafile "$ORDERER_CA" \
        -b "${CHANNEL_NAME}.block"
}

# Update anchor peers
update_anchors() {
    echo "Updating anchor peers..."
    docker exec fabric-cli peer channel update \
        -o orderer1.example.com:7050 \
        --tls \
        --cafile "$ORDERER_CA" \
        -c "$CHANNEL_NAME" \
        -f /etc/hyperledger/config/channel-artifacts/Org1Anchor.tx

    docker exec -e CORE_PEER_LOCALMSPID=Org2MSP \
               -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto/peer/msp \
               fabric-cli peer channel update \
        -o orderer2.example.com:7050 \
        --tls \
        --cafile "$ORDERER_CA" \
        -c "$CHANNEL_NAME" \
        -f /etc/hyperledger/config/channel-artifacts/Org2Anchor.tx
}

case "${1:-help}" in
    create)
        create_channel
        ;;
    join-org1)
        join_org1
        ;;
    join-org2)
        join_org2
        ;;
    update-anchors)
        update_anchors
        ;;
    all)
        create_channel
        join_org1
        join_org2
        update_anchors
        ;;
    *)
        echo "Usage: $0 {create|join-org1|join-org2|update-anchors|all}"
        ;;
esac
