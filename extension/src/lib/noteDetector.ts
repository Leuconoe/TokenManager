// Non-blocking token-pattern warning, mirrors the app's NoteTokenDetector.

const PREFIXES: RegExp[] = [
  /gh[posru]_[A-Za-z0-9]{20,}/,
  /github_pat_[A-Za-z0-9_]{20,}/,
  /sk-[A-Za-z0-9]{20,}/,
  /xox[baprs]-[A-Za-z0-9-]{10,}/,
  /AKIA[0-9A-Z]{16}/,
  /AIza[0-9A-Za-z\-_]{35}/,
  /eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}/,
];

const CONTIGUOUS = /[A-Za-z0-9+/=_-]{32,}/g;

export function looksLikeToken(note: string): boolean {
  if (!note) return false;
  if (PREFIXES.some((re) => re.test(note))) return true;
  for (const m of note.matchAll(CONTIGUOUS)) {
    if (shannonEntropy(m[0]) >= 3.5) return true;
  }
  return false;
}

function shannonEntropy(s: string): number {
  const counts: Record<string, number> = {};
  for (const c of s) counts[c] = (counts[c] ?? 0) + 1;
  const n = s.length;
  let e = 0;
  for (const c of Object.values(counts)) {
    const p = c / n;
    e -= p * Math.log2(p);
  }
  return e;
}
