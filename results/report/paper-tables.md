# Paper-ready Tables

Evidence: attack 2026-10-05T09-36-02-444Z-18396; benchmark 2026-10-05T09-27-55-634Z-19976; Fabric fabric-20261005T095132Z.

## Table 3 — End-to-End Performance (real CouchDB + MemoryLedger component mode)

| Votes | Concurrency | Success rate | Mean ms | Median | P95 | P99 | Successful commits/s |
|---:|---:|---:|---:|---:|---:|---:|---:|
|100|1|1.000|22.370|21.562|28.820|34.501|44.683|
|100|5|1.000|32.663|32.585|40.930|43.323|125.728|
|100|10|1.000|44.568|46.059|54.066|54.388|187.777|
|100|25|1.000|65.637|67.446|84.139|84.778|330.343|
|1000|1|1.000|22.094|21.683|24.759|32.176|45.248|
|1000|5|1.000|40.235|40.375|52.603|55.806|100.772|
|1000|10|1.000|50.878|52.044|64.368|66.414|166.925|
|1000|25|1.000|73.274|75.572|87.969|97.305|294.345|
|5000|1|1.000|22.173|21.676|25.519|32.396|45.087|
|5000|5|1.000|36.357|36.078|47.209|52.426|111.753|
|5000|10|1.000|52.229|54.072|65.366|70.800|161.508|
|5000|25|1.000|73.161|76.381|87.644|92.847|295.574|

## Table 4 — TECV Performance

| Votes | Valid | Invalid | Batch ms | Validations/s |
|---:|---:|---:|---:|---:|
|100|100|0|202.630|493.510|
|100|100|0|193.072|517.942|
|100|100|0|193.914|515.693|
|100|100|0|195.459|511.618|
|1000|1000|0|1929.494|518.271|
|1000|1000|0|2028.680|492.931|
|1000|1000|0|2043.272|489.411|
|1000|1000|0|1926.302|519.129|
|5000|5000|0|10007.507|499.625|
|5000|5000|0|9838.599|508.202|
|5000|5000|0|10348.375|483.168|
|5000|5000|0|9941.493|502.943|

## Table 6 — Tally Correctness

| Candidate | Ground truth | Prototype | Difference |
|---|---:|---:|---:|
|Candidate A|2|2|0|
|Candidate B|1|1|0|
|Candidate C|1|1|0|
|Candidate D|1|1|0|

## Table 8 — BFT Availability

| Active orderers | Scenario | Attempts | Committed | Failed/timeout | Duration ms | Outcome |
|---:|---|---:|---:|---:|---:|---|
|4|normal_4_orderers|1|1|0|238|PASS|
|4|duplicate_proof_rejection|1|0|1|182|EXPECTED_REJECTION_OR_FAILURE|
|4|unauthorized_vote_rejection|1|0|1|184|EXPECTED_REJECTION_OR_FAILURE|
|4|result_proof|1|1|0|257|PASS|
|3|one_orderer_unavailable|1|1|0|265|PASS|
|1|beyond_threshold|1|0|1|10252|LIVENESS_LOSS_OBSERVED|

## Table 10 — Storage

| Votes | CouchDB external bytes | Bytes/vote | Fabric ledger bytes |
|---:|---:|---:|---|
|100|30300|303.000|NOT MEASURED|
|1000|303000|303.000|NOT MEASURED|
|5000|1515000|303.000|NOT MEASURED|
