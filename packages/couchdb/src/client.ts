import type { VoteDoc, VoterDoc } from '../../shared/src/types.js';
export class CouchClient {
  constructor(readonly baseUrl:string, readonly user:string, readonly password:string){}
  private auth(){return `Basic ${Buffer.from(`${this.user}:${this.password}`).toString('base64')}`}
  async request<T>(path:string, init:RequestInit={}):Promise<T>{ const r=await fetch(`${this.baseUrl}${path}`,{...init,headers:{authorization:this.auth(),'content-type':'application/json',...(init.headers||{})}}); const text=await r.text(); const body=text?JSON.parse(text):{}; if(!r.ok){const e=new Error(body.reason||body.error||`HTTP_${r.status}`); (e as any).status=r.status;(e as any).body=body;throw e} return body as T }
  async ensureDatabase(name:string){try{await this.request(`/${name}`,{method:'PUT'})}catch(e){if((e as any).status!==412)throw e} await this.request(`/${name}/_security`,{method:'PUT',body:JSON.stringify({admins:{names:[this.user],roles:[]},members:{names:[this.user],roles:[]}})})}
  async resetDatabase(name:string){try{await this.request(`/${name}`,{method:'DELETE'})}catch(e){if((e as any).status!==404)throw e} await this.ensureDatabase(name)}
  async get<T>(db:string,id:string):Promise<T|null>{try{return await this.request<T>(`/${db}/${encodeURIComponent(id)}`)}catch(e){if((e as any).status===404)return null;throw e}}
  async put<T extends {_id:string;_rev?:string}>(db:string,doc:T):Promise<T>{const r=await this.request<{rev:string}>(`/${db}/${encodeURIComponent(doc._id)}`,{method:'PUT',body:JSON.stringify(doc)});return {...doc,_rev:r.rev}}
  async bulk<T extends {_id:string}>(db:string,docs:T[]){return this.request<Array<{id:string;rev?:string;error?:string}>>(`/${db}/_bulk_docs`,{method:'POST',body:JSON.stringify({docs})})}
  async delete(db:string,id:string,rev:string){return this.request(`/${db}/${encodeURIComponent(id)}?rev=${encodeURIComponent(rev)}`,{method:'DELETE'})}
  async all<T>(db:string):Promise<T[]>{const r=await this.request<{rows:Array<{doc:T}>}>(`/${db}/_all_docs?include_docs=true`);return r.rows.map(x=>x.doc).filter(Boolean)}
  voters(){return {get:(id:string)=>this.get<VoterDoc>('voters_db',id),put:(d:VoterDoc)=>this.put('voters_db',d),all:()=>this.all<VoterDoc>('voters_db')}}
  votes(){return {get:(id:string)=>this.get<VoteDoc>('votes_db',id),put:(d:VoteDoc)=>this.put('votes_db',d),all:()=>this.all<VoteDoc>('votes_db'),delete:(id:string,rev:string)=>this.delete('votes_db',id,rev)}}
}
