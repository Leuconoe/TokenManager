<script lang="ts">
  import { onMount } from 'svelte';
  import {
    getExpiryLead, setExpiryLead, type ExpiryLead,
    getNoExpiryInterval, setNoExpiryInterval, type NoExpiryInterval,
    getSyncPassphrase, setSyncPassphrase, getSyncLast,
  } from '../lib/settings';
  import { SELECTABLE, currentSelection, setLocale, t, type LocaleSel } from '../lib/i18n.svelte';
  import { checkUpdate } from '../lib/update';
  import { getToken, isConnected, disconnect, redirectUri, DriveConfigError } from '../lib/drive';
  import { getLog, clearLog, type LogEntry } from '../lib/debuglog';

  let { runSync }: {
    runSync: (interactive: boolean) => Promise<{ merged?: number; error?: string }>;
  } = $props();

  let lead = $state<ExpiryLead>('14');
  let interval = $state<NoExpiryInterval>('30');
  let langSel = $state<LocaleSel>('system');
  let saved = $state(false);
  let updateMsg = $state('');

  // Drive sync state
  let connected = $state(false);
  let syncPass = $state('');
  let lastSync = $state<number | null>(null);
  let syncMsg = $state('');
  const redirect = redirectUri();

  const appVersion = chrome.runtime.getManifest().version;

  // Debug log
  let logEntries = $state<LogEntry[]>([]);
  async function loadLog() {
    logEntries = (await getLog()).slice().reverse(); // newest first
  }
  async function doClearLog() {
    await clearLog();
    await loadLog();
  }

  async function connectDrive() {
    syncMsg = '';
    try {
      await disconnect(); // reconnect: drop any stale token, force fresh consent
      await getToken(true);
      connected = true;
    } catch (e) {
      syncMsg = e instanceof DriveConfigError
        ? t('syncNeedClientId')
        : `${t('syncFailed')} [${(e as Error)?.message ?? e}]`;
    }
  }
  async function disconnectDrive() {
    await disconnect();
    connected = false;
  }
  async function saveSyncPass() {
    await setSyncPassphrase(syncPass || null);
    flash();
  }
  async function doSyncNow() {
    syncMsg = t('syncing');
    const r = await runSync(true);
    if (r.error === 'needPass') syncMsg = t('syncNeedSetup');
    else if (r.error?.includes('BackupAuthError')) syncMsg = t('syncPassMismatch');
    else if (r.error) {
      syncMsg = `${t('syncFailed')} [${r.error}]`;
      connected = await isConnected(); // sync dropped the connection on failure
    } else {
      syncMsg = t('syncDone', { count: r.merged ?? 0 });
      lastSync = await getSyncLast();
    }
  }

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
    connected = await isConnected();
    syncPass = (await getSyncPassphrase()) ?? '';
    lastSync = await getSyncLast();
    await loadLog();
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

<div><b style="font-size:13px">{t('syncTitle')}</b></div>
<p class="sub">{t('syncSub')}</p>
{#if connected}
  <div class="row" style="justify-content:space-between;margin:6px 0">
    <span class="ok" style="margin:0">✓ {t('syncConnected')}</span>
    <button class="ghost" style="width:auto" onclick={disconnectDrive}>{t('syncDisconnect')}</button>
  </div>
{:else}
  <button class="ghost" style="width:100%" onclick={connectDrive}>{t('syncConnect')}</button>
  <p class="sub" style="margin-top:6px">{t('syncRedirect')}</p>
  <code style="display:block;word-break:break-all;font-size:11px;background:var(--bg);padding:6px;border-radius:6px">{redirect}</code>
{/if}
<label style="display:block;margin-top:10px;font-size:12px;color:var(--muted)">{t('syncPassLabel')}</label>
<div class="row" style="margin:4px 0">
  <input type="password" bind:value={syncPass} placeholder={t('syncPassLabel')} />
  <button style="width:auto" onclick={saveSyncPass}>{t('syncPassSave')}</button>
</div>
<button style="width:100%;margin-top:6px" onclick={doSyncNow}>{t('syncNow')}</button>
{#if syncMsg}<div class="ok" style="margin-top:6px">{syncMsg}</div>{/if}
<p class="sub" style="margin-top:6px">{t('syncLast', { time: lastSync ? new Date(lastSync).toLocaleString() : t('syncNever') })}</p>

<hr style="border:none;border-top:1px solid var(--border);margin:16px 0" />
<button class="ghost" style="width:100%" onclick={doCheckUpdate}>{t('updateCheck')}</button>
{#if updateMsg}<div class="ok" style="margin-top:6px">{updateMsg}</div>{/if}

<div class="banner" style="margin-top:16px">{t('settingsNote')}</div>

<hr style="border:none;border-top:1px solid var(--border);margin:16px 0" />
<div class="row" style="justify-content:space-between">
  <b style="font-size:13px">{t('debugLogTitle')}</b>
  <span>
    <button class="ghost" style="width:auto" onclick={loadLog}>{t('debugRefresh')}</button>
    <button class="ghost" style="width:auto" onclick={doClearLog}>{t('debugClear')}</button>
  </span>
</div>
<div style="margin-top:6px;max-height:220px;overflow:auto;background:var(--bg);border:1px solid var(--border);border-radius:6px;padding:6px;font-family:monospace;font-size:11px;white-space:pre-wrap;word-break:break-all">
  {#if logEntries.length === 0}{t('debugEmpty')}{:else}{#each logEntries as e, i (i)}{new Date(e.t).toLocaleTimeString()}  {e.m}
{/each}{/if}
</div>

<p class="sub" style="text-align:center;margin-top:14px">{t('versionTitle')} {appVersion}</p>
