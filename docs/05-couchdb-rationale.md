# CouchDB Rationale

**Document Status:** NOT EXECUTED
**Version:** 1.0
**Date:** 2026-10-05

---

## 1. Selection Criteria

CouchDB was selected from a candidate pool of distributed databases based on the following weighted criteria:

| Criterion | Weight | Rationale |
|-----------|--------|-----------|
| Replication model | 30% | Masterless preferred; must handle node failure |
| Consistency configuration | 25% | Tunable from eventual to strong |
| Conflict resolution | 15% | Built-in revision trees |
| Auditability | 15% | Append-only friendly, revisions as audit trail |
| Operational simplicity | 10% | Mature, well-documented |
| Language ecosystem | 5% | Go/JavaScript client availability |

---

## 2. Candidate Comparison

### 2.1 CouchDB vs. Alternatives

| Feature | CouchDB | PostgreSQL HA | etcd | MongoDB | Cassandra |
|---------|---------|---------------|------|---------|-----------|
| Replication model | Masterless | Primary-replica | Raft-based | Replica sets | Gossip |
| Tunable consistency | Yes (r/w quorum) | Limited | No | Yes (read preference) | Yes |
| Conflict detection | Built-in | Manual | N/A | Built-in | Last-write-wins |
| Offline-first | Excellent | Poor | Poor | Moderate | Moderate |
| Append-only audit | Good | Requires config | No | No | No |
| HTTP API | Native | No | gRPC | Wire protocol | CQL |
| Offline replication | Yes | No | No | Limited | No |

### 2.2 Why CouchDB Over Others

#### CouchDB vs. PostgreSQL HA

- **Advantage CouchDB:** Built-in multi-master replication without configuration
- **Advantage PostgreSQL:** Stronger transactional guarantees, mature ecosystem
- **Decision:** CouchDB's replication model maps directly to our partition-tolerance requirements; PostgreSQL's streaming replication requires careful failover configuration

#### CouchDB vs. etcd

- **Advantage etcd:** Strong consistency via Raft, excellent for coordination
- **Advantage CouchDB:** Schema flexibility, HTTP API, conflict resolution
- **Decision:** etcd is optimized for small metadata; we require document-scale ballot storage

#### CouchDB vs. MongoDB

- **Advantage MongoDB:** Better write throughput, richer query language
- **Advantage CouchDB:** Native conflict resolution, masterless operation
- **Decision:** CouchDB's revision trees provide native conflict visibility needed for voter-intent verification

#### CouchDB vs. Cassandra

- **Advantage Cassandra:** Higher write throughput, geo-distribution
- **Advantage CouchDB:** Tunable read consistency, native document model
- **Decision:** Cassandra defaults to eventual consistency; our voter-intent requirement needs configurable strong reads

---

## 3. CAP Theorem Implications

### 3.1 CouchDB's Position

CouchDB occupies a **configurable position** on the CAP triangle:

```
           Consistency
              ▲
              │
              │
    ┌─────────┴─────────┐
    │                   │
    │   COUCHDB         │
    │   (configurable)  │
    │                   │
    │                   │
Availability────────────►
```

By adjusting `r` (read quorum) and `w` (write quorum), we select:

| Configuration | C | A | P |
|---------------|---|---|---|
| r=1, w=1 (default) | Eventual | High | Yes |
| r=2, w=2 | Sequential | Moderate | Yes |
| r=3, w=3 | Strong | Lower | Yes |
| r=1, w=3 | Strong | Lower | Yes |
| r=3, w=1 | Eventual | High | Yes |

### 3.2 Suitability for Voter-Intent

For voter-intent preservation, we require:

1. **No lost writes:** w ≥ 2 (majority quorum)
2. **No stale reads:** r ≥ 2 (majority quorum)
3. **Conflict visibility:** Revision trees must be readable

CouchDB satisfies all three with `r=2, w=2` configuration.

---

## 4. CouchDB Strengths for This Use Case

### 4.1 Masterless Replication

- **Benefit:** No single point of failure; any node can accept writes
- **Election analogy:** Ballot boxes at each precinct remain functional even if central server is unreachable
- **Trade-off:** Slightly higher latency for quorum operations

### 4.2 Revision Trees

- **Benefit:** Full history of document changes, native conflict detection
- **Election analogy:** Paper audit trail of ballot modifications (if any)
- **Trade-off:** Storage overhead for revision history

### 4.3 HTTP API

- **Benefit:** Language-agnostic, firewall-friendly, easy debugging
- **Election analogy:** Standardized protocol for ballot submission
- **Trade-off:** JSON overhead vs. binary protocols

### 4.4 Offline-First Architecture

- **Benefit:** Nodes can sync when connectivity is restored
- **Election analogy:** Voting machines at rural precincts with intermittent connectivity
- **Trade-off:** Eventual consistency during partition

---

## 5. CouchDB Weaknesses and Mitigations

### 5.1 Weaknesses Identified

| Weakness | Impact | Mitigation |
|----------|--------|------------|
| No built-in authentication | Security risk | Reverse proxy with OAuth2/JWT |
| No field-level encryption | PII exposure | Client-side encryption before submission |
| Manual conflict resolution | Operational burden | Automated resolution for simple cases; flag complex ones |
| Memory pressure with large dbs | Performance | Proper sharding, document size limits |
| Compaction required | Operational overhead | Scheduled compaction jobs |

### 5.2 Operational Mitigations

1. **Authentication:** CouchDB's `/_session` API combined with reverse proxy (nginx/Caddy)
2. **Authorization:** Per-database roles via CouchDB's internal auth DB
3. **Encryption:** Field-level AES-256 encryption in application layer
4. **Monitoring:** Prometheus exporter for CouchDB metrics (`couchdb_exporter`)

---

## 6. Version Selection

| Version | Status | Recommendation |
|---------|--------|----------------|
| 3.3.x | LTS | **Recommended for production** |
| 3.2.x | LTS | Acceptable if 3.3 unavailable |
| 2.x | EOL | Do not use |

**Rationale:** CouchDB 3.x introduces improved clustering, better memory management, and security enhancements. Version 3.3.x is the current LTS with expected support until 2028.

---

## 7. Alternative Considered: PouchDB

PouchDB is CouchDB's browser/Node.js counterpart with the same replication protocol. It was considered but rejected for the server-side storage layer:

- **PouchDB:** Good for offline-first client apps, not suitable as primary data store
- **CouchDB:** Server-side authoritative storage with full replication support

**Conclusion:** Use PouchDB on clients (if needed) syncing to CouchDB server-side.

---

## 8. Conclusion

CouchDB is selected for this research because:

1. It provides the **configurable consistency** required to study CAP trade-offs empirically
2. Its **masterless replication** eliminates single points of failure
3. Its **revision trees** provide native conflict detection for voter-intent verification
4. Its **HTTP API** enables simple integration and debugging
5. It has a **mature, stable** release suitable for long-term research

The empirical study in this research will validate whether these theoretical advantages translate to practical voter-intent preservation under load.
