#!/usr/bin/env bash
set -e
npm install
(cd chaincode && npm install && npm run build && npm test)
docker compose up -d couchdb
