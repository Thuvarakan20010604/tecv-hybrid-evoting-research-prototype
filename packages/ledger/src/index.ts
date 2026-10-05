import { randomUUID } from 'node:crypto';
import type { ResultProof, VoteProof } from '../../shared/src/types.js';
export interface Ledger { submitVoteProof(proof: VoteProof, identity: string): Promise<VoteProof>; getVoteProof(id: string): Promise<VoteProof|null>; getVoteProofsByElection(electionId: string): Promise<VoteProof[]>; submitResultProof(proof: ResultProof, identity: string): Promise<ResultProof>; getResultProof(id: string): Promise<ResultProof|null> }
export class MemoryLedger implements Ledger {
  private votes = new Map<string, VoteProof>(); private results = new Map<string, ResultProof>();
  constructor(private electionId: string, private district: string) {}
  async submitVoteProof(p: VoteProof, identity: string) { if(identity!=='vote-submitter') throw new Error('ERR_UNAUTHORIZED'); for(const k of ['voteDocId','voteDocRev','voteHash','district','electionId','timestamp'] as const) if(!p[k]) throw new Error('ERR_MISSING_FIELD'); if(p.electionId!==this.electionId) throw new Error('ERR_INVALID_ELECTION'); if(p.district!==this.district) throw new Error('ERR_INVALID_DISTRICT'); if(this.votes.has(p.voteDocId)) throw new Error('ERR_DUPLICATE_PROOF'); const out={...p,transactionId:randomUUID()}; this.votes.set(p.voteDocId,out); return out; }
  async getVoteProof(id:string){return this.votes.get(id)??null}
  async getVoteProofsByElection(id:string){return [...this.votes.values()].filter(p=>p.electionId===id).sort((a,b)=>a.voteDocId.localeCompare(b.voteDocId))}
  async submitResultProof(p:ResultProof,identity:string){if(identity!=='result-submitter') throw new Error('ERR_UNAUTHORIZED'); if(this.results.has(p.resultId)) throw new Error('ERR_DUPLICATE_RESULT'); const out={...p,transactionId:randomUUID()}; this.results.set(p.resultId,out); return out}
  async getResultProof(id:string){return this.results.get(id)??null}
}
