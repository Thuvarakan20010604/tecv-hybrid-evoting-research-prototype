# Reviewer Response Guide

**Document Status:** NOT EXECUTED
**Version:** 1.0
**Date:** 2026-10-05

---

## 1. Purpose

This document anticipates potential reviewer concerns and provides structured rebuttals. It is organized by anticipated review category and includes specific talking points, evidence requirements, and pre-emptive acknowledgments.

---

## 2. Anticipated Review Categories

### 2.1 Methodology Reviews

| Concern | Severity | Response Strategy |
|---------|----------|-------------------|
| Synthetic workload not representative | High | Acknowledge limitation; justify with reproducibility; propose real-world validation as future work |
| Single CouchDB version | Medium | Pin to LTS; document upgrade path; version comparison as future work |
| Single hardware configuration | Medium | Acknowledge; test across ≥2 hardware profiles; normalize metrics |
| Missing statistical power analysis | Medium | Include a priori power analysis; state minimum detectable effect |
| No human subjects validation | Medium | Acknowledge; note synthetic ballot rationale; cite usability literature |

### 2.2 Claims Reviews

| Concern | Severity | Response Strategy |
|---------|----------|-------------------|
| Overclaiming on voter-intent preservation | High | Qualify claims with "within tested conditions"; acknowledge out-of-scope threats |
| Generalizing to all voting systems | High | Narrow scope explicitly; CouchDB-specific findings only |
| Correlation vs. causation | Medium | Distinguish observational from experimental claims; avoid causal language |
| Effect size vs. statistical significance | Medium | Report both; emphasize practical significance |
| Multiple comparisons | Medium | Apply Bonferroni correction; pre-register primary hypotheses |

### 2.3 Security Reviews

| Concern | Severity | Response Strategy |
|---------|----------|-------------------|
| Assumes trusted election authority | High | Acknowledge; note out-of-scope; cite Byzantine tolerance literature |
| Voter authentication not addressed | High | Explicitly scope out; note separate identity layer required |
| No formal verification | High | Acknowledge; propose TCB reduction as future work |
| Encryption at rest not implemented | Medium | Acknowledge; note as operational choice; cite solution approaches |
| Physical security not addressed | Medium | Acknowledge out-of-scope; physical security assumed |

### 2.4 Reproducibility Reviews

| Concern | Severity | Response Strategy |
|---------|----------|-------------------|
| No code/data availability | High | Release all code, configs, seeds; archive at DOI |
| Platform-dependent results | Medium | Document hardware; test on ≥2 platforms |
| Non-deterministic results | Medium | Log all seeds; report variance metrics |
| Missing artifact validation | Medium | Provide validation script; screenshot of successful run |

---

## 3. Specific Anticipated Comments and Responses

### R3.1: "The synthetic workload may not reflect real election-day traffic patterns"

**Response:**
> We acknowledge this as a fundamental limitation. Real election-day traffic exhibits burst patterns, diurnal cycles, and voter behavior effects (e.g., queue at poll closing) that synthetic workloads cannot fully capture. Our methodology prioritizes reproducibility and controlled experimentation over ecological validity. We recommend real-world validation as future work, potentially using shadow mode testing with a production-equivalent system.

**Pre-emptive acknowledgment in paper:**
> "The synthetic workload used in this study does not capture all real-world election traffic patterns. Burst traffic, voter panic loading, and diurnal effects are not modeled."

### R3.2: "Why CouchDB? Why not evaluate PostgreSQL, MongoDB, etc.?"

**Response:**
> We selected CouchDB based on its (1) configurable consistency model enabling CAP trade-off study, (2) masterless replication reducing SPOF, and (3) native conflict detection via revision trees. A full comparative evaluation of all candidate databases is beyond the scope of a single paper; we focus on rigorous evaluation of CouchDB as a representative eventual-consistency system. We explicitly note this as a limitation and cite comparable studies for alternative databases.

**Pre-emptive acknowledgment in paper:**
> "This study evaluates CouchDB specifically; findings may not generalize to other distributed databases. We justify CouchDB selection in Section X."

### R3.3: "The threat model assumes honest-but-crashy nodes; what about Byzantine faults?"

