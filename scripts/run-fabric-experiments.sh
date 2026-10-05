#!/usr/bin/env bash
# Official Fabric helper scripts reference optional unset variables, so nounset is intentionally disabled.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; NET="$ROOT/fabric/vendor/fabric-samples/test-network"; RUN_ID="fabric-$(date -u +%Y%m%dT%H%M%SZ)"; OUT="$ROOT/results/fabric/$RUN_ID"; mkdir -p "$OUT/logs"
cd "$NET"; export PATH="$PWD/../bin:$PATH" FABRIC_CFG_PATH="$PWD/../config"; . scripts/envVar.sh
results="$OUT/fabric-results.csv"; echo 'scenario,active_orderers,attempts,committed,failed,duration_ms,outcome' > "$results"
now(){ date +%s%3N; }
invoke_vote(){ local id="$1"; peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" -C voting-channel -n tecv --peerAddresses localhost:7051 --tlsRootCertFiles "$PEER0_ORG1_CA" --peerAddresses localhost:9051 --tlsRootCertFiles "$PEER0_ORG2_CA" -c "{\"function\":\"VoteProofContract:SubmitVoteProof\",\"Args\":[\"$id\",\"1-research\",\"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\",\"Jaffna\",\"ELECTION-2026-001\",\"2026-10-05T10:00:00.000Z\"]}" --waitForEvent --waitForEventTimeout 10s; }
measure(){ local name="$1" active="$2" log="$3"; shift 3; local s e rc; s=$(now); "$@" >"$OUT/logs/$log" 2>&1; rc=$?; e=$(now); if [ $rc -eq 0 ];then echo "$name,$active,1,1,0,$((e-s)),PASS" >> "$results";else echo "$name,$active,1,0,1,$((e-s)),EXPECTED_REJECTION_OR_FAILURE" >> "$results";fi; return $rc; }
setGlobals 1
measure normal_4_orderers 4 normal.log invoke_vote "fabric-normal-$RUN_ID" || true
# Duplicate rejection uses the already committed same ID.
measure duplicate_proof_rejection 4 duplicate.log invoke_vote "fabric-normal-$RUN_ID" && true
# Unauthorized Org2 vote submission.
setGlobals 2
measure unauthorized_vote_rejection 4 unauthorized.log invoke_vote "fabric-unauth-$RUN_ID" && true
# Authorized result publication from Org2.
measure result_proof 4 result.log peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" -C voting-channel -n tecv --peerAddresses localhost:7051 --tlsRootCertFiles "$PEER0_ORG1_CA" --peerAddresses localhost:9051 --tlsRootCertFiles "$PEER0_ORG2_CA" -c "{\"function\":\"ResultContract:SubmitResultProof\",\"Args\":[\"result-$RUN_ID\",\"ELECTION-2026-001\",\"Jaffna\",\"{\\\"Candidate A\\\":1}\",\"1\",\"0\",\"cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc\",\"2026-10-05T10:00:00.000Z\"]}" --waitForEvent --waitForEventTimeout 10s || true
# One-orderer crash/availability experiment. This is not malicious Byzantine behavior.
docker stop orderer4.example.com >"$OUT/logs/stop-one.log" 2>&1; sleep 3; setGlobals 1
measure one_orderer_unavailable 3 one-down.log invoke_vote "fabric-one-down-$RUN_ID" || true
# Beyond threshold: leave only orderer1 running. Bound client with host timeout.
docker stop orderer2.example.com orderer3.example.com >"$OUT/logs/stop-three.log" 2>&1; sleep 3
s=$(now); timeout 20s bash -c "$(declare -f invoke_vote); invoke_vote 'fabric-threshold-$RUN_ID'" >"$OUT/logs/beyond-threshold.log" 2>&1; rc=$?; e=$(now); if [ $rc -eq 0 ];then echo "beyond_threshold,1,1,1,0,$((e-s)),UNEXPECTED_COMMIT" >> "$results";else echo "beyond_threshold,1,1,0,1,$((e-s)),LIVENESS_LOSS_OBSERVED" >> "$results";fi
docker start orderer2.example.com orderer3.example.com orderer4.example.com >"$OUT/logs/restore.log" 2>&1; sleep 5
docker stats --no-stream --format '{{json .}}' orderer.example.com orderer2.example.com orderer3.example.com orderer4.example.com peer0.org1.example.com peer0.org2.example.com > "$OUT/resource-snapshot.jsonl"
docker ps --filter name=orderer --filter name=peer0 --format '{{json .}}' > "$OUT/container-state.jsonl"
{
 echo '{'; echo "  \"runId\": \"$RUN_ID\","; echo '  "classification": "MEASURED local Docker crash/availability experiment",'; echo '  "fabricVersion": "3.1.5",'; echo '  "consensus": "BFT/SmartBFT",'; echo '  "orderers": 4,'; echo '  "peers": 2,'; echo '  "warning": "Stopped orderers model crash/availability faults, not Byzantine-malicious behavior."'; echo '}';
} > "$OUT/manifest.json"
(cd "$OUT" && find . -type f ! -name checksums.sha256 -print0 | sort -z | xargs -0 sha256sum > checksums.sha256)
echo "$OUT"
