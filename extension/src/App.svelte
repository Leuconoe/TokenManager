<script lang="ts">
  import { onMount } from 'svelte';
  import { save, unlock, vaultExists } from './lib/vault';
  import { getExpiryLead, getSyncPassphrase, setSyncLast } from './lib/settings';
  import { activeEntries, type TokenEntry } from './lib/domain';
  import { isConnected } from './lib/drive';
  import { syncNow } from './lib/sync';
  import { t } from './lib/i18n.svelte';
  import TokenList from './components/TokenList.svelte';
  import TokenEdit from './components/TokenEdit.svelte';
  import Backup from './components/Backup.svelte';
  import Settings from './components/Settings.svelte';

  let locked = $state(true);
  let hasVault = $state(false);
  let pass = $state(''); // session passphrase — memory only, never persisted
  let entries = $state<TokenEntry[]>([]);
  let view = $state<'list' | 'edit' | 'backup' | 'settings'>('list');
  let editing = $state<TokenEntry | null>(null);
  let pwInput = $state('');
  let err = $state('');
  let busy = $state(false);
  let leadDays = $state(14);

  onMount(async () => {
    hasVault = await vaultExists();
    leadDays = parseInt(await getExpiryLead(), 10);
  });

  async function refreshLead() {
    leadDays = parseInt(await getExpiryLead(), 10);
  }

  async function doUnlock() {
    err = '';
    if (pwInput.length < 8) {
      err = t('pwTooShort');
      return;
    }
    busy = true;
    try {
      entries = await unlock(pwInput);
      pass = pwInput;
      pwInput = '';
      locked = false;
      if (!hasVault) await save(pass, entries);
      // Quiet pull/merge/push on unlock (non-interactive; ignore failures).
      void quietSync();
    } catch {
      err = t('pwWrong');
    } finally {
      busy = false;
    }
  }

  /** Full sync cycle: pull → merge → persist locally → push. Returns the live
   *  count, or an error tag. interactive=true may show the Google consent UI. */
  async function runSync(interactive: boolean): Promise<{ merged?: number; error?: string }> {
    const syncPass = await getSyncPassphrase();
    if (!syncPass) return { error: 'needPass' };
    try {
      const merged = await syncNow(syncPass, entries, interactive);
      await persist(merged);
      await setSyncLast(Date.now());
      return { merged: activeEntries(merged).length };
    } catch (e) {
      const err = e as Error;
      return { error: `${err?.name ?? 'error'}: ${err?.message ?? ''}` };
    }
  }

  async function quietSync() {
    try {
      if ((await isConnected()) && (await getSyncPassphrase())) await runSync(false);
    } catch {
      /* best effort */
    }
  }

  let syncingMain = $state(false);
  let syncMainMsg = $state('');
  async function doMainSync() {
    if (syncingMain) return;
    syncingMain = true;
    syncMainMsg = t('syncing');
    const r = await runSync(false);
    if (r.error === 'needPass') syncMainMsg = t('syncNeedSetup');
    else if (r.error?.includes('BackupAuthError')) syncMainMsg = t('syncPassMismatch');
    else if (r.error) syncMainMsg = `${t('syncFailed')} [${r.error}]`;
    else syncMainMsg = t('syncDone', { count: r.merged ?? 0 });
    syncingMain = false;
    setTimeout(() => (syncMainMsg = ''), 4000);
  }

  async function persist(next: TokenEntry[]) {
    entries = next;
    await save(pass, entries);
  }

  async function onSave(entry: TokenEntry) {
    const i = entries.findIndex((e) => e.id === entry.id);
    // Monotonic updatedAt: an edit must beat the version it edits, even if that
    // version carries a future timestamp from a clock-skewed device.
    const saved =
      i >= 0 ? { ...entry, updatedAt: Math.max(entry.updatedAt, entries[i].updatedAt + 1) } : entry;
    const next = i >= 0 ? entries.map((e) => (e.id === entry.id ? saved : e)) : [...entries, saved];
    await persist(next);
    view = 'list';
  }
  async function onDelete(id: string) {
    // Soft delete (tombstone). updatedAt is bumped past the entry's own value so
    // the deletion always supersedes the copy it was applied to — otherwise a
    // remote/local copy with a future (clock-skewed) timestamp would resurrect it.
    const now = Date.now();
    const next = entries.map((e) =>
      e.id === id ? { ...e, deletedAt: now, updatedAt: Math.max(now, e.updatedAt + 1) } : e,
    );
    await persist(next);
    view = 'list';
  }

  function lock() {
    locked = true;
    pass = '';
    entries = [];
    view = 'list';
  }

  let title = $derived(
    view === 'edit' ? (editing ? t('titleEdit') : t('titleAdd'))
    : view === 'backup' ? t('titleBackup')
    : view === 'settings' ? t('titleSettings')
    : t('titleList'),
  );
</script>

{#if locked}
  <div class="app">
    <div class="center">
      <div style="font-size:40px">🛡️</div>
      <h1 style="margin:0">TokenManager</h1>
      <p style="color:var(--muted);font-size:13px;margin:0">
        {hasVault ? t('lockUnlockPrompt') : t('lockSetPrompt')}
      </p>
      <input
        type="password"
        placeholder={t('passphrase')}
        bind:value={pwInput}
        onkeydown={(e) => e.key === 'Enter' && doUnlock()}
      />
      <button onclick={doUnlock} disabled={busy} style="width:100%">
        {hasVault ? t('unlock') : t('start')}
      </button>
      {#if err}<div class="err">{err}</div>{/if}
    </div>
  </div>
{:else}
  <div class="app">
    <header>
      {#if view !== 'list'}
        <button class="icon ghost" style="color:#fff;border-color:rgba(255,255,255,.3)" onclick={() => { view = 'list'; refreshLead(); }}>←</button>
      {/if}
      <h1>{title}</h1>
      {#if view === 'list'}
        <button class="icon" title={t('syncNow')} onclick={doMainSync} disabled={syncingMain}>{syncingMain ? '…' : '🔄'}</button>
        <button class="icon" title={t('titleSettings')} onclick={() => (view = 'settings')}>⚙</button>
        <button class="icon" title={t('titleBackup')} onclick={() => (view = 'backup')}>⛁</button>
        <button class="icon" title={t('unlock')} onclick={lock}>🔒</button>
      {/if}
    </header>
    <main>
      {#if view === 'list'}
        {#if syncMainMsg}<div class="ok" style="margin:0 0 8px">{syncMainMsg}</div>{/if}
        <TokenList entries={activeEntries(entries)} {leadDays} onAdd={() => { editing = null; view = 'edit'; }} onEdit={(e) => { editing = e; view = 'edit'; }} />
      {:else if view === 'edit'}
        <TokenEdit existing={editing} {onSave} {onDelete} onCancel={() => (view = 'list')} />
      {:else if view === 'backup'}
        <Backup {entries} {pass} onImported={persist} />
      {:else}
        <Settings {runSync} />
      {/if}
    </main>
  </div>
{/if}
