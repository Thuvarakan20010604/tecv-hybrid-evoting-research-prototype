# Paper Methodology Draft

## Prototype

The prototype models a supervised polling station in Jaffna using synthetic voters and mock biometric references. Application CouchDB 3.4.3 stores `voters_db` and `votes_db`. Ballots are encrypted with AES-256-GCM using a fresh 96-bit IV. The environment key is excluded from storage, ledger, logs, and source control.

The baseline proof hash is SHA-256 over deterministic canonical serialization of `encryptedBallot`. Each Fabric proof contains `voteDocId`, CouchDB `_rev`, hash, district, election ID, and timestamp. No plaintext choice is stored on-chain.

## Fabric

The executed network used Hyperledger Fabric 3.1.5, two peer organizations, TLS/MSP identities, embedded peer state databases, and four BFT/SmartBFT orderers created from the official `fabric-samples` BFT profile. The deployed Node contract API was 2.5.8, compatible with Fabric v3 peers. Org1MSP was mapped to vote-proof submission and Org2MSP to result-proof submission. The application includes the current Fabric Gateway API client.

All nodes were Docker containers on one workstation. This is logical, not geographic, distribution.

## TECV

For every ledger proof, TECV reads the referenced CouchDB document. It reports `MISSING_VOTE` when absent, `REVISION_MISMATCH` when `_rev` differs, `HASH_MISMATCH` when the canonical ciphertext hash differs, and `VALID` only when all conditions match. A reverse scan reports `UNPROVEN_DB_RECORD`. Only the sorted valid-document set enters tallying. The stable evidence structure is canonically hashed to produce the audit hash.

## Workloads and repetitions

Deterministic seed `20260047` generated candidates with intended probabilities 35%, 30%, 20%, and 15%. The primary component matrix measured 100, 1,000, and 5,000 ballots at concurrency 1, 5, 10, and 25. Concurrency-10 configurations received two additional independent runs. Initialization and container startup were excluded from transaction timing.

The performance matrix used real CouchDB and MemoryLedger to isolate application/TECV behavior. It must not be reported as Fabric TPS. Fabric tests separately measured individual live-chaincode transactions.

## Attacks and fault injection

Controlled tests executed normal flow, modification, component hash mismatch, deletion, unproven insertion, sequential/concurrent double voting, duplicate and unauthorized proof submission, unauthorized result submission, unverified tally, CouchDB unavailability, wrong key, voter-intent mutation, metadata modification, observer determinism, and result proof retrieval. Fabric tests stopped one orderer and then three orderers; stopped containers represent crash/availability faults.

## Metrics and analysis

`performance.now()` measured operation durations. Summaries calculate count, minimum, maximum, arithmetic mean, sample standard deviation, median, p90, p95, p99, and normal-approximation 95% confidence intervals. Security summaries calculate TP, TN, FP, FN, accuracy, precision, recall, specificity, F1, FPR, and FNR, returning N/A when a denominator is zero. Raw JSON/CSV/log files and SHA-256 manifests are preserved per run.
