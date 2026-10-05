#!/usr/bin/env bash
docker compose down
if [ -x fabric/vendor/fabric-samples/test-network/network.sh ];then (cd fabric/vendor/fabric-samples/test-network && MSYS_NO_PATHCONV=1 COMPOSE_CONVERT_WINDOWS_PATHS=1 ./network.sh down) || true;fi
