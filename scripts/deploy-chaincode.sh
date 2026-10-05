#!/bin/bash
# deploy-chaincode.sh
# Chaincode package, install, and approve/commit operations

set -e

CHANNEL_NAME="voting-channel"
CHAINCODE_NAME="voting"
CHAINCODE_VERSION="1.0"
CHAINCODE_LANG="node"
ORDERER_CA="/etc/hyperledger/fabric/crypto/orderer/tls/ca.crt"

echo "=========================================="
echo "  Chaincode Deployment"
echo "=========================================="

# Package chaincode
package_cc() {
    echo "Packaging chaincode..."
    docker exec fabric-cli peer lifecycle chaincode package \
        "${CHAINCODE_NAME}.tar.gz" \
        --path /root/chaincode \
        --lang "$CHAINCODE_LANG" \
        --label "${CHAINCODE_NAME}_${CHAINCODE_VERSION}"
}

# Install on Org1
install_org1() {
    echo "Installing chaincode on Org1..."
    docker exec fabric-cli peer lifecycle chaincode install \
        "${CHAINCODE_NAME}.tar.gz"
}

# Install on Org2
install_org2() {
    echo "Installing chaincode on Org2..."
    docker exec -e CORE_PEER_LOCALMSPID=Org2MSP \
               -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto/peer/msp \
               -e CORE_PEER_ADDRESS=peer0.org2.example.com:7051 \
               fabric-cli peer lifecycle chaincode install \
        "${CHAINCODE_NAME}.tar.gz"
}

# Get package ID
get_package_id() {
    echo "Getting package ID..."
    docker exec fabric-cli peer lifecycle chaincode queryinstalled
}

# Approve for Org1
approve_org1() {
    local PACKAGE_ID="${1:-}"
    [ -z "$PACKAGE_ID" ] && echo "Package ID required" && exit 1

    echo "Approving chaincode for Org1..."
    docker exec fabric-cli peer lifecycle chaincode approveformyorg \
        --channelID "$CHANNEL_NAME" \
        --name "$CHAINCODE_NAME" \
        --version "$CHAINCODE_VERSION" \
        --package-id "$PACKAGE_ID" \
        --sequence 1 \
        --tls \
        --cafile "$ORDERER_CA" \
        -o orderer1.example.com:7050
}

# Approve for Org2
approve_org2() {
    local PACKAGE_ID="${1:-}"
    [ -z "$PACKAGE_ID" ] && echo "Package ID required" && exit 1

    echo "Approving chaincode for Org2..."
    docker exec -e CORE_PEER_LOCALMSPID=Org2MSP \
               -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/crypto/peer/msp \
               -e CORE_PEER_ADDRESS=peer0.org2.example.com:7051 \
               fabric-cli peer lifecycle chaincode approveformyorg \
        --channelID "$CHANNEL_NAME" \
        --name "$CHAINCODE_NAME" \
        --version "$CHAINCODE_VERSION" \
        --package-id "$PACKAGE_ID" \
        --sequence 1 \
        --tls \
        --cafile "$ORDERER_CA" \
        -o orderer2.example.com:7050
}

# Commit chaincode
commit_cc() {
    echo "Committing chaincode..."
    docker exec fabric-cli peer lifecycle chaincode commit \
        --channelID "$CHANNEL_NAME" \
        --name "$CHAINCODE_NAME" \
        --version "$CHAINCODE_VERSION" \
        --sequence 1 \
        --tls \
        --cafile "$ORDERER_CA" \
        -o orderer1.example.com:7050 \
        --policy "OR('Org1MSP.member','Org2MSP.member')"
}

# Verify commit
verify_commit() {
    echo "Verifying commit..."
    docker exec fabric-cli peer lifecycle chaincode querycommitted \
        --channelID "$CHANNEL_NAME"
}

# Initialize chaincode
init_cc() {
    echo "Initializing chaincode..."
    docker exec fabric-cli peer chaincode invoke \
        --channelID "$CHANNEL_NAME" \
        --name "$CHAINCODE_NAME" \
        --tls \
        --cafile "$ORDERER_CA" \
        -o orderer1.example.com:7050 \
        -c '{"Args":["org.voting.voteproof:registerVoter", "voter-001", "US-East", "admin"]}' \
        --waitForEvent \
        --timeout 30s
}

case "${1:-help}" in
    package)
        package_cc
        ;;
    install)
        install_org1
        install_org2
        ;;
    install-org1)
        install_org1
        ;;
    install-org2)
        install_org2
        ;;
    approve)
        approve_org1 "$2"
        approve_org2 "$2"
        ;;
    commit)
        commit_cc
        ;;
    verify)
        verify_commit
        ;;
    init)
        init_cc
        ;;
    all)
        package_cc
        install_org1
        install_org2
        echo "Run 'deploy-chaincode.sh approve <PACKAGE_ID>' after getting package ID"
        ;;
    *)
        echo "Usage: $0 {package|install|approve|commit|verify|init|all}"
        ;;
esac
