# Methodology

**Document Status:** NOT EXECUTED
**Version:** 1.0
**Date:** 2026-10-05

---

## 1. Research Design Overview

This study employs a **mixed-methods empirical approach** combining:

1. **Controlled experiments** — Systematic performance and correctness evaluation under laboratory conditions
2. **Negative controls** — Voter-intent drift detection as a correctness baseline
3. **Analytical reasoning** — CAP theorem implications and CouchDB consistency model analysis

The methodology is designed to be **conservative** (favoring Type II error avoidance) and **reproducible** (full specification of conditions, seeds, and artifacts).

---

## 2. Paradigm and Theoretical Framework

### 2.1 CAP Theorem Context

CouchDB implements an **eventually consistent** data store under the CAP theorem. This research operationalizes the following CAP implications:

- **Consistency (C):** All nodes see the same data at the same time. CouchDB provides this via quorum reads/writes at the cost of latency.
- **Availability (A):** Every request receives a response. CouchDB remains available even with minority node failure.
- **Partition Tolerance (P):** System continues operating during network partitions. CouchDB handles this via masterless replication with conflict resolution.

**Design Claim:** For voter-intent preservation, **C > A > P** — consistency is non-negotiable; availability is preferred but secondary; partition tolerance is handled by design.

### 2.2 Isolation Levels Mapping

CouchDB's consistency levels map to SQL isolation levels:

| CouchDB Level | SQL Equivalent | Voter-Intent Risk |
|--------------|----------------|-------------------|
| `eventual` | Read Uncommitted | Possible stale read |
| `sequential` | Snapshot Isolation | Safe for single-key writes |
| `strong` | Serializable | Guaranteed safe |

**Decision Rule:** Sequential consistency is the **minimum acceptable level** for ballot recording. Strong consistency is measured but not required unless H3 fails.

---

## 3. Data Collection Methods

### 3.1 Performance Metrics

| Metric | Collection Method | Frequency |
|--------|------------------|-----------|
| Throughput | Operation counter / elapsed time | Per 60s window |
| Latency | Client-side timestamps (send, recv) | Per operation |
| Error rate | Exception/log-level counting | Per run |
| Consistency violations | Shadow document polling | Per 1s |
| Recovery time | Watchdog heartbeat | Continuous |

### 3.2 Correctness Metrics

| Metric | Collection Method | Threshold |
|--------|------------------|-----------|
| Voter-intent drift | Hash verification | 0 events |
| Ballot duplication | Sequence number gap detection | 0 events |
| Ballot loss | Submitted vs. recorded count | 0 events |
| Conflict count | CouchDB conflict revision count | ≤ threshold |

### 3.3 Data Sources

- **Primary:** Experiment instrumentation logs (JSON)
- **Secondary:** CouchDB `/_all_dbs`, `/_node_stats` endpoints
- **Tertiary:** System-level metrics (iostat, vmstat, netstat)

---

## 4. Analytical Strategy

### 4.1 Statistical Analysis

| Analysis | Purpose | Method |
|----------|---------|--------|
| Throughput scaling | Test H1, H7 | Polynomial regression |
| Consistency penalty | Test H2 | Cohen's d effect size |
| Recovery time | Test H4 | Kaplan-Meier survival analysis |
| Voter-intent drift | Test H5, H6 | Binomial exact test |
| Multi-factor interactions | Test all | ANOVA with interaction terms |

**Software:** R (version ≥ 4.3) with `stats`, `survival`, `effsize` packages.

### 4.2 Qualitative Analysis

For anomalies and unexpected results, a structured root-cause analysis (RCA) protocol is applied:

1. **Describe:** What happened, when, under what conditions?
2. **Measure:** What metricsdeviated?
3. **Hypothesize:** What is the plausible cause?
4. **Test:** Can the cause be reproduced?
5. **Conclude:** Is the cause confirmed or ruled out?

---

## 5. Validity Threats and Mitigations

### 5.1 Internal Validity

| Threat | Mitigation |
|--------|------------|
| Instrumentation bias | Separate monitoring process from workload generation |
| Warm-up effects | 120s warm-up before measurement |
| Memory leaks | Fresh instance per condition |
| Clock drift | NTP synchronization before each run |
| Non-independence | Randomization of run order within blocks |

### 5.2 External Validity

| Threat | Mitigation |
|--------|------------|
| Lab-to-production gap | Explicit boundary conditions documented |
| Synthetic ballot vs. real | Acknowledged in Limitations section |
| Single CouchDB version | Pin to LTS version, document upgrade path |
| Single hardware config | Test across at least 2 hardware profiles |

### 5.3 Construct Validity

| Threat | Mitigation |
|--------|------------|
| Operationalization mismatch | Map each RQ to IV/DV explicitly |
| Face validity | Expert review of ballot hash as intent proxy |
| Predictive validity | Negative control baseline must pass first |

---

## 6. Ethical Considerations

### 6.1 Human Subjects

**Not applicable.** No human voter data is used. All ballots are synthetic with no PII.

### 6.2 Dual Use

The CouchDB consistency techniques studied here could be applied to:
- **Positive:** Auditable voting systems, audit logs, medical records
- **Negative:** Surveillance systems, censorship platforms

**Mitigation:** Research is published under open-access principles; no proprietary restrictions on use.

### 6.3 Environmental Impact

- Estimated cloud compute: ~500 GPU-hours equivalent
- Carbon footprint: Calculated and reported in supplementary materials

---

## 7. Reproducibility Checklist

- [ ] CouchDB version pinned
- [ ] Experiment code version-tagged
- [ ] Random seeds logged
- [ ] Raw logs archived (SHA-256)
- [ ] Statistical code version-pinned (R, Python)
- [ ] Hardware specs documented
- [ ] OS and kernel version documented
- [ ] Docker image digests recorded
- [ ] Analysis scripts included in artifact

---

## 8. Limitations (A Priori)

This methodology acknowledges the following limitations before execution:

1. **Synthetic workload:** May not capture real election-day behavioral patterns
2. **Single-region:** No geo-distribution effects studied
3. **Single failure mode:** Multi-node simultaneous failure not tested
4. **No Byzantine actors:** All nodes assumed honest-but-crashy
5. **No human factors:** Voter UX, accessibility not evaluated
6. **Short fault window:** Long-duration partitions (>1 hour) not simulated

These limitations will be explicitly stated in the paper's "Threats to Validity" section.
