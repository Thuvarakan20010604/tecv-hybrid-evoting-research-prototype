#!/usr/bin/env bash
set -e
docker compose up -d couchdb
if [ "${START_FABRIC:-0}" = "1" ];then ./fabric/scripts/bootstrap.sh;fi
