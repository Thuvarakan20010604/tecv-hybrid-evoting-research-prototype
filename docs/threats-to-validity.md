# Threats to Validity

## Internal validity

Prototype defects, timestamp instrumentation, Node/Docker scheduling, and container co-location may affect observations. The application benchmark used a MemoryLedger adapter and therefore isolates CouchDB/application behavior rather than Fabric commit performance. Raw failed attempts were retained.

## External validity

The environment was one Windows workstation with local Docker containers, synthetic voters, one district, and at most 5,000 ballots per measured configuration. Logical institutional labels are not geographic or administrative independence. Results cannot be generalized to national deployment.

## Construct validity

The injected modification, deletion, fabrication, duplicate, and authorization scenarios represent a limited attack set. Stopping orderer containers models crash/availability faults, not arbitrary Byzantine-malicious behavior. Hash mismatch was a component-level controlled vector, not an end-to-end database attack.

## Security validity

TECV does not prove cast-as-intended voter intent, prevent coercion/vote buying, secure a compromised terminal before encryption, protect a compromised ballot key, validate real biometrics, or stop nationwide denial of service. Environment-based prototype key custody is not production-grade; trustee threshold decryption and HSM-backed independent custodians are required for production research.

## Statistical validity

The primary workload matrix has one run per size/concurrency configuration. Concurrency-10 workloads at 100, 1,000, and 5,000 ballots have three independent runs. Fabric fault states have one transaction attempt each. Finite repetitions and host noise restrict confidence. CPU/RAM averages and peaks were not measured; only a post-experiment Docker snapshot exists.
