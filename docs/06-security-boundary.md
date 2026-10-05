# Security Boundary Definition

**Document Status:** NOT EXECUTED
**Version:** 1.0
**Date:** 2026-10-05

---

## 1. Trust Model

### 1.1 Trusted Components

| Component | Trust Level | Justification |
|-----------|-------------|---------------|
| CouchDB nodes | Trusted | Operated by election authority |
| Ballot Recording Service | Trusted | Operated by election authority |
| Network (intra-cluster) | Trusted | Isolated LAN segment |
| Client applications | Untrusted | Voter devices, no control |
| Network (client-to-server) | Untrusted | Public internet |

### 1.2 Threat Actors

| Actor | Capability | Intent | Mitigation |
|-------|-----------|--------|------------|
| External attacker | Network access | Disrupt availability | Firewall, rate limiting |
| Malicious voter | Client device | Double vote | Server-side validation |
| Curious admin | CouchDB admin access | Data exfiltration | Principle of least privilege |
| CouchDB bug | Software vulnerability | Data corruption | Version pinning, monitoring |
| Hardware failure | Node loss | Data unavailability | Replication, backups |

### 1.3 Adversarial Assumptions

This research assumes the **honest-but-crashy** failure model:

- CouchDB nodes execute the protocol correctly
- Nodes may fail (crash, network partition) but do not exhibit Byzantine behavior
- A Byzantine-tolerant voter-intent system is **out of scope** (see Section 5.2)

---

## 2. Security Boundaries

### 2.1 Network Topology

```
┌────────────────────────────────────────────────────────────────┐
│                     TRUSTED ZONE (Election Authority)          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     Load Balancer                         │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐                   │  │
│  │  │ TLS     │  │ TLS     │  │ TLS     │                   │  │
│  │  │ Term.   │  │ Term.   │  │ Term.   │                   │  │
│  │  └─────────┘  └─────────┘  └─────────┘                   │  │
│  │        │           │           │                         │  │
│  │        └───────────┼───────────┘                         │  │
│  │                    ▼                                      │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │           Ballot Recording Service                  │  │  │
│  │  │  ┌───────────┐  ┌───────────┐  ┌───────────┐      │  │  │
│  │  │  │ Node A    │◄─►│ Node B    │◄─►│ Node C    │      │  │  │
│  │  │  │ 10.0.1.10 │  │ 10.0.1.11 │  │ 10.0.1.12 │      │  │  │
│  │  │  └───────────┘  └───────────┘  └───────────┘      │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ TLS 1.3 (mTLS)
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                    UNTRUSTED ZONE                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │ Voter App   │  │ Voter App   │  │ Voter App   │  ...       │
│  │ (Untrusted) │  │ (Untrusted) │  │ (Untrusted) │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└────────────────────────────────────────────────────────────────┘
```

### 2.2 Boundary Definitions

| Boundary | Description | Enforced By |
|----------|-------------|-------------|
| A → B | Voter app to Load Balancer | TLS 1.3, certificate validation |
| B → C | Load Balancer to API | Internal network ACL |
| C → D | API to CouchDB (intra-cluster) | mTLS, internal IP allowlist |
| D ↔ D | CouchDB inter-node replication | mTLS, internal network only |

### 2.3 Data Flow Security

```
Voter App                    System                     CouchDB
   │                           │                           │
   │──── 1. Request ballot ────►│                           │
   │                           │──── 2. Fetch template ────►│
   │                           │◄─── 3. Template ───────────│
   │◄── 4. Ballot form ────────│                           │
   │                           │                           │
   │ 5. Fill ballot            │                           │
   │ 6. Sign with voter key    │                           │
   │                           │                           │
   │──── 7. Submit (TLS) ───────►│                           │
   │                           │──── 8. Verify signature ──►│
   │                           │──── 9. Hash + write ──────►│
   │                           │◄─── 10. Confirm (quorum) ──│
   │◄── 11. Receipt (signed) ───│                           │
```

