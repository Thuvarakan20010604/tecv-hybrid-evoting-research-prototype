# Manual Test, Evidence Recording, and Paper Inclusion Guide

**Project:** TECV Hybrid Blockchain-Based Electronic Voting Prototype
**Setting:** Supervised polling station, Jaffna district
**Data policy:** Synthetic voters and mock biometrics only

> **Research-integrity rule:** Examples under **Expected response pattern** are not experimental results. Save the actual response produced by your run. Only actual saved responses may be quoted as measured or observed evidence in the paper.

## 1. Start from a clean component-test state

Use **Git Bash** from the project folder. Stop a currently running API with `Ctrl+C` before reseeding.

```bash
cd /c/Users/thuva/Desktop/Research

docker compose up -d couchdb

export BALLOT_KEY_HEX=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
export SEED_COUNT=100
export RANDOM_SEED=20260047

npm run seed
mkdir -p results/manual
npm start
```

Keep this terminal open. In a **second Git Bash terminal**, run the tests below:

```bash
cd /c/Users/thuva/Desktop/Research
mkdir -p results/manual
```

The seed command creates voter document IDs `voter-000001` through `voter-000100`. It resets `voters_db` and `votes_db`; do not reseed in the middle of a test sequence.

## 2. Sample synthetic test data

| Test voter document ID | Synthetic voter ID | Candidate input | Intended use |
|---|---|---|---|
| `voter-000001` | `VOTER-000001` | Candidate A | Normal flow and sequential second-vote rejection |
| `voter-000002` | `VOTER-000002` | Candidate B / Candidate C | Concurrent double-vote test |
| `voter-000003` | `VOTER-000003` | Candidate C | Second honest ballot |
| `voter-000004` | `VOTER-000004` | Candidate D | Third honest ballot |
| `voter-000005` | `VOTER-000005` | Candidate A | Additional honest ballot |

All records contain district `Jaffna`, election `ELECTION-2026-001`, synthetic NIC values, and `MOCK-BIOMETRIC-HASH`. No real personal or biometric data is used.

---

## TEST M1 — Health check

```bash
curl -s http://localhost:3000/health | tee results/manual/M1-health.json
```

**Expected response pattern — CONFIGURATION / FACT:**

```json
{
  "status": "ok",
  "ledgerAdapter": "memory",
  "warning": "Memory adapter is component-test mode, not Hyperledger Fabric"
}
```

**Record:** HTTP status, execution timestamp, adapter, and raw response path.

---

## TEST M2 — Normal encrypted vote

```bash
curl -s -X POST http://localhost:3000/votes \
  -H "Content-Type: application/json" \
  -d '{"voterId":"voter-000001","candidate":"Candidate A"}' \
  | tee results/manual/M2-normal-vote.json
```

**Expected response pattern — do not copy random values as observed data:**

```json
{
  "voteDocId": "<random UUID>",
  "revision": "1-<CouchDB revision digest>",
  "transactionId": "<component-ledger transaction UUID>",
  "timings": {
    "authenticationMs": "<measured number>",
    "encryptionMs": "<measured number>",
    "couchInsertMs": "<measured number>",
    "hashMs": "<measured number>",
    "proofCommitMs": "<measured number>",
    "endToEndMs": "<measured number>"
  }
}
```

**Pass condition:** response contains `voteDocId`, CouchDB revision, transaction ID, and numeric timings.

> These timings are MemoryLedger component-mode measurements, not Fabric commit latency.

---

## TEST M3 — TECV audit

```bash
curl -s -X POST http://localhost:3000/audits \
  | tee results/manual/M3-audit.json
```

**Expected response conditions:**

- `totalLedgerProofs` = 1
- `totalDatabaseVotes` = 1
- `validVotes` = 1
- `invalidVotes` = 0
- `missingVotes` = 0
- `revisionMismatches` = 0
- `hashMismatches` = 0
- `unprovenDatabaseRecords` = 0
- `auditResultHash` is a 64-character SHA-256 hexadecimal value

**Pass condition:** the `voteDocId` returned by M2 appears in `validVoteDocIds`.

---

## TEST M4 — Verified decryption and tally

Run only after M3:

```bash
curl -s -X POST http://localhost:3000/tallies \
  | tee results/manual/M4-tally.json
```

**Expected totals for this test state:**

```json
{
  "Candidate A": 1,
  "Candidate B": 0,
  "Candidate C": 0,
  "Candidate D": 0
}
```

**Pass condition:** Candidate A equals 1, all other candidates equal 0, `validVoteCount` equals 1, and a ResultProof is returned.

---

## TEST M5 — Sequential second-vote rejection

```bash
curl -s -X POST http://localhost:3000/votes \
  -H "Content-Type: application/json" \
  -d '{"voterId":"voter-000001","candidate":"Candidate B"}' \
  | tee results/manual/M5-second-vote.json
```

**Expected response:**

```json
{
  "error": "ERR_ALREADY_VOTED"
}
```

**Pass condition:** no second vote is accepted for `voter-000001`.

---

## TEST M6 — Concurrent double-vote protection

Run both requests from the second terminal:

```bash
curl -s -X POST http://localhost:3000/votes \
  -H "Content-Type: application/json" \
  -d '{"voterId":"voter-000002","candidate":"Candidate B"}' \
  > results/manual/M6-concurrent-A.json &
pid_a=$!

curl -s -X POST http://localhost:3000/votes \
  -H "Content-Type: application/json" \
  -d '{"voterId":"voter-000002","candidate":"Candidate C"}' \
  > results/manual/M6-concurrent-B.json &
pid_b=$!

wait $pid_a
wait $pid_b

cat results/manual/M6-concurrent-A.json
echo
cat results/manual/M6-concurrent-B.json
```

