# Research Questions and Hypotheses

**Document Status:** NOT EXECUTED
**Version:** 1.0
**Date:** 2026-10-05

---

## 1. Motivation and Context

Electronic voting systems must balance **availability**, **consistency**, and **auditability** under variable load conditions (e.g., election day spikes). This research investigates whether CouchDB's replication model can serve as a viable backend for voter-intent-preserving vote recording, with specific attention to the CAP theorem trade-offs inherent in its eventual consistency model.

---

## 2. Research Questions

### RQ1: Performance Under Variable Load

**RQ1:** *How does CouchDB's throughput and latency scale with increasing concurrency and workload mix in a three-node replicated deployment?*

**Sub-questions:**
- RQ1a: At what concurrency level does throughput plateau or degrade?
- RQ1b: How does write-heavy vs. read-heavy workload affect p99 latency?
- RQ1c: Does `network_latency_ms` have a non-linear effect on tail latency?

**Operationalization:** See Experiment Specification (Section 2) for variable definitions.

---

### RQ2: Consistency Guarantees Under Load

**RQ2:** *Do CouchDB's configurable consistency levels (eventual, sequential, strong) maintain voter-intent integrity under concurrent load, and what are the performance trade-offs?*

**Sub-questions:**
- RQ2a: Under eventual consistency, what is the maximum observed stale-read window?
- RQ2b: Does sequential consistency eliminate voter-intent drift without incurring strong consistency overhead?
- RQ2c: What is the throughput penalty for strong consistency vs. eventual consistency?

**Operationalization:** Consistency level configured per CouchDB `_revs_info` and revision limit parameters. Stale-read detection via shadow document with monotonically increasing sequence numbers.

---

### RQ3: Fault Tolerance and Recovery

**RQ3:** *How long does it take for a three-node CouchDB cluster to restore full read/write availability after a single-node failure, and does this recovery time meet election-day SLAs?*

**Sub-questions:**
- RQ3a: What is the time-to-detect for node failure?
- RQ3b: What is the time-to-recover for full quorum restoration?
- RQ3c: Are any ballots lost or duplicated during failover?

**Operationalization:** Controlled node kill via SIGTERM, metrics collected by watchdog process.

---

### RQ4: Voter-Intent Preservation

**RQ4:** *Under adversarial conditions (network partitions, Byzantine faults), does the system preserve voter intent with zero tolerance for drift?*

**Sub-questions:**
- RQ4a: Can network partitions cause divergent ballot records across nodes?
- RQ4b: What is the worst-case voter-intent drift under a split-brain scenario?
- RQ4c: Does the system's compensating logic (e.g., revision vectors) correctly reconcile diverged state?

**Operationalization:** Voter-intent drift measured as hash mismatch events per Experiment Specification Section 7.

---

## 3. Hypotheses

| ID | Hypothesis | Direction | Justification |
|----|------------|-----------|----------------|
| H1 | Throughput increases sub-linearly with concurrency beyond N=50 | Non-linear | Contention on write locks in CouchDB's MVCC |
| H2 | Strong consistency reduces throughput by >30% vs. eventual consistency | Negative effect | Quorum write overhead |
| H3 | Sequential consistency achieves voter-intent preservation without strong consistency penalty | Neutral/positive | Balances isolation and performance |
| H4 | Recovery time after single-node failure is <60 seconds | Positive | CouchDB's incremental replication |
| H5 | Voter-intent drift = 0 under normal operation (no partition) | Zero tolerance | Correct implementation should not drift |
| H6 | Voter-intent drift is detectable and bounded under partition | Bounded | Compensating logic limits divergence window |
| H7 | Dataset size has diminishing performance impact beyond 100K records | Diminishing returns | CouchDB view indexing amortizes scan cost |

---

## 4. Null Hypotheses (for significance testing)

| ID | Null Hypothesis | Test |
|----|-----------------|------|
| H0-1 | Throughput scales linearly with concurrency | ANOVA + Tukey HSD |
| H0-2 | Strong consistency has no throughput penalty | Mann-Whitney U test |
| H0-3 | Recovery time is independent of dataset size | Spearman correlation |
| H0-4 | Voter-intent drift rate > 0 under normal operation | Binomial test (p = 0) |

**Significance level:** α = 0.05, with Bonferroni correction for multiple comparisons (adjusted α = 0.0071 for 7 tests).

---

## 5. Boundary Conditions

### 5.1 Scope Boundaries

| Boundary | Value | Rationale |
|----------|-------|-----------|
| Maximum concurrency | 500 clients | Election day peak estimate |
| Maximum dataset | 1M ballots | National election scale (US 2020: ~160M votes) |
| Maximum network latency | 300ms | Transcontinental RTT ceiling |
| Failure mode | Single-node only | Primary-secondary-arbiter model |

### 5.1 Out-of-Scope

- Byzantine fault tolerance (malicious nodes)
- Multi-region geo-replication
- Real-time tabulation UI latency
- Voter authentication protocols
- Ballot encoding standards (CVR, VDF, blockchain)

---

## 6. Claim Mapping

Each hypothesis maps to one or more claims in the Claims Taxonomy (`08-claims-taxonomy.md`):

| Hypothesis | Primary Claim | Evidence Type |
|------------|---------------|---------------|
| H1 | Throughput scaling | Performance measurement |
| H2 | Consistency-performance trade-off | Comparative measurement |
| H3 | Sequential adequacy | Hybrid measurement + reasoning |
| H4 | Recovery SLA | Fault injection experiment |
| H5 | Intent preservation (normal) | Negative control (zero events) |
| H6 | Intent preservation (adversarial) | Fault injection + detection |
| H7 | Scalability | Performance measurement |
