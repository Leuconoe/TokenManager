<script lang="ts">
  import type { TokenEntry } from '../lib/domain';
  import { t } from '../lib/i18n.svelte';

  let { deleted, onRestore, onPurge, onPurgeAll }: {
    deleted: TokenEntry[];
    onRestore: (id: string) => void;
    onPurge: (id: string) => void;
    onPurgeAll: () => void;
  } = $props();

  function ymd(ms: number): string {
    const d = new Date(ms);
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  }
  function purgeAll() {
    if (confirm(t('trashPurgeAllConfirm'))) onPurgeAll();
  }
</script>

{#if deleted.length === 0}
  <div class="empty">{t('trashEmpty')}</div>
{:else}
  <p class="sub" style="margin:0 0 8px">{t('trashHint')}</p>
  <button class="ghost" style="width:100%;margin-bottom:8px" onclick={purgeAll}>{t('trashPurgeAll')}</button>
  {#each deleted as e (e.id)}
    <div class="card row" style="justify-content:space-between">
      <div style="overflow:hidden">
        <div class="svc">{e.serviceName}</div>
        {#if e.deletedAt}<div class="sub">{t('trashDeletedOn', { date: ymd(e.deletedAt) })}</div>{/if}
      </div>
      <span class="row" style="gap:4px;flex:none">
        <button class="icon" title={t('trashRestore')} onclick={() => onRestore(e.id)}>↩</button>
        <button class="icon" title={t('trashPurge')} onclick={() => onPurge(e.id)}>🗑</button>
      </span>
    </div>
  {/each}
{/if}
