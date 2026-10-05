#!/usr/bin/env bash
set -e
npm run research-run
if docker ps --format '{{.Names}}' | grep -q '^orderer.example.com$';then ./scripts/run-fabric-experiments.sh;else echo 'Fabric experiments NOT EXECUTED: BFT network is not running.';fi
npx tsx experiments/consolidate.ts
