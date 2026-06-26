<script lang="ts">
  import type { TokenEntry } from '../lib/domain';
  import { BackupAuthError, BackupFormatError, exportTmbk, importTmbk } from '../lib/crypto';
  import { t } from '../lib/i18n.svelte';

  let { entries, onImported }: {
    entries: TokenEntry[];
    pass: string;
    onImported: (next: TokenEntry[]) => Promise<void>;
  } = $props();

  let bpass = $state('');
  let mode = $state<'merge' | 'overwrite'>('merge');
  let msg = $state('');
  let err = $state('');
  let fileInput: HTMLInputElement;

  // Compares the meaningful fields (ignores id/timestamps).
  function sameData(a: TokenEntry, b: TokenEntry): boolean {
    return a.url === b.url &&
      a.issuedAt === b.issuedAt &&
      a.expiresAt === b.expiresAt &&
      a.note === b.note;
  }

  function fileName(): string {
    const d = new Date();
    const ymd = `${d.getFullYear()}${String(d.getMonth() + 1).padStart(2, '0')}${String(d.getDate()).padStart(2, '0')}`;
    return `tokenmanager-backup-${ymd}.tmbk`;
  }

  async function doExport() {
    err = ''; msg = '';
    if (bpass.length < 8) { err = t('pwTooShort'); return; }
    const blob = new Blob([await exportTmbk(bpass, JSON.stringify(entries))], { type: 'application/octet-stream' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = fileName();
    a.click();
    URL.revokeObjectURL(a.href);
    msg = t('exported');
  }

  async function doImport(ev: Event) {
    err = ''; msg = '';
    const f = (ev.target as HTMLInputElement).files?.[0];
    if (!f) return;
    if (bpass.length < 8) { err = t('pwTooShort'); return; }
    try {
      const bytes = new Uint8Array(await f.arrayBuffer());
      const json = await importTmbk(bpass, bytes);
      const incoming = JSON.parse(json) as TokenEntry[];
      let next: TokenEntry[];
      if (mode === 'overwrite') {
        next = incoming;
      } else {
        // Merge keyed by serviceName (title). On a real difference, let the
        // user choose local vs imported (e.g. local has expiry, imported none).
        const byTitle = new Map(entries.map((e) => [e.serviceName, e]));
        for (const inc of incoming) {
          const local = byTitle.get(inc.serviceName);
          if (!local) {
            byTitle.set(inc.serviceName, inc);
          } else if (!sameData(local, inc)) {
            const useImported = confirm(t('mergeConflict', { name: inc.serviceName }));
            // keep title unique: overwrite the local row in place when imported wins
            byTitle.set(inc.serviceName, useImported ? { ...inc, id: local.id } : local);
          }
        }
        next = [...byTitle.values()];
      }
      await onImported(next);
      msg = t('restored', { count: incoming.length });
    } catch (e) {
      if (e instanceof BackupAuthError) err = t('authErr');
      else if (e instanceof BackupFormatError) err = t('fmtErr');
      else err = `${e}`;
    } finally {
      fileInput.value = '';
    }
  }
</script>

<p class="sub">{t('backupInfo')}</p>

<label>{t('passLabel')}</label>
<input type="password" bind:value={bpass} placeholder={t('passShared')} />

<div style="margin-top:14px"><b style="font-size:13px">{t('exportSection')}</b></div>
<button style="width:100%;margin-top:6px" onclick={doExport}>{t('exportBtn')}</button>

<div style="margin-top:16px"><b style="font-size:13px">{t('restoreSection')}</b></div>
<div class="row" style="margin-top:6px">
  <label style="margin:0"><input type="radio" style="width:auto" bind:group={mode} value="merge" /> {t('merge')}</label>
  <label style="margin:0"><input type="radio" style="width:auto" bind:group={mode} value="overwrite" /> {t('overwrite')}</label>
</div>
<input bind:this={fileInput} type="file" accept=".tmbk,application/octet-stream" onchange={doImport} style="margin-top:8px;border:none;padding:0" />

{#if msg}<div class="ok">{msg}</div>{/if}
{#if err}<div class="err">{err}</div>{/if}

<div class="banner" style="margin-top:16px">{t('shareWarn')}</div>
