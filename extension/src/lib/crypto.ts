// Argon2id (hash-wasm) + AES-256-GCM (WebCrypto).
// Two surfaces:
//  - Vault at-rest: {salt,nonce,ct} where ct = WebCrypto ciphertext||tag.
//  - .tmbk backup interop with the Flutter app: header JSON + '\n' + base64(cipher),
//    GCM tag stored SEPARATELY in header.mac (the `cryptography` package layout).

import { argon2id } from 'hash-wasm';

const ENC = new TextEncoder();
const DEC = new TextDecoder();

// Must match the app (passphrase_crypto.dart): 64 MiB / 3 iters / 1 lane / 32-byte key.
const MEM_KIB = 65_536;
const ITERATIONS = 3;
const PARALLELISM = 1;
const KEY_LEN = 32;
const SALT_LEN = 16;
const NONCE_LEN = 12;
const TAG_LEN = 16; // 128-bit GCM tag

export class BackupAuthError extends Error {}
export class BackupFormatError extends Error {}

function b64e(u: Uint8Array): string {
  let s = '';
  for (const b of u) s += String.fromCharCode(b);
  return btoa(s);
}
function b64d(s: string): Uint8Array {
  return Uint8Array.from(atob(s), (c) => c.charCodeAt(0));
}
function rand(n: number): Uint8Array {
  const u = new Uint8Array(n);
  crypto.getRandomValues(u);
  return u;
}

async function deriveKey(passphrase: string, salt: Uint8Array): Promise<CryptoKey> {
  const raw = await argon2id({
    password: passphrase,
    salt,
    parallelism: PARALLELISM,
    iterations: ITERATIONS,
    memorySize: MEM_KIB,
    hashLength: KEY_LEN,
    outputType: 'binary',
  });
  return crypto.subtle.importKey('raw', raw, 'AES-GCM', false, ['encrypt', 'decrypt']);
}

// ---- Vault at-rest (chrome.storage) ----

export interface VaultBlob {
  v: 1;
  salt: string;
  nonce: string;
  ct: string; // ciphertext||tag (WebCrypto layout)
}

export async function encryptVault(passphrase: string, plaintext: string): Promise<VaultBlob> {
  const salt = rand(SALT_LEN);
  const nonce = rand(NONCE_LEN);
  const key = await deriveKey(passphrase, salt);
  const ct = new Uint8Array(
    await crypto.subtle.encrypt({ name: 'AES-GCM', iv: nonce }, key, ENC.encode(plaintext)),
  );
  return { v: 1, salt: b64e(salt), nonce: b64e(nonce), ct: b64e(ct) };
}

export async function decryptVault(passphrase: string, blob: VaultBlob): Promise<string> {
  const key = await deriveKey(passphrase, b64d(blob.salt));
  try {
    const pt = await crypto.subtle.decrypt(
      { name: 'AES-GCM', iv: b64d(blob.nonce) },
      key,
      b64d(blob.ct),
    );
    return DEC.decode(pt);
  } catch {
    throw new BackupAuthError('wrong passphrase');
  }
}

// ---- .tmbk backup interop with the Flutter app ----

export async function exportTmbk(passphrase: string, plaintext: string): Promise<Uint8Array> {
  const salt = rand(SALT_LEN);
  const nonce = rand(NONCE_LEN);
  const key = await deriveKey(passphrase, salt);
  const combined = new Uint8Array(
    await crypto.subtle.encrypt({ name: 'AES-GCM', iv: nonce }, key, ENC.encode(plaintext)),
  );
  const cipher = combined.slice(0, combined.length - TAG_LEN);
  const mac = combined.slice(combined.length - TAG_LEN);
  const header = {
    magic: 'TokenManagerBackup',
    version: 1,
    kdf: 'argon2id',
    params: { memKiB: MEM_KIB, iter: ITERATIONS, par: PARALLELISM },
    salt: b64e(salt),
    nonce: b64e(nonce),
    mac: b64e(mac),
  };
  return ENC.encode(`${JSON.stringify(header)}\n${b64e(cipher)}`);
}

export async function importTmbk(passphrase: string, file: Uint8Array): Promise<string> {
  const text = DEC.decode(file);
  const nl = text.indexOf('\n');
  if (nl < 0) throw new BackupFormatError('missing header');
  let header: { magic?: string; version?: number; salt?: string; nonce?: string; mac?: string };
  try {
    header = JSON.parse(text.slice(0, nl));
  } catch {
    throw new BackupFormatError('invalid header');
  }
  if (header.magic !== 'TokenManagerBackup') throw new BackupFormatError('not a TokenManager backup');
  if (header.version !== 1) throw new BackupFormatError(`unsupported version ${header.version}`);

  const salt = b64d(header.salt!);
  const nonce = b64d(header.nonce!);
  const mac = b64d(header.mac!);
  const cipher = b64d(text.slice(nl + 1).trim());
  const combined = new Uint8Array(cipher.length + mac.length);
  combined.set(cipher, 0);
  combined.set(mac, cipher.length);

  const key = await deriveKey(passphrase, salt);
  try {
    const pt = await crypto.subtle.decrypt({ name: 'AES-GCM', iv: nonce }, key, combined);
    return DEC.decode(pt);
  } catch {
    throw new BackupAuthError('wrong passphrase or corrupted backup');
  }
}
