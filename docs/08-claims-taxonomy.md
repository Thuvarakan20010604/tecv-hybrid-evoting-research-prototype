# Claims Taxonomy

**Document Status:** NOT EXECUTED
**Version:** 1.0
**Date:** 2026-10-05

---

## 1. Purpose

This document classifies all claims made in the research and maps them to evidence requirements. It ensures that claims are appropriately hedged based on the strength of supporting evidence and that no unsupported claims appear in the final manuscript.

---

## 2. Claim Classification Framework

### 2.1 Claim Categories

| Category | Code | Definition | Example | Evidence Requirement |
|----------|------|------------|---------|---------------------|
| Empirical | E | Observable facts from experiments | "Throughput at N=100 is X ops/sec" | Experimental measurement |
| Comparative | C | Relative performance difference | "Strong consistency is 30% slower than eventual" | Controlled experiment with statistical test |
| Correlational | R | Association between variables | "Higher latency correlates with higher error rate" | Correlation analysis |
| Analytical | A | Logical deduction from design | "CouchDB provides eventual consistency by default" | System inspection |
| Speculative | S | Future work or extension | "This could be applied to medical records" | None required (labeled as speculation) |
| Negative | N | Null result or absence of effect | "Voter-intent drift = 0 under normal operation" | Rigorous negative control |

### 2.2 Claim Strength Levels

| Level | Label | Qualifier Required | Example |
|-------|-------|-------------------|---------|
| 1 | Definitive | No | "CouchDB uses multi-version concurrency control" |
| 2 | Established | No | "SHA-256 is collision-resistant" |
| 3 | Well-supported | Minimal | "Throughput scales sub-linearly" (from data) |
| 4 | Supported | Yes | "Consistency level X outperforms Y in scenario Z" |
| 5 | Preliminary | Yes + caveats | "This configuration may be suitable for production" |
| 6 | Speculative | "Future work could explore" | Not a contribution |

---

## 3. Master Claim List

### 3.1 Performance Claims (Empirical)

| ID | Claim | Category | Strength | Evidence Type |
|----|-------|----------|----------|---------------|
| P-1 | CouchDB throughput increases with concurrency up to N=X, then plateaus | E | 3 | Throughput measurement |
| P-2 | Throughput scaling is sub-linear beyond N=50 | E | 3 | Polynomial regression |
| P-3 | Write-heavy workloads have higher p99 latency than read-heavy | E | 3 | Latency comparison |
| P-4 | Dataset size > 100K shows diminishing performance impact | E | 3 | Comparative measurement |
| P-5 | Network latency has non-linear effect on tail latency | E | 4 | Interaction analysis |

**Evidence requirement for P-1 through P-5:** Full experimental results (NOT EXECUTED → TBD placeholders)

### 3.2 Consistency Claims (Comparative)

| ID | Claim | Category | Strength | Evidence Type |
|----|-------|----------|----------|---------------|
| C-1 | Strong consistency reduces throughput by >30% vs. eventual | C | 4 | Cohen's d effect size |
| C-2 | Sequential consistency achieves <5% throughput penalty vs. eventual | C | 4 | Percentage difference + CI |
| C-3 | Read quorum r=2 prevents stale reads under normal operation | N | 2 | System inspection + negative control |
| C-4 | Write quorum w=2 prevents lost writes | N | 2 | System inspection + negative control |
| C-5 | Eventual consistency allows stale reads detectable within X seconds | E | 3 | Stale-read measurement |

**Evidence requirement for C-1, C-2:** Comparative experiment with statistical test
**Evidence requirement for C-3, C-4:** Design inspection + negative control passing

### 3.3 Fault Tolerance Claims (Empirical)

| ID | Claim | Category | Strength | Evidence Type |
|----|-------|----------|----------|---------------|
| F-1 | Single-node failure detection time < 30 seconds | E | 3 | Fault injection experiment |
| F-2 | Recovery time after node failure < 60 seconds | E | 3 | Fault injection experiment |
| F-3 | Cluster remains available during single-node failure | E | 2 | System design inspection |
| F-4 | No ballots lost during failover | N | 1 | Negative control |
| F-5 | Recovery time scales with dataset size | R | 4 | Correlation analysis |

**Evidence requirement for F-1, F-2:** Fault injection experiment
**Evidence requirement for F-4:** Negative control with zero events

### 3.4 Voter-Intent Claims (Negative)

