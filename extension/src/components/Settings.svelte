<script lang="ts">
  import { onMount } from 'svelte';
  import { getNoExpiryInterval, setNoExpiryInterval, type NoExpiryInterval } from '../lib/settings';
  import { SELECTABLE, currentSelection, setLocale, t, type LocaleSel } from '../lib/i18n.svelte';

  let interval = $state<NoExpiryInterval>('30');
  let langSel = $state<LocaleSel>('system');
  let saved = $state(false);

  onMount(async () => {
    interval = await getNoExpiryInterval();
    langSel = await currentSelection();
  });

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

<div><b style="font-size:13px">{t('noExpiryTitle')}</b></div>
<p class="sub">{t('noExpirySub')}</p>
{#each ivOpts as o (o.v)}
  <label class="row" style="margin:6px 0;cursor:pointer">
    <input type="radio" name="noexpiry" style="width:auto" checked={interval === o.v} onclick={() => chooseInterval(o.v)} />
    <span>{t(o.key)}</span>
  </label>
{/each}

{#if saved}<div class="ok">{t('saved')}</div>{/if}

<div class="banner" style="margin-top:16px">{t('settingsNote')}</div>