**Response:**
> Byzantine fault tolerance (BFT) is explicitly out of scope for this paper. BFT requires >3n+1 nodes and introduces significant performance overhead, fundamentally changing the system design. CouchDB does not provide BFT. We acknowledge this limitation and cite dedicated BFT voting system literature (e.g., [X, Y]) for readers interested in that threat model.

**Pre-emptive acknowledgment in paper:**
> "This paper assumes the honest-but-crashy failure model. Byzantine fault tolerance, where nodes may act maliciously, is out of scope and addressed in [citation]."

### R3.4: "How do you know voter intent is preserved if you can't observe voter behavior?"

**Response:**
> We operationalize voter intent preservation as the absence of ballot modification between submission and storage. The voter computes a cryptographic hash of their ballot content; if this hash matches upon storage and retrieval, intent is preserved. This is a proxy measure, not a direct observation of voter intent. We acknowledge this limitation and justify the proxy as standard practice in verifiable voting systems (e.g., Scantegrity, Helios).

**Pre-emptive acknowledgment in paper:**
> "Voter intent is operationalized via cryptographic hash verification. While this does not capture subjective voter intent, it is standard practice for verifiable voting systems [citation]."

### R3.5: "The negative control requires zero tolerance; how do you justify statistical confidence?"

**Response:**
> We use exact binomial confidence intervals. With N=0 events observed out of M trials, the one-sided 95% CI upper bound is:
>
> ```
> λ_upper = χ²(0.05, 2) / (2 × M)
> ```
>
> For M=1,000,000 trials, λ_upper = 5.15×10⁻⁸. This gives us 95% confidence that the true drift rate is below this bound, meeting our zero-tolerance requirement for practical purposes.

**Statistical note in paper:**
> "The 95% confidence interval for zero observed drift events out of 1,000,000 trials is [0, 5.15×10⁻⁸]."

### R3.6: "No real elections were run; how do you claim this applies to elections?"

**Response:**
> We do not claim this system is ready for real elections. This is a research prototype evaluating database suitability. Production deployment requires additional components (voter authentication, ballot certification, compliance with election standards) not addressed here. We position this work as foundational database research for future election system development.

**Pre-emptive statement in paper:**
> "This is a research prototype; it is not certified for use in real elections. Production deployment requires additional components beyond this paper's scope."

### R3.7: "The CAP theorem discussion is superficial; CouchDB is ultimately AP"

**Response:**
> We agree that CouchDB's default is AP (eventual consistency), but CouchDB allows configurable consistency via quorum parameters. We study these configurations explicitly. The CAP theorem states you cannot have all three simultaneously during partition; CouchDB lets you choose which two of C and A to prioritize. We clarify this nuance in the methodology section.

**Revised text:**
> "CouchDB's default is AP (eventual consistency), but quorum parameters allow configuration toward CP (strong consistency) at the cost of availability. This paper studies CouchDB across its configurable range."

---

## 4. Response Template

When responding to reviews, use the following structure:

```
### Response to [Reviewer Concern]

**Reviewer's comment:** [Quote or paraphrase]

**Our response:** [Direct response addressing the concern]

**Action taken:** [If applicable: text revision, additional analysis, new experiment]

**Location in revised manuscript:** [Section X, Paragraph Y]
```

---

## 5. Pre-Emptive Revisions

Based on anticipated reviews, we will make the following revisions to the manuscript:

1. **Add explicit scope statement** in Introduction
2. **Add threat model limitations** in Security section
3. **Add synthetic workload justification** in Methodology
4. **Add statistical power analysis** in Experiment Specification
5. **Add CouchDB version rationale** in Design section
6. **Add "research prototype" disclaimer** in Abstract and Conclusion

---

## 6. Escalation Protocol

If reviewers raise concerns not addressed here:

| Category | Action |
|----------|--------|
| Already anticipated | Use prepared response |
| New but addressable | Draft response + new experiment if needed |
| Fundamental challenge | Consider paper scope reduction or major revision |
| Out of scope | Politely acknowledge and redirect |
| Incorrect premise | Provide correction with evidence |
