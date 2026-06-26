<script lang="ts">
  import type { TokenEntry } from '../lib/domain';
  import { BackupAuthError, BackupFormatError, exportTmbk, importTmbk } from '../lib/crypto';

  let { entries, onImported }: {
    entries: TokenEntry[];
    pass: string;
    onImported: (next: TokenEntry[]) => Promise<void>;
  } = $props();

  let bpass = $state('');
  let mode = $state<'merge' | 'overwrite'>('merge');
  let msg = $state('');
  let err = $state('');
  let fileInput: HTMLInputElement;

  function fileName(): string {
    const d = new Date();
    const ymd = `${d.getFullYear()}${String(d.getMonth() + 1).padStart(2, '0')}${String(d.getDate()).padStart(2, '0')}`;
    return `tokenmanager-backup-${ymd}.tmbk`;
  }

  async function doExport() {
    err = ''; msg = '';
    if (bpass.length < 8) { err = '패스프레이즈는 8자 이상이어야 합니다'; return; }
    const blob = new Blob([await exportTmbk(bpass, JSON.stringify(entries))], { type: 'application/octet-stream' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = fileName();
    a.click();
    URL.revokeObjectURL(a.href);
    msg = '백업 파일을 내보냈습니다';
  }

  async function doImport(ev: Event) {
    err = ''; msg = '';
    const f = (ev.target as HTMLInputElement).files?.[0];
    if (!f) return;
    if (bpass.length < 8) { err = '패스프레이즈를 입력하세요'; return; }
    try {
      const bytes = new Uint8Array(await f.arrayBuffer());
      const json = await importTmbk(bpass, bytes);
      const incoming = JSON.parse(json) as TokenEntry[];
      let next: TokenEntry[];
      if (mode === 'overwrite') {
        next = incoming;
      } else {
        const map = new Map(entries.map((e) => [e.id, e]));
        for (const e of incoming) map.set(e.id, e);
        next = [...map.values()];
      }
      await onImported(next);
      msg = `${incoming.length}건을 복원했습니다`;
    } catch (e) {
      if (e instanceof BackupAuthError) err = '비밀번호가 올바르지 않거나 백업이 손상되었습니다';
      else if (e instanceof BackupFormatError) err = '지원하지 않는 백업 파일입니다';
      else err = `복원 실패: ${e}`;
    } finally {
      fileInput.value = '';
    }
  }
</script>

<p class="sub">백업은 패스프레이즈로 암호화됩니다 (Argon2id + AES-256-GCM). 앱의 <code>.tmbk</code> 백업과 호환됩니다.</p>

<label>패스프레이즈 (8자 이상)</label>
<input type="password" bind:value={bpass} placeholder="백업/복원 공통" />

<div style="margin-top:14px"><b style="font-size:13px">내보내기</b></div>
<button style="width:100%;margin-top:6px" onclick={doExport}>백업 파일 내보내기</button>

<div style="margin-top:16px"><b style="font-size:13px">복원</b></div>
<div class="row" style="margin-top:6px">
  <label style="margin:0"><input type="radio" style="width:auto" bind:group={mode} value="merge" /> 병합</label>
  <label style="margin:0"><input type="radio" style="width:auto" bind:group={mode} value="overwrite" /> 덮어쓰기</label>
</div>
<input bind:this={fileInput} type="file" accept=".tmbk,application/octet-stream" onchange={doImport} style="margin-top:8px;border:none;padding:0" />

{#if msg}<div class="ok">{msg}</div>{/if}
{#if err}<div class="err">{err}</div>{/if}

<div class="banner" style="margin-top:16px">⚠️ 백업 파일을 공유할 때 패스프레이즈를 함께 전송하지 마세요.</div>
