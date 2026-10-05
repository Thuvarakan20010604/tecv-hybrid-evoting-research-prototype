# TECV Hybrid E-Voting Research Prototype

A reproducible **supervised polling-station** prototype for revision-aware validation of encrypted ballot records stored in application-level CouchDB against immutable proof records intended for Hyperledger Fabric.

> Research specification: AES-256. Prototype implementation: **AES-256-GCM**.
>
> Scope: TECV detects post-cast storage inconsistencies. It does **not** prove cast-as-intended voter intent and is not a complete secure voting system.

## Integrity labels

Every result is classified as **MEASURED**, **DERIVED FROM MEASURED DATA**, **CONFIGURATION / FACT**, **THEORETICAL / PROTOCOL PROPERTY**, **NOT TESTED**, or **LIMITATION**. The MemoryLedger adapter exists only for unit/component integration tests; it is never evidence of Fabric/BFT behavior.

## Prerequisites

- Node.js 22+ (tested host has Node 26)
- Docker and Docker Compose
- Bash for Fabric bootstrap scripts
- Hyperledger Fabric prerequisites for the full BFT profile

Python, Go, and GNU Make are optional on the host because the core harness is TypeScript and chaincode can run in a container.

## Quick start

```bash
cp .env.example .env
# Set BALLOT_KEY_HEX to: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
docker compose up -d couchdb
npm install
npm test
npm run attack-test
BENCHMARK_SIZES=100 CONCURRENCY_LEVELS=1,5 npm run benchmark
npm run report
```

The default `npm run research-run` attempts sizes 100, 1,000, and 5,000 at concurrency 1, 5, 10, and 25. Failed runs are preserved under `results/runs/<run-id>/FAILED.json`.

## Full Fabric BFT setup

The executed setup uses the official Fabric 3.1.5 BFT sample profile (four SmartBFT orderers and two peers):

```bash
./fabric/scripts/bootstrap.sh
./scripts/run-fabric-experiments.sh
npx tsx scripts/gateway-smoke.ts
```

On Windows Git Bash, the bootstrap applies the required Docker-socket path compatibility patch. Downloaded samples, generated MSP private keys, and binaries live under ignored `fabric/vendor/`.

The application supports `LEDGER_ADAPTER=fabric` through the current Fabric Gateway API. Vote and result submissions use separate Org1MSP and Org2MSP credentials configured with the paths in `.env.example`.

## Commands

- `make setup`, `make start`, `make stop`, `make reset`
- `make seed`, `make test`, `make attack-test`, `make benchmark`
- `make research-run`, `make generate-report`
- `./scripts/run-research-experiments.sh` — component suite, live Fabric suite when running, and consolidated paper outputs
- Without Make: use the equivalent `npm` and `docker compose` commands in the Makefile.

## Architecture

- `voters_db`: synthetic voter authorization state; CouchDB MVCC enforces concurrent single-use transition.
- `votes_db`: encrypted AES-256-GCM ballots, append-only through normal application code.
- `chaincode/`: VoteProof and Result contracts with identity and duplicate enforcement.
- `packages/tecv`: deterministic ledger→database and database→ledger audit.
- `apps/tally-service`: decrypts only the TECV-valid set and emits a result proof.
- `experiments/`: attack injection, benchmarks, statistics, manifests, and checksums.
- `fabric/`: four-orderer BFT/two-peer-organization infrastructure artifacts.

The application CouchDB is separate from any Fabric peer state database.

## Manual testing and paper evidence

Follow [docs/manual-test-guide.md](docs/manual-test-guide.md) for synthetic voter IDs, exact curl commands, expected response patterns, raw-evidence filenames, checksums, and paper-safe wording.

## Result interpretation

A run using `ledgerAdapter: MemoryLedger` validates application logic only. It does **not** support claims about Fabric, SmartBFT, four-orderer availability, peer endorsement, or ledger disk usage. Only a run manifest explicitly showing active Fabric containers and captured Fabric transaction evidence may support those claims.

## Secrets and privacy

Only synthetic voters and mock biometric references are used. Keys belong in environment variables. Never store a ballot key in CouchDB, Fabric, logs, or source control. Production deployments require trustee/threshold decryption, HSM-backed custody, and independent key holders.
