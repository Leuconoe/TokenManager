<script lang="ts">
  import { onMount } from 'svelte';
  import { uuid, type TokenEntry } from '../lib/domain';
  import { looksLikeToken } from '../lib/noteDetector';
  import { activeTabHint } from '../lib/currentTab';
  import { t } from '../lib/i18n.svelte';

  let { existing, onSave, onDelete, onCancel }: {
    existing: TokenEntry | null;
    onSave: (e: TokenEntry) => void;
    onDelete: (id: string) => void;
    onCancel: () => void;
  } = $props();

  let serviceName = $state(existing?.serviceName ?? '');
  let url = $state(existing?.url ?? '');
  let issued = $state(toInput(existing?.issuedAt ?? null));
  let expires = $state(toInput(existing?.expiresAt ?? null));
  let note = $state(existing?.note ?? '');
  let err = $state('');
  let autofilled = $state(false);

  onMount(async () => {
    if (existing) return;
    const hint = await activeTabHint();
    if (!hint) return;
    if (!serviceName) serviceName = hint.serviceName;
    if (!url) url = hint.url;
    autofilled = true;
  });

  function toInput(ms: number | null): string {
    if (ms == null) return '';
    const d = new Date(ms);
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  }
  function fromInput(s: string): number | null {
    return s ? new Date(s).getTime() : null;
  }

  function submit() {
    err = '';
    if (!serviceName.trim()) {
      err = t('errService');
      return;
    }
    if (looksLikeToken(note) && !confirm(t('noteWarn'))) return;
    const now = Date.now();
    onSave({
      id: existing?.id ?? uuid(),
      serviceName: serviceName.trim(),
      url: url.trim(),
      issuedAt: fromInput(issued),
      expiresAt: fromInput(expires),
      note,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    });
  }

  function remove() {
    if (existing && confirm(t('deleteConfirm', { name: existing.serviceName }))) onDelete(existing.id);
  }
</script>

<div class="banner">{t('tokenBanner')}</div>
{#if autofilled}<div class="ok">{t('autofilled')}</div>{/if}

<label>{t('fieldService')}</label>
<input bind:value={serviceName} placeholder={t('svcHint')} />

<label>{t('fieldUrl')}</label>
<input bind:value={url} type="url" placeholder="https://github.com/settings/tokens" />

<div class="row">
  <div style="flex:1"><label>{t('issued')}</label><input type="date" bind:value={issued} /></div>
  <div style="flex:1"><label>{t('expires')}</label><input type="date" bind:value={expires} /></div>
</div>
{#if !expires}<div class="sub" style="color:#b45309;margin-top:4px">{t('noExpiryHint')}</div>{/if}

<label>{t('note')}</label>
<textarea bind:value={note} rows="3" placeholder={t('noteHint')}></textarea>

{#if err}<div class="err">{err}</div>{/if}

<div class="row" style="margin-top:14px">
  <button style="flex:1" onclick={submit}>{t('save')}</button>
  {#if existing}
    <button class="ghost" style="color:#b91c1c;border-color:#b91c1c" onclick={remove}>{t('delete')}</button>
  {/if}
  <button class="ghost" onclick={onCancel}>{t('cancel')}</button>
</div>
