<script lang="ts">
  import { onMount } from 'svelte';
  import { save, unlock, vaultExists } from './lib/vault';
  import type { TokenEntry } from './lib/domain';
  import TokenList from './components/TokenList.svelte';
  import TokenEdit from './components/TokenEdit.svelte';
  import Backup from './components/Backup.svelte';

  let locked = $state(true);
  let hasVault = $state(false);
  let pass = $state(''); // session passphrase — memory only, never persisted
  let entries = $state<TokenEntry[]>([]);
  let view = $state<'list' | 'edit' | 'backup'>('list');
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
      err = '패스프레이즈는 8자 이상이어야 합니다';
      return;
    }
    busy = true;
    try {
      entries = await unlock(pwInput);
      pass = pwInput;
      pwInput = '';
      locked = false;
      if (!hasVault) await save(pass, entries); // seal the vault on first set
    } catch {
      err = '패스프레이즈가 올바르지 않습니다';
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
</script>

{#if locked}
  <div class="app">
    <div class="center">
      <div style="font-size:40px">🛡️</div>
      <h1 style="margin:0">TokenManager</h1>
      <p style="color:var(--muted);font-size:13px;margin:0">
        {hasVault ? '패스프레이즈를 입력해 잠금을 해제하세요' : '새 패스프레이즈를 설정하세요 (8자 이상)'}
      </p>
      <input
        type="password"
        placeholder="패스프레이즈"
        bind:value={pwInput}
        onkeydown={(e) => e.key === 'Enter' && doUnlock()}
      />
      <button onclick={doUnlock} disabled={busy} style="width:100%">
        {hasVault ? '잠금 해제' : '시작하기'}
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
      <h1>{view === 'edit' ? (editing ? '토큰 수정' : '토큰 추가') : view === 'backup' ? '백업 / 복원' : '토큰 보관함'}</h1>
      {#if view === 'list'}
        <button class="icon" title="백업/복원" onclick={() => (view = 'backup')}>⛁</button>
        <button class="icon" title="잠금" onclick={lock}>🔒</button>
      {/if}
    </header>
    <main>
      {#if view === 'list'}
        <TokenList {entries} onAdd={() => { editing = null; view = 'edit'; }} onEdit={(e) => { editing = e; view = 'edit'; }} />
      {:else if view === 'edit'}
        <TokenEdit existing={editing} {onSave} {onDelete} onCancel={() => (view = 'list')} />
      {:else}
        <Backup {entries} {pass} onImported={persist} />
      {/if}
    </main>
  </div>
{/if}
