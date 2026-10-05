# Paper Results Draft

## Evidence scope

The component-performance matrix used real CouchDB 3.4.3 with the MemoryLedger adapter; it does not represent Fabric TPS. Separately, Fabric 3.1.5 chaincode and crash-availability tests ran on four SmartBFT orderers and two peers.

## Functional and security results

In the executed attack run, modification, deletion, and unproven insertion were classified as revision mismatch, missing vote, and unproven database record. The derived tested-set confusion matrix was TP=3, TN=5, FP=0, and FN=0. This is 100% detection only in the tested attack set, not a general security claim. Concurrent and sequential double voting were rejected. The chaincode run returned ERR_DUPLICATE_PROOF and ERR_UNAUTHORIZED for the corresponding transactions.

## Tally correctness

The honest five-ballot synthetic flow produced {"Candidate A":2,"Candidate B":1,"Candidate C":1,"Candidate D":1}, equal to ground truth {"Candidate A":2,"Candidate B":1,"Candidate C":1,"Candidate D":1} with zero per-candidate difference. This demonstrates correctness under the honest prototype implementation, not cast-as-intended verifiability.

## Performance

Across the primary 12-configuration component matrix, all 24400 ballot operations succeeded. Mean end-to-end latency ranged from 22.094 to 73.274 ms and successful component commit throughput ranged from 44.683 to 330.343 operations/s. At 5,000 ballots, TECV processed 483.168 validations/s in the concurrency-10 run.

## BFT availability

The four-orderer baseline transaction committed in 238 ms. With one orderer stopped, the tested transaction committed in 265 ms. With three orderers stopped, the bounded client observed no commit and timed out after 10252 ms. These are single-attempt crash/availability observations, not Byzantine-malicious fault tests.

## Storage, resources, and cost

CouchDB external data size was 303 bytes per ballot in each measured primary workload. Fabric ledger bytes were not measured. Docker resource data is a single post-experiment snapshot; average and peak CPU/RAM are not supported. Cloud cost requires provider pricing input.

## Negative control

The intended Candidate A / encrypted Candidate B experiment passed TECV. **LIMITATION CONFIRMED:** TECV detects post-cast inconsistency but does not provide cast-as-intended verification.
