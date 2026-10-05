# Threat Analysis

**Document Status:** NOT EXECUTED
**Version:** 1.0
**Date:** 2026-10-05

---

## 1. Threat Model Overview

This threat analysis follows the **STRIDE** methodology (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege) applied to the voter-intent recording system.

### 1.1 Scope

Threats are analyzed within the security boundary defined in `06-security-boundary.md`. The trusted zone includes the CouchDB cluster and Ballot Recording Service; the untrusted zone includes voter devices and public networks.

### 1.2 Assumptions

- Honest-but-crashy failure model (no Byzantine actors within trusted zone)
- Election authority is trusted
- Cryptographic primitives (SHA-256, TLS 1.3, Ed25519) are secure
- CouchDB software is vulnerability-free (per version)

---

## 2. Threat Enumeration (STRIDE)

### 2.1 Spoofing (Identity Impersonation)

| Threat ID | Threat | Likelihood | Impact | Mitigation |
|-----------|--------|------------|--------|------------|
| S-1 | Voter impersonation | Low | Critical | Voter authentication (out of scope) |
| S-2 | CouchDB node impersonation | Very Low | High | mTLS with certificate pinning |
| S-3 | API server impersonation | Very Low | High | TLS server certificates |

**Analysis:** Voter impersonation is not addressed by this system (requires separate identity verification layer). CouchDB/node impersonation is mitigated by mTLS.

### 2.2 Tampering (Unauthorized Modification)

| Threat ID | Threat | Likelihood | Impact | Mitigation |
|-----------|--------|------------|--------|------------|
| T-1 | Ballot content modification | Low | Critical | Voter intent hash verification |
| T-2 | Voter-intent hash collision | Very Low | Critical | SHA-256 with voter secret |
| T-3 | CouchDB revision manipulation | Very Low | Critical | Immutable audit log |
| T-4 | Log tampering | Low | High | Append-only log, hash chain |
| T-5 | Configuration drift | Medium | High | Configuration as code, version control |

**Analysis:** T-1 and T-2 are the primary threats to voter intent. The voter-intent hash provides tamper evidence; any modification is detectable.

### 2.3 Repudiation (Denial of Action)

| Threat ID | Threat | Likelihood | Impact | Mitigation |
|-----------|--------|------------|--------|------------|
| R-1 | Voter denies casting ballot | Low | Medium | Server timestamps + voter receipt |
| R-2 | Election authority denies recording | Very Low | High | Immutable audit log |
| R-3 | Voter denies seeing ballot confirmation | Low | Low | Cryptographic receipt |

**Analysis:** Voter receipts (signed by server) provide non-repudiation. Combined with server-side audit log, both parties have evidence.

### 2.4 Information Disclosure (Confidentiality Breach)

| Threat ID | Threat | Likelihood | Impact | Mitigation |
|-----------|--------|------------|--------|------------|
| I-1 | Ballot content leak | Low | High | Field encryption (optional), TLS |
| I-2 | Voter identity correlation | Medium | Medium | Voter ID hashed, separated from ballot |
| I-3 | Audit log leak | Low | Medium | Access control, encryption at rest |
| I-4 | Timing analysis of votes | Medium | Medium | Batch processing, random delays |

**Analysis:** Ballot content confidentiality is partially addressed. Full anonymity requires additional mechanisms (mixnet, shuffle) not in scope.

### 2.5 Denial of Service (Availability Loss)

| Threat ID | Threat | Likelihood | Impact | Mitigation |
|-----------|--------|------------|--------|------------|
| D-1 | Network DDoS | Medium | High | Rate limiting, CDN, ingress filtering |
| D-2 | CouchDB overload | Low | High | Horizontal scaling, load shedding |
| D-3 | Single node failure | Low | Low | Replication to remaining nodes |
| D-4 | Full cluster failure | Very Low | Critical | Offsite backup, disaster recovery |
| D-5 | Disk/memory exhaustion | Medium | High | Monitoring, auto-scaling |

**Analysis:** D-1 and D-2 are the most likely availability threats. The CouchDB cluster's replication provides resilience against node failure (D-3).

### 2.6 Elevation of Privilege (Unauthorized Access)

| Threat ID | Threat | Likelihood | Impact | Mitigation |
|-----------|--------|------------|--------|------------|
| E-1 | Voter escalates to admin | Very Low | Critical | RBAC, MFA, jump server |
| E-2 | API bug allows privilege escalation | Low | Critical | Code review, penetration testing |
| E-3 | CouchDB vulnerability allows root | Very Low | Critical | Containerization, least privilege |

