# CLAIMS SUPPORTED BY EXPERIMENT

- In the tested set, TECV identified post-cast revision modification, missing anchored ballots, and unproven CouchDB records.
- The component hash-mismatch path rejected a deliberately mismatched proof hash.
- Sequential and concurrent duplicate voting attempts were rejected in the executed CouchDB MVCC tests.
- Deployed Fabric chaincode rejected duplicate proof IDs and an unauthorized MSP.
- The honest five-ballot verified tally matched synthetic ground truth.
- In one local run, a four-orderer SmartBFT network committed with one orderer stopped and did not commit before timeout with three stopped.

# CLAIMS NOT SUPPORTED / MUST NOT BE MADE

- TECV proves voter intent or cast-as-intended correctness.
- The system is completely secure.
- Component benchmark throughput is Fabric TPS.
- The prototype has national-scale or geographically independent fault tolerance.
- A stopped orderer demonstrates malicious Byzantine behavior.
- Average/peak resource use, Fabric bytes per vote, network overhead, or cloud cost were measured.
