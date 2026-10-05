# Contribution Statement

The contribution is not the individual use of CouchDB, blockchain, AES, SHA-256, or smart contracts, and no claim of a new cryptographic primitive or “first-ever” system is made. The prototype evaluates a revision-aware off-chain/on-chain workflow in which an encrypted operational ballot record is bound to immutable ledger evidence through document identity, CouchDB revision state, and a canonical ciphertext hash, and is subjected to deterministic TECV before it can influence the tally.

The evaluated workflow adds:

1. ledger-to-database existence, `_rev`, and ciphertext-hash validation;
2. database-to-ledger scanning for unproven records;
3. a verified-only decryption and tally gate;
4. independently reproducible audit hashes;
5. explicit negative-control evidence that voter-intent verification remains outside TECV.

Executed evidence is limited to the local synthetic environment described in the methodology. It does not establish national-scale performance, complete voting security, or production readiness.