**Expected:** exactly one response contains an accepted `voteDocId`; the other contains `ERR_CONCURRENT_VOTE_CONFLICT` or `ERR_ALREADY_VOTED`.

**Pass condition:** accepted votes = 1; rejected votes = 1.

---

## TEST M7 — Observer determinism

Freeze the state by not casting more votes, then run two audits:

```bash
curl -s -X POST http://localhost:3000/audits > results/manual/M7-auditor-A.json
curl -s -X POST http://localhost:3000/audits > results/manual/M7-auditor-B.json

node -e "const fs=require('fs'); const a=JSON.parse(fs.readFileSync('results/manual/M7-auditor-A.json')); const b=JSON.parse(fs.readFileSync('results/manual/M7-auditor-B.json')); console.log(JSON.stringify({auditHashA:a.auditResultHash,auditHashB:b.auditResultHash,hashesMatch:a.auditResultHash===b.auditResultHash,validSetsMatch:JSON.stringify(a.validVoteDocIds)===JSON.stringify(b.validVoteDocIds)},null,2))" \
  | tee results/manual/M7-determinism-comparison.json
```

**Pass condition:** `hashesMatch` and `validSetsMatch` are both `true`. `auditRunId` and timing fields may differ and are intentionally excluded from the stable audit hash.

---

## TEST M8 — Automated attack suite

Stop the API with `Ctrl+C` before this suite because it resets databases.

```bash
npm run attack-test | tee results/manual/M8-attack-command.log
```

The command prints a run directory such as:

```text
results/runs/<run-id>/
```

Preserve:

- `raw/attack-results.json`
- `summaries/security-summary.json`
- `environment.json`
- `run-manifest.json`
- `checksums.sha256`

Executed cases include modification, component-level hash mismatch, deletion, fabricated record, sequential/concurrent double voting, duplicate proof, authorization, tally gate, wrong key, voter-intent mutation, metadata modification, observer determinism, and result-proof verification. Fabric-only cases remain explicitly `NOT EXECUTED` in this component run.

---

## TEST M9 — Live Fabric/SmartBFT experiments

Start the full network if it is not already running:

```bash
./fabric/scripts/bootstrap.sh
```

Then run:

```bash
./scripts/run-fabric-experiments.sh | tee results/manual/M9-fabric-command.log
```

The output gives a directory under `results/fabric/`. Preserve:

- `fabric-results.csv`
- `manifest.json`
- `logs/duplicate.log`
- `logs/unauthorized.log`
- `logs/one-down.log`
- `logs/beyond-threshold.log`
- `resource-snapshot.jsonl`
- `checksums.sha256`

Verify Fabric Gateway separately:

```bash
npx tsx scripts/gateway-smoke.ts \
  | tee results/manual/M9-gateway-smoke.json
```

Interpret orderer-stop tests only as local crash/availability experiments, not malicious Byzantine behavior.

---

## 3. Generate checksums for manual evidence

```bash
find results/manual -type f ! -name checksums.sha256 -print0 \
  | sort -z \
  | xargs -0 sha256sum \
  > results/manual/checksums.sha256
```

Do not edit raw response files after checksums are generated. If a test must be repeated, use new filenames such as `M2-normal-vote-rerun-01.json` and preserve the failed file.

## 4. Manual observation record

Complete one row per executed test. Do not mark unexecuted tests as passed.

| Test | Execution time | Status | Actual key observation | Raw evidence | Classification |
|---|---|---|---|---|---|
| M1 Health | | | | `M1-health.json` | CONFIGURATION / FACT |
| M2 Normal vote | | | | `M2-normal-vote.json` | MEASURED |
| M3 TECV audit | | | | `M3-audit.json` | MEASURED |
| M4 Verified tally | | | | `M4-tally.json` | MEASURED |
| M5 Sequential duplicate | | | | `M5-second-vote.json` | MEASURED |
| M6 Concurrent duplicate | | | | `M6-concurrent-*.json` | MEASURED |
| M7 Auditor determinism | | | | `M7-*.json` | MEASURED / DERIVED |
| M8 Attack suite | | | | run directory | MEASURED / DERIVED |
| M9 Fabric/BFT | | | | Fabric run directory | MEASURED |

## 5. Paper-ready wording template

Replace bracketed fields only with values from your saved evidence:

> On [execution date], the supervised-polling-station prototype was evaluated using synthetic voters for district Jaffna. In the honest manual flow, [valid count] of [ledger-proof count] proofs passed TECV, and the verified tally reported [candidate totals]. The sequential second-vote attempt returned [actual error], while the concurrent test accepted [accepted count] of [attempt count] requests. Auditor A and Auditor B produced [matching/non-matching] stable audit hashes. These observations apply only to the executed local prototype environment.

For the Fabric test:

> In the local four-orderer Fabric 3.1.5 SmartBFT availability experiment, [committed count] of [attempted count] transactions committed with one orderer unavailable. With [failed-orderer count] orderers unavailable, the client [actual observed behavior] after [actual duration] ms. Stopped containers model crash/availability faults and do not constitute an experiment against malicious Byzantine behavior.

## 6. Claims you must not infer

Do not write that:

- TECV guarantees voter intent;
- the framework is completely secure;
- MemoryLedger component throughput is Fabric TPS;
- one successful run proves national scalability;
- stopped orderers prove malicious Byzantine-fault tolerance;
- expected response examples are measured findings.

Use: **“observed in the tested prototype environment”** and **“100% detection in the tested attack set”** only when the saved evidence supports those statements.
