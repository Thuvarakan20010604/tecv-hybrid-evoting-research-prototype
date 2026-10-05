# CouchDB Design Rationale

CouchDB is the prototype operational database because its JSON document model fits voter and encrypted-ballot records, and its MVCC `_rev` token provides observable revision state for concurrency control and TECV comparison. Keeping ciphertexts and mutable voter state off-chain avoids replicating operational ballot payloads throughout ledger history. Direct database access also permits controlled modification, deletion, and fabrication experiments. CouchDB replication and backups could support future recovery research.

The application databases `voters_db` and `votes_db` are separate from Fabric peer world state. The executed Fabric network used its embedded state database.

## Limitations

- `_rev` is not a cryptographic proof; its evidential value comes from anchoring the observed revision with an immutable ledger proof.
- CouchDB alone does not guarantee election integrity and is not claimed to be inherently more secure than alternatives.
- The study does not establish universal performance superiority.
- Fabric private-data collections and other operational databases are viable alternatives.
- Exact revision restoration after deletion was not tested.
