<script lang="ts">
  import { statusOf, type TokenEntry, type TokenStatus } from '../lib/domain';
  import { t } from '../lib/i18n.svelte';

  let { entries, onAdd, onEdit }: {
    entries: TokenEntry[];
    onAdd: () => void;
    onEdit: (e: TokenEntry) => void;
  } = $props();

  const STATUS_KEY: Record<TokenStatus, string> = {
    valid: 'stValid', expiringSoon: 'stSoon', expired: 'stExpired', noExpiry: 'stNoExpiry',
  };

  const now = Date.now();
  let sorted = $derived(
    [...entries].sort((a, b) => {
      if (a.expiresAt == null && b.expiresAt == null) return a.serviceName.localeCompare(b.serviceName);
      if (a.expiresAt == null) return 1;
      if (b.expiresAt == null) return -1;
      return a.expiresAt - b.expiresAt;
    }),
  );

  function subtitle(e: TokenEntry): string {
    if (e.expiresAt == null) return t('noExpiryDate');
    const d = new Date(e.expiresAt);
    const ymd = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    const days = Math.floor((e.expiresAt - now) / 86_400_000);
    return days < 0 ? t('expiredAt', { date: ymd }) : t('dday', { days, date: ymd });
  }
</script>

{#if entries.length === 0}
  <div class="empty">{t('empty1')}<br />{t('empty2')}</div>
{:else}
  {#each sorted as e (e.id)}
    <div class="card row" style="justify-content:space-between;cursor:pointer" onclick={() => onEdit(e)} role="button" tabindex="0" onkeydown={(ev) => ev.key === 'Enter' && onEdit(e)}>
      <div style="overflow:hidden">
        <div class="svc">{e.serviceName}</div>
        {#if e.url}<div class="url">{e.url}</div>{/if}
        <div class="sub">{subtitle(e)}</div>
      </div>
      <span class="badge {statusOf(e, now)}">{t(STATUS_KEY[statusOf(e, now)])}</span>
    </div>
  {/each}
{/if}

<button style="position:sticky;bottom:8px;width:100%;margin-top:8px" onclick={onAdd}>{t('addToken')}</button>
