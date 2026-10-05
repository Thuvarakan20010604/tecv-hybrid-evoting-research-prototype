import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'node:crypto';
import type { EncryptedBallot } from '../../shared/src/types.js';

export function canonicalize(value: unknown): string {
  if (value === null || typeof value !== 'object') return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(canonicalize).join(',')}]`;
  const object = value as Record<string, unknown>;
  return `{${Object.keys(object).sort().map(k => `${JSON.stringify(k)}:${canonicalize(object[k])}`).join(',')}}`;
}
export function sha256(value: string | Buffer): string { return createHash('sha256').update(value).digest('hex'); }
export function voteHash(ballot: EncryptedBallot): string { return sha256(canonicalize(ballot)); }
export function encryptBallot(candidate: string, key: Buffer, iv = randomBytes(12)): EncryptedBallot {
  if (key.length !== 32) throw new Error('ERR_INVALID_KEY_LENGTH');
  const cipher = createCipheriv('aes-256-gcm', key, iv);
  const ciphertext = Buffer.concat([cipher.update(JSON.stringify({ candidate }), 'utf8'), cipher.final()]);
  return { algorithm: 'AES-256-GCM', iv: iv.toString('base64'), ciphertext: ciphertext.toString('base64'), authTag: cipher.getAuthTag().toString('base64') };
}
export function decryptBallot(ballot: EncryptedBallot, key: Buffer): string {
  if (key.length !== 32) throw new Error('ERR_INVALID_KEY_LENGTH');
  const decipher = createDecipheriv('aes-256-gcm', key, Buffer.from(ballot.iv, 'base64'));
  decipher.setAuthTag(Buffer.from(ballot.authTag, 'base64'));
  const plaintext = Buffer.concat([decipher.update(Buffer.from(ballot.ciphertext, 'base64')), decipher.final()]);
  const parsed = JSON.parse(plaintext.toString('utf8')) as {candidate?: unknown};
  if (typeof parsed.candidate !== 'string') throw new Error('ERR_INVALID_BALLOT');
  return parsed.candidate;
}
export function resultHash(value: unknown): string { return sha256(canonicalize(value)); }
