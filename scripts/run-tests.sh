#!/usr/bin/env bash
set -e
npm run build
npm test
(cd chaincode && npm run build && npm test)
