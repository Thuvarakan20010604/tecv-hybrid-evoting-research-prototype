#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"; VENDOR="$ROOT/fabric/vendor"; mkdir -p "$VENDOR"; cd "$VENDOR"
if [ ! -f install-fabric.sh ];then curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh;chmod +x install-fabric.sh;fi
./install-fabric.sh --fabric-version 3.1.5 --ca-version 1.5.17 docker binary samples
curl -sSL -o fabric-samples/bin/jq.exe https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-windows-amd64.exe
NET="$VENDOR/fabric-samples/test-network"; sed -i 's|SOCK="${DOCKER_HOST:-/var/run/docker.sock}"|SOCK="${DOCKER_HOST:-//var/run/docker.sock}"|' "$NET/network.sh"
cd "$NET"; COMPOSE_CONVERT_WINDOWS_PATHS=1 ./network.sh up createChannel -bft -c voting-channel
COMPOSE_CONVERT_WINDOWS_PATHS=1 ./network.sh deployCC -c voting-channel -ccn tecv -ccp ../../../../chaincode -ccl javascript