**Analysis:** E-1 is mitigated by standard RBAC; E-2 requires ongoing security engineering; E-3 requires CouchDB security updates.

---

## 3. Voter-Intent Specific Threats

### 3.1 Primary Threats

| Threat | Description | Severity | Mitigation |
|--------|-------------|----------|------------|
| **Intent Drift** | Ballot modified during storage/replication | Critical | Voter intent hash + strong quorum |
| **Ghost Votes** | Ballot created without voter action | Critical | Server-side signature verification |
| **Lost Votes** | Valid ballot overwritten/lost | Critical | Write quorum + confirmation |
| **Duplicated Votes** | Same ballot recorded multiple times | Critical | Idempotency keys, sequence numbers |

### 3.2 Intent Drift Scenarios

| Scenario | Trigger | Detection | Mitigation |
|----------|---------|-----------|------------|
| Single-node corruption | Hardware error | Hash mismatch | Read quorum verification |
| Replication race | Concurrent writes | Revision conflict | Sequential consistency |
| Network partition | Split-brain | Version vector divergence | Halt writes during partition |
| Software bug | CouchDB fault | Hash mismatch | Voter receipt + audit log |

---

## 4. Risk Assessment Matrix

| | Low Impact | Medium Impact | High Impact | Critical Impact |
|---|---|---|---|---|
| **High Likelihood** | - | I-4 | D-1, D-5 | T-1, T-2 |
| **Medium Likelihood** | R-1 | I-2 | D-2 | - |
| **Low Likelihood** | R-3 | T-5, I-3 | S-1, I-1 | T-3, T-4 |
| **Very Low Likelihood** | - | - | S-2, S-3, E-2 | R-2, D-3, D-4, E-1, E-3 |

**High-priority mitigations (red cells):**
- T-1, T-2: Voter intent hash + strong quorum
- D-1, D-5: Rate limiting + monitoring

---

## 5. Mitigation Prioritization

### 5.1 Must Have (Before Deployment)

| Mitigation | Addresses | Implementation |
|------------|-----------|----------------|
| Voter intent hash verification | T-1, T-2 | Client-side hash, server-side verify |
| Write quorum (w≥2) | T-3, Lost Votes | CouchDB configuration |
| Read quorum (r≥2) | T-1 | CouchDB configuration |
| TLS 1.3 | S-3, I-1 | Load balancer termination |
| Audit log | R-2, T-4 | Append-only CouchDB DB |

### 5.2 Should Have (Before Production)

| Mitigation | Addresses | Implementation |
|------------|-----------|----------------|
| mTLS between nodes | S-2 | Internal CA |
| Rate limiting | D-1 | API gateway |
| Voter authentication | S-1 | External IDP (out of scope) |
| Monitoring and alerting | D-5, T-5 | Prometheus + Grafana |
| Disaster recovery | D-4 | Offsite backup |

### 5.3 Nice to Have (Future)

| Mitigation | Addresses | Implementation |
|------------|-----------|----------------|
| Ballot field encryption | I-1 | Client-side AES |
| Voter receipts (Ed25519) | R-1, R-3 | Digital signatures |
| Coercion resistance | I-4 | Mixnet (separate research) |

---

## 6. Verification Plan

### 6.1 Threat Mitigation Testing

| Threat | Test Method | Pass Criteria |
|--------|-------------|---------------|
| T-1 (Intent drift) | Fault injection (corrupt on write) | Drift detected, logged, halted |
| T-2 (Collision) | Adversarial hash generation | No collision found in 2^128 attempts |
| D-1 (DDoS) | Load test to failure | Graceful degradation, no data loss |
| D-3 (Node failure) | Kill one node | <1% error rate, auto-recovery |
| R-2 (Non-repudiation) | Audit log integrity check | Hash chain intact |

### 6.2 Penetration Testing (Future Work)

- Authenticated voter endpoint fuzzing
- CouchDB replication protocol testing
- TLS certificate validation bypass attempts
- Privilege escalation attempts via API

---

## 7. Limitations of This Threat Model

1. **Honest-but-crashy:** Malicious insiders within election authority not modeled
2. **Software vulnerabilities:** Zero-day exploits not predictable
3. **Physical security:** Server room access not addressed
4. **Supply chain:** CouchDB dependencies not audited
5. **Social engineering:** Voter/operator manipulation out of scope

These limitations will be documented in the paper's "Limitations" section.
