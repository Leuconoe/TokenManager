<script lang="ts">
  import { onMount } from 'svelte';
  import { statusOf, type TokenEntry, type TokenStatus } from '../lib/domain';
  import { t } from '../lib/i18n.svelte';
  import { getSort, setSort, type SortKey, type SortDir } from '../lib/settings';

  let { entries, leadDays = 14, onAdd, onEdit }: {
    entries: TokenEntry[];
    leadDays?: number;
    onAdd: () => void;
    onEdit: (e: TokenEntry) => void;
  } = $props();

  const STATUS_KEY: Record<TokenStatus, string> = {
    valid: 'stValid', expiringSoon: 'stSoon', expired: 'stExpired', noExpiry: 'stNoExpiry',
  };

  const now = Date.now();
  let sortKey = $state<SortKey>('expiry');
  let sortDir = $state<SortDir>('asc');
  onMount(async () => {
    const s = await getSort();
    sortKey = s.key;
    sortDir = s.dir;
  });
  async function changeKey(k: SortKey) { sortKey = k; await setSort(sortKey, sortDir); }
  async function toggleDir() {
    sortDir = sortDir === 'asc' ? 'desc' : 'asc';
    await setSort(sortKey, sortDir);
  }

  // Compare in ascending order for the chosen key; null expiry always sinks.
  function cmp(a: TokenEntry, b: TokenEntry): number {
    switch (sortKey) {
      case 'name': return a.serviceName.localeCompare(b.serviceName);
      case 'site': return (a.url || '').localeCompare(b.url || '');
      case 'created': return a.createdAt - b.createdAt;
      case 'expiry':
      default:
        if (a.expiresAt == null && b.expiresAt == null) return a.serviceName.localeCompare(b.serviceName);
        if (a.expiresAt == null) return 1; // no-expiry to the bottom (both dirs)
        if (b.expiresAt == null) return -1;
        return a.expiresAt - b.expiresAt;
    }
  }
  let sorted = $derived(
    [...entries].sort((a, b) => {
      const base = cmp(a, b);
      // Keep no-expiry sinking regardless of direction for the expiry sort.
      if (sortKey === 'expiry' && (a.expiresAt == null) !== (b.expiresAt == null)) return base;
      return sortDir === 'desc' ? -base : base;
    }),
  );

  // Search across title / site / note.
  let q = $state('');
  function matches(e: TokenEntry): boolean {
    const s = q.trim().toLowerCase();
    if (!s) return true;
    return (
      e.serviceName.toLowerCase().includes(s) ||
      (e.url || '').toLowerCase().includes(s) ||
      (e.note || '').toLowerCase().includes(s)
    );
  }
  let shown = $derived(sorted.filter(matches));

  function subtitle(e: TokenEntry): string {
    if (e.expiresAt == null) return t('noExpiryDate');
    const d = new Date(e.expiresAt);
    const ymd = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    const days = Math.floor((e.expiresAt - now) / 86_400_000);
    return days < 0 ? t('expiredAt', { date: ymd }) : t('dday', { days, date: ymd });
  }

  function openUrl(raw: string, ev: Event) {
    ev.stopPropagation();
    let u = raw.trim();
    if (!/^https?:\/\//i.test(u)) u = 'https://' + u;
    chrome.tabs.create({ url: u });
  }
</script>

{#if entries.length === 0}
  <div class="empty">{t('empty1')}<br />{t('empty2')}</div>
{:else}
  <input type="search" placeholder={t('searchPlaceholder')} bind:value={q} style="margin-bottom:8px" />
  <div class="row" style="gap:6px;margin-bottom:8px">
    <select value={sortKey} onchange={(e) => changeKey((e.currentTarget as HTMLSelectElement).value as SortKey)} style="flex:1">
      <option value="expiry">{t('sortExpiry')}</option>
      <option value="created">{t('sortCreated')}</option>
      <option value="name">{t('sortName')}</option>
      <option value="site">{t('sortSite')}</option>
    </select>
    <button class="ghost" style="width:auto;flex:none" title={sortDir === 'asc' ? t('sortAsc') : t('sortDesc')} onclick={toggleDir}>
      {sortDir === 'asc' ? '↑' : '↓'}
    </button>
  </div>
  {#if shown.length === 0}
    <div class="empty" style="margin-top:24px">{t('searchNoResults')}</div>
  {/if}
  {#each shown as e (e.id)}
    <div class="card row" style="justify-content:space-between;cursor:pointer" onclick={() => onEdit(e)} role="button" tabindex="0" onkeydown={(ev) => ev.key === 'Enter' && onEdit(e)}>
      <div style="overflow:hidden">
        <div class="svc">{e.serviceName}</div>
        {#if e.url}
          <div class="url" style="display:flex;align-items:center;gap:4px">
            <span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{e.url}</span>
            <button
              onclick={(ev) => openUrl(e.url, ev)}
              title={e.url}
              style="flex:none;width:auto;padding:0 4px;background:none;border:none;color:var(--accent,#4f46e5);cursor:pointer;font-size:13px"
            >↗</button>
          </div>
        {/if}
        <div class="sub">{subtitle(e)}</div>
      </div>
      <span class="badge {statusOf(e, now, leadDays)}">{t(STATUS_KEY[statusOf(e, now, leadDays)])}</span>
    </div>
  {/each}
{/if}

<button style="position:sticky;bottom:8px;width:100%;margin-top:8px" onclick={onAdd}>{t('addToken')}</button>
