# Experiment Specification

**Document Status:** NOT EXECUTED
**Version:** 1.0
**Date:** 2026-10-05

---

## 1. Overview

This document specifies the experimental protocol for validating voter-intent analysis in electronic voting systems using CouchDB as the underlying data store. All experiments are designed for reproducibility and conservative interpretation.

---

## 2. Independent Variables

| Variable | Type | Levels | Operational Definition |
|----------|------|--------|------------------------|
| `workload_type` | Categorical | `read-heavy`, `write-heavy`, `balanced` | Ratio of read:write operations per test cycle |
| `concurrency_level` | Integer | 1, 10, 50, 100, 500 | Simultaneous client connections |
| `consistency_level` | Categorical | `eventual`, `sequential`, `strong` | CouchDB replication configuration |
| `dataset_size` | Integer | 1K, 10K, 100K, 1M | Number of ballot records |
| `network_latency_ms` | Integer | 0, 50, 150, 300 | Artificial latency injection (ms) |

---

## 3. Dependent Variables

| Variable | Unit | Measurement Method |
|----------|------|-------------------|
| `throughput_ops_sec` | operations/second |计数器均值 over 60s windows |
| `latency_p50` | milliseconds | 50th percentile response time |
| `latency_p95` | milliseconds | 95th percentile response time |
| `latency_p99` | milliseconds | 99th percentile response time |
| `error_rate` | proportion | Failed operations / total operations |
| `consistency_violation_count` | integer | Detected stale-read events |
| `recovery_time_seconds` | seconds | Time to restore n=3 quorum after failure |

---

## 4. Control Variables

The following variables are held constant or randomized and accounted for:

- **Hardware:** Identical bare-metal or VM specs across trials
- **CouchDB version:** Pinned to a single release (e.g., 3.3.x)
- **Network:** Isolated LAN segment, no external traffic
- **OS scheduling:** Tests run during low-background-activity windows
- **Warm-up period:** 120 seconds before measurement collection
- **Cool-down period:** 30 seconds between experimental conditions

---

## 5. Experiment Design

### 5.1 Full Factorial (Pilot)

For initial characterization, a full factorial design across all variable levels:

```
Total runs = 5 × 5 × 3 × 4 × 4 = 1200 runs
```

### 5.2 Fractional Factorial (Main Study)

Given resource constraints, a Resolution-V fractional factorial (1/8 fraction) is employed for the main study, balancing main effects and two-way interactions.

### 5.3 Blocking and Randomization

- **Blocking:** Runs grouped by `dataset_size` to minimize rebuild overhead
- **Randomization:** Within blocks, run order randomized via Mersenne Twister seed
- **Seed logging:** All seeds recorded for exact reproduction

---

## 6. Procedure

### 6.1 Pre-Experiment Checklist

1. Provision fresh CouchDB instance (container or bare-metal)
2. Verify disk I/O baseline (minimum: 500 MB/s read, 300 MB/s write)
3. Load seed data via `util_load` script
4. Verify replication chain: primary → replica1 → replica2
5. Confirm monitoring agents active (latency, throughput, consistency checker)

### 6.2 Per-Run Protocol

```
FOR each configuration tuple (workload, concurrency, consistency, size, latency):
    1. Apply network shaping (if latency > 0)
    2. Spawn N client goroutines/threads
    3. Execute 60-second warm-up (discard results)
    4. Execute 300-second measurement window
    5. Aggregate metrics (throughput, latency histograms, error log)
    6. Verify consistency invariants via separate checker process
    7. Log results to JSON artifact
    8. Reset state (drain connections, clear caches)
    9. Cool-down 30s
ENDFOR
```

### 6.3 Post-Experiment Verification

- Replay run seeds to confirm reproducibility (±5% tolerance on throughput)
- Cross-check aggregate metrics against per-node logs
- Validate no undetected consistency violations (full scan of version vectors)

---

## 7. Negative Control: Voter-Intent Drift

### 7.1 Rationale

Electronic voting systems must preserve **voter intent** — the correspondence between a voter's cast ballot and the recorded vote. This negative control establishes that the system does **not** introduce intent drift under normal operation.

### 7.2 Definition

**Voter-Intent Drift (VID):** A divergence between the voter's submitted ballot and the ballot record in CouchDB, caused by system operation (not voter error).

### 7.3 Operationalization

1. **Synthetic Ballot Generation:** Create ballots with cryptographically signed hashes
2. **Pre-Record Hash:** Store hash before submission
3. **Post-Record Verification:** After CouchDB write, read back and verify hash match
4. **Drift Detection:** Any hash mismatch = one VID event

### 7.4 Control Conditions

| Condition | VID Events | Interpretation |
|-----------|------------|-----------------|
| Baseline (no load) | 0 expected | System correctness baseline |
| Read-heavy load | 0 expected | Read operations cannot modify records |
| Write-heavy load | 0 expected | Correct writes preserve hash integrity |
| Network partition | TBD | Partition tolerance validation |

### 7.5 Success Criteria

The voter-intent negative control passes **if and only if** VID events = 0 across all control conditions.

---

## 8. Artifact Format

Each experimental run produces:

```json
{
  "run_id": "uuid",
  "timestamp": "ISO8601",
  "seed": "int",
  "config": {
    "workload_type": "string",
    "concurrency_level": "int",
    "consistency_level": "string",
    "dataset_size": "int",
    "network_latency_ms": "int"
  },
  "results": {
    "throughput_ops_sec": "float",
    "latency_p50_ms": "float",
    "latency_p95_ms": "float",
    "latency_p99_ms": "float",
    "error_rate": "float",
    "consistency_violation_count": "int",
    "recovery_time_seconds": "float"
  },
  "vid_control": {
    "condition": "string",
    "ballots_submitted": "int",
    "vid_events": "int",
    "pass": "boolean"
  },
  "checksums": {
    "log_archive": "sha256",
    "metrics_json": "sha256"
  }
}
```

---

## 9. Reproducibility Requirements

1. **Code:** All experiment code version-controlled with pinned dependencies
2. **Data:** Seed datasets archived with SHA-256 checksums
3. **Environment:** Docker image or environment spec (OS, kernel, CouchDB version)
4. **Seeds:** All randomization seeds logged
5. **Raw logs:** Preserved for 5 years minimum

---

## 10. Ethical Considerations

- **No real voter data:** All experiments use synthetic ballots
- **No network externalities:** Tests isolated to prevent interference
- **Resource consumption:** Cloud resources tracked for cost control
