export type Candidate = 'Candidate A' | 'Candidate B' | 'Candidate C' | 'Candidate D';
export const CANDIDATES: Candidate[] = ['Candidate A', 'Candidate B', 'Candidate C', 'Candidate D'];

export interface EncryptedBallot { algorithm: 'AES-256-GCM'; iv: string; ciphertext: string; authTag: string }
export interface VoterDoc { _id: string; _rev?: string; voterId: string; nic: string; district: string; biometricRef: string; isVoted: boolean; voteDocId?: string; voteState?: 'AUTHORIZED_TO_VOTE'|'PENDING_PROOF'|'VOTE_COMPLETE' }
export interface VoteDoc { _id: string; _rev?: string; voteDocId: string; encryptedBallot: EncryptedBallot; district: string; electionId: string; timestamp: string }
export interface VoteProof { voteDocId: string; voteDocRev: string; voteHash: string; district: string; electionId: string; timestamp: string; transactionId?: string }
export interface ResultProof { resultId: string; electionId: string; district: string; candidateTotals: Record<string, number>; validVoteCount: number; invalidVoteCount: number; resultHash: string; timestamp: string; transactionId?: string }
export type TecvClassification = 'VALID'|'MISSING_VOTE'|'REVISION_MISMATCH'|'HASH_MISMATCH'|'UNPROVEN_DB_RECORD';
export interface TecvAnomaly { voteDocId: string; classification: TecvClassification; expectedRev?: string; actualRev?: string; expectedHash?: string; actualHash?: string }
export interface AuditResult { auditRunId: string; electionId: string; district: string; startedAt: string; completedAt: string; totalLedgerProofs: number; totalDatabaseVotes: number; validVotes: number; invalidVotes: number; missingVotes: number; revisionMismatches: number; hashMismatches: number; unprovenDatabaseRecords: number; validVoteDocIds: string[]; anomalies: TecvAnomaly[]; auditResultHash: string }
export interface OperationMetric { runId: string; operation: string; startedAt: string; durationMs: number; status: 'SUCCESS'|'FAILURE'; errorCode?: string; voteDocId?: string; configuration?: Record<string, unknown> }
