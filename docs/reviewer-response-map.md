# Reviewer Response Map

| Reviewer concern | Implemented response | Evidence |
|---|---|---|
| Real-world setting unclear | Supervised polling-station model; synthetic Jaffna district voters only | `README.md`, methodology |
| Why CouchDB? | JSON operational data, MVCC token, off-chain minimization, controlled compromise testing; no superiority claim | `couchdb-design-rationale.md` |
| Technical contribution limited | Revision-aware proof binding, deterministic pre-tally consequence gate, and two-way consistency audit | `contribution-statement.md`, `packages/tecv` |
| No empirical validation | Executed attack run, 12-configuration workload matrix, two repeat runs, Fabric enforcement/fault run, checksums | `results/runs`, `results/fabric`, `results/report` |
| Does not prove voter intent | Explicit Candidate A intention / Candidate B encryption negative control passed TECV | attack TEST 15; `paper-results-draft.md` |
| Decryption/counting unclear | Only `validVoteDocIds` enter AES-GCM decryption; honest five-ballot totals matched ground truth | attack TEST 0; `apps/tally-service` |
| Fabric/PBFT unclear | Corrected to Fabric 3.1.5 BFT/SmartBFT ordering with four orderers; peers endorse/validate/commit | Fabric manifest and logs; no PBFT validator claim |
| Who performs TECV? | Deterministic auditor module; two executions produced matching audit hash and valid set | attack TEST 17 |
| Duplicate/unauthorized proof enforcement | Deployed chaincode returned `ERR_DUPLICATE_PROOF` and `ERR_UNAUTHORIZED` | Fabric raw logs |
| BFT evidence | One-orderer-down commit observed; three-orderer-down timeout observed | `fabric-results.csv`; qualified as crash/availability only |

## Required paper correction

Any prior statement that TECV proves voter intent, that CouchDB is intrinsically secure, that Fabric peers execute PBFT, or that the design was nationally validated must be removed.