---

## 3. Security Controls

### 3.1 Authentication

| Layer | Mechanism | Implementation |
|-------|-----------|----------------|
| Voter to system | Short-lived JWT | Signed by election authority, 15-minute expiry |
| System to CouchDB | mTLS | Mutual certificate validation |
| Admin access | LDAP + MFA | Jump server required |

### 3.2 Authorization

- **Voters:** Write-only access to ballot submission endpoint
- **Auditors:** Read-only access to certified ballot records
- **Admins:** Full access to system configuration (logged)

### 3.3 Encryption

| Data State | Algorithm | Key Management |
|------------|-----------|-----------------|
| In transit | TLS 1.3 | Let's Encrypt (voter-facing), Internal CA (cluster) |
| At rest (OS) | LUKS/dm-crypt | Key stored in HSM |
| At rest (CouchDB) | AES-256 (optional) | Application-level, key in vault |
| Ballot content | Field-level AES | Voter-generated key (secret sharing) |

### 3.4 Integrity

- **Ballot hashes:** SHA-256 (voter intent)
- **Document signatures:** Ed25519 (optional enhancement)
- **Audit logs:** Append-only CouchDB DB, SHA-256 chain

---

## 4. Incident Response

### 4.1 Detection

| Incident | Detection Method | Alert |
|----------|-----------------|-------|
| Voter-intent drift | Hash verification | P0 alert |
| Unauthorized access | Log anomaly detection | Security alert |
| Node failure | Health check | Infrastructure alert |
| High error rate | Metric threshold | Operations alert |

### 4.2 Response Procedures

**Voter-Intent Drift Detected (P0):**
1. Immediately halt ballot acceptance
2. Identify affected ballot IDs
3. Compare with backup (paper trail or parallel system)
4. Reconstruct affected ballots from audit logs
5. Resume only after root cause identified and fixed

**Node Failure:**
1. Load balancer reroutes traffic
2. Remaining nodes continue operation
3. Failed node recovers via standard replication
4. No voter impact (zero downtime)

---

## 5. Out-of-Scope and Limitations

### 5.1 Out-of-Scope

| Item | Reason |
|------|--------|
| Byzantine fault tolerance | Requires >3n+1 nodes, not in design |
| End-to-end voter authentication | Requires separate identity system |
| Ballot secrecy (anonymity) | Requires shuffle or mixnet (separate research) |
| Jurisdictional compliance | Jurisdiction-specific (e.g., VVSG, EAC) |

### 5.2 Known Limitations

1. **Single authority:** System assumes trusted election authority
2. **No coercion resistance:** Voter cannot verify their vote was counted without receipt
3. **Key management:** Voter key generation/out-of-band verification not addressed
4. **Denial of service:** System vulnerable to availability attacks (rate limiting mitigates only)

---

## 6. Compliance Considerations

This system, if deployed for real elections, would need to address:

| Standard | Requirement | Current Status |
|----------|-------------|----------------|
| VVSG 2.0 | Voter-verified paper audit trail | Not implemented (out of scope) |
| EAC Certification | Testing and certification | Not pursued (research only) |
| GDPR | Voter data protection | Voter PII not stored |
| CCPA | California privacy law | Voter PII not stored |
| SOC 2 | Security controls | Not audited |

**Note:** This is a research prototype. Production deployment requires full compliance review.

---

## 7. Summary

The security boundary is defined as:

1. **Trusted zone:** Election authority infrastructure (CouchDB cluster, API servers)
2. **Untrusted zone:** Voter devices, public network
3. **Boundary enforcement:** TLS/mTLS, JWT authentication, network segmentation
4. **Out of scope:** Byzantine fault tolerance, ballot anonymity, voter identity verification

This boundary definition constrains the threat model in `07-threats.md` and the claims taxonomy in `08-claims-taxonomy.md`.