| ID | Claim | Category | Strength | Evidence Type |
|----|-------|----------|----------|---------------|
| V-1 | Voter-intent drift = 0 under normal operation (all conditions) | N | 1 | Negative control |
| V-2 | Voter-intent drift is detectable under partition | N | 2 | Fault injection + detection |
| V-3 | Voter-intent drift is bounded (max X events) under partition | E | 3 | Fault injection measurement |
| V-4 | Hash verification detects all intentional modifications | A | 2 | Cryptographic reasoning |

**Evidence requirement for V-1:** Zero events across all control conditions
**Evidence requirement for V-2, V-3:** Fault injection experiment
**Evidence requirement for V-4:** SHA-256 collision resistance (established)

### 3.5 Design Claims (Analytical)

| ID | Claim | Category | Strength | Evidence Type |
|----|-------|----------|----------|---------------|
| D-1 | CouchDB's replication model supports masterless operation | A | 1 | Documentation inspection |
| D-2 | CouchDB revision trees enable conflict detection | A | 1 | Documentation inspection |
| D-3 | CouchDB's default is eventual consistency (AP) | A | 1 | Documentation inspection |
| D-4 | CouchDB can be configured for strong consistency (CP) | A | 2 | Configuration + experiment |
| D-5 | Sequential consistency maps to Snapshot Isolation | A | 2 | SQL standard mapping |

### 3.6 Comparison Claims (Comparative)

| ID | Claim | Category | Strength | Evidence Type |
|----|-------|----------|----------|---------------|
| M-1 | CouchDB is suitable for voter-intent recording vs. alternatives | C | 5 | Comparison framework (not exhaustive) |
| M-2 | CouchDB's conflict detection is superior to Cassandra's LWW | C | 5 | Feature comparison (not empirical) |

**Evidence requirement for M-1, M-2:** Qualitative comparison; labeled as "preliminary assessment"

---

## 4. Claim-to-Evidence Mapping

```
Claim Category → Evidence Requirements

E (Empirical) → Requires experimental results
  └── MUST have: measurement data, statistical summary
  └── MUST NOT have: invented numbers (use TBD placeholders)

C (Comparative) → Requires controlled comparison
  └── MUST have: statistical test, effect size, confidence interval
  └── MUST NOT have: cherry-picked conditions

R (Correlational) → Requires correlation analysis
  └── MUST have: correlation coefficient, p-value, N
  └── MUST NOT imply: causation

A (Analytical) → Requires reasoning or inspection
  └── MUST have: citation or inspection evidence
  └── MUST be: clearly labeled as analytical, not empirical

S (Speculative) → Labeled as future work
  └── MUST have: "Future work could..." or "This suggests..."
  └── MUST NOT be: presented as contribution

N (Negative) → Requires rigorous negative control
  └── MUST have: zero events, exact binomial CI
  └── MUST be: pre-specified, not post-hoc
```

---

## 5. Prohibited Claim Patterns

The following claim formulations are prohibited:

| Prohibited | Reason | Fix |
|------------|--------|-----|
| "Results show..." without data | Premature | Use "This study will show..." or TBD |
| "Significantly different" without p-value | Unverifiable | Report exact p-value |
| "Proven to be safe" | Absolute claim | Use "no drift detected in N trials" |
| "Always" / "Never" | Overclaiming | Use "under tested conditions" |
| "Generalizes to all X" | Overclaiming | Scope to tested conditions |
| Invented numbers | Fabrication | Use TBD placeholders |

---

## 6. Hedging Language Guidelines

| Claim Strength | Appropriate Hedging |
|---------------|---------------------|
| Definitive | "CouchDB implements X" (no hedge needed) |
| Established | "SHA-256 is considered collision-resistant" |
| Well-supported | "Data suggest...", "Results indicate..." |
| Supported | "Under condition X, Y outperforms Z", "We observe..." |
| Preliminary | "This configuration may be suitable...", "These results suggest the potential for..." |
| Speculative | "Future work could explore...", "This approach might generalize to..." |

---

## 7. Evidence Checklist

Before claiming any result, verify:

- [ ] Experimental results are present (or TBD placeholder)
- [ ] Statistical tests have p-values and effect sizes
- [ ] Negative controls have zero events with exact CI
- [ ] Analytical claims have citations
- [ ] Speculative claims are labeled as such
- [ ] No invented numbers appear

---

## 8. Results Section Placeholders

Since experiments are NOT EXECUTED, all results will use:

```
**Result:** TBD
**Table X:** TBD
**Figure X:** TBD
**Statistical test:** TBD (N=XXXX, p=TBD, d=TBD)
```

When experiments complete, replace TBD with actual values.
