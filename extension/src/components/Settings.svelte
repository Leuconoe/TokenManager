<script lang="ts">
  import { onMount } from 'svelte';
  import {
    getExpiryLead, setExpiryLead, type ExpiryLead,
    getNoExpiryInterval, setNoExpiryInterval, type NoExpiryInterval,
  } from '../lib/settings';
  import { SELECTABLE, currentSelection, setLocale, t, type LocaleSel } from '../lib/i18n.svelte';
  import { checkUpdate } from '../lib/update';

  let lead = $state<ExpiryLead>('14');
  let interval = $state<NoExpiryInterval>('30');
  let langSel = $state<LocaleSel>('system');
  let saved = $state(false);
  let updateMsg = $state('');

  async function doCheckUpdate() {
    updateMsg = t('updateChecking');
    try {
      const info = await checkUpdate();
      if (info.hasUpdate) {
        if (confirm(t('updateAvailable', { latest: info.latest })) && info.url) {
          window.open(info.url, '_blank');
        }
        updateMsg = '';
      } else {
        updateMsg = t('updateUpToDate', { version: info.current });
      }
    } catch {
      updateMsg = t('updateFailed');
    }
  }

  onMount(async () => {
    lead = await getExpiryLead();
    interval = await getNoExpiryInterval();
    langSel = await currentSelection();
  });

  async function chooseLead(v: ExpiryLead) {
    lead = v;
    await setExpiryLead(v);
    flash();
  }

  async function chooseInterval(v: NoExpiryInterval) {
    interval = v;
    await setNoExpiryInterval(v);
    flash();
  }

  async function chooseLang(code: LocaleSel) {
    langSel = code;
    await setLocale(code); // updates t() reactively across the UI
    flash();
  }

  function flash() {
    saved = true;
    setTimeout(() => (saved = false), 1500);
  }

  const leadOpts: { v: ExpiryLead; key: string }[] = [
    { v: '7', key: 'lead7' },
    { v: '14', key: 'lead14' },
    { v: '30', key: 'lead30' },
  ];
  const ivOpts: { v: NoExpiryInterval; key: string }[] = [
    { v: 'off', key: 'intervalOff' },
    { v: '15', key: 'interval15' },
    { v: '30', key: 'interval30' },
  ];
</script>

<div><b style="font-size:13px">{t('language')}</b></div>
{#each SELECTABLE as o (o.code)}
  <label class="row" style="margin:6px 0;cursor:pointer">
    <input type="radio" name="lang" style="width:auto" checked={langSel === o.code} onclick={() => chooseLang(o.code)} />
    <span>{o.code === 'system' ? t('languageSystem') : o.label}</span>
  </label>
{/each}

<hr style="border:none;border-top:1px solid var(--border);margin:16px 0" />

<div><b style="font-size:13px">{t('expiryTitle')}</b></div>
<p class="sub">{t('expirySub')}</p>
{#each leadOpts as o (o.v)}
  <label class="row" style="margin:6px 0;cursor:pointer">
    <input type="radio" name="lead" style="width:auto" checked={lead === o.v} onclick={() => chooseLead(o.v)} />
    <span>{t(o.key)}</span>
  </label>
{/each}

<hr style="border:none;border-top:1px solid var(--border);margin:16px 0" />

<div><b style="font-size:13px">{t('noExpiryTitle')}</b></div>
<p class="sub">{t('noExpirySub')}</p>
{#each ivOpts as o (o.v)}
  <label class="row" style="margin:6px 0;cursor:pointer">
    <input type="radio" name="noexpiry" style="width:auto" checked={interval === o.v} onclick={() => chooseInterval(o.v)} />
    <span>{t(o.key)}</span>
  </label>
{/each}

{#if saved}<div class="ok">{t('saved')}</div>{/if}

<hr style="border:none;border-top:1px solid var(--border);margin:16px 0" />
<button class="ghost" style="width:100%" onclick={doCheckUpdate}>{t('updateCheck')}</button>
{#if updateMsg}<div class="ok" style="margin-top:6px">{updateMsg}</div>{/if}

<div class="banner" style="margin-top:16px">{t('settingsNote')}</div>
