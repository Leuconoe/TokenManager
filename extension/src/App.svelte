<script lang="ts">
  import { onMount } from 'svelte';
  import { save, unlock, vaultExists } from './lib/vault';
  import type { TokenEntry } from './lib/domain';
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

  onMount(async () => {
    hasVault = await vaultExists();
  });

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
    } catch {
      err = t('pwWrong');
    } finally {
      busy = false;
    }
  }

  async function persist(next: TokenEntry[]) {
    entries = next;
    await save(pass, entries);
  }

  async function onSave(entry: TokenEntry) {
    const i = entries.findIndex((e) => e.id === entry.id);
    const next = i >= 0 ? entries.map((e) => (e.id === entry.id ? entry : e)) : [...entries, entry];
    await persist(next);
    view = 'list';
  }
  async function onDelete(id: string) {
    await persist(entries.filter((e) => e.id !== id));
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
        <button class="icon ghost" style="color:#fff;border-color:rgba(255,255,255,.3)" onclick={() => (view = 'list')}>←</button>
      {/if}
      <h1>{title}</h1>
      {#if view === 'list'}
        <button class="icon" title={t('titleSettings')} onclick={() => (view = 'settings')}>⚙</button>
        <button class="icon" title={t('titleBackup')} onclick={() => (view = 'backup')}>⛁</button>
        <button class="icon" title={t('unlock')} onclick={lock}>🔒</button>
      {/if}
    </header>
    <main>
      {#if view === 'list'}
        <TokenList {entries} onAdd={() => { editing = null; view = 'edit'; }} onEdit={(e) => { editing = e; view = 'edit'; }} />
      {:else if view === 'edit'}
        <TokenEdit existing={editing} {onSave} {onDelete} onCancel={() => (view = 'list')} />
      {:else if view === 'backup'}
        <Backup {entries} {pass} onImported={persist} />
      {:else}
        <Settings />
      {/if}
    </main>
  </div>
{/if}
