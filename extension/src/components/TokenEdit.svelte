<script lang="ts">
  import { onMount } from 'svelte';
  import { uuid, type TokenEntry } from '../lib/domain';
  import { looksLikeToken } from '../lib/noteDetector';
  import { activeTabHint } from '../lib/currentTab';

  let { existing, onSave, onDelete, onCancel }: {
    existing: TokenEntry | null;
    onSave: (e: TokenEntry) => void;
    onDelete: (id: string) => void;
    onCancel: () => void;
  } = $props();

  let serviceName = $state(existing?.serviceName ?? '');
  let url = $state(existing?.url ?? '');
  let autofilled = $state(false);

  // Add mode: pre-fill service name + URL from the current tab (activeTab).
  onMount(async () => {
    if (existing) return;
    const hint = await activeTabHint();
    if (!hint) return;
    if (!serviceName) serviceName = hint.serviceName;
    if (!url) url = hint.url;
    autofilled = true;
  });
  let issued = $state(toInput(existing?.issuedAt ?? null));
  let expires = $state(toInput(existing?.expiresAt ?? null));
  let note = $state(existing?.note ?? '');
  let err = $state('');

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
      err = '서비스 명을 입력하세요';
      return;
    }
    if (looksLikeToken(note) && !confirm('노트에 토큰 값으로 보이는 내용이 있습니다. 계속 저장할까요?')) {
      return;
    }
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
    if (existing && confirm(`"${existing.serviceName}" 기록을 삭제할까요?`)) onDelete(existing.id);
  }
</script>

<div class="banner">⚠️ 토큰 값은 입력하지 마세요. 이 앱은 토큰 추적용이며 값 저장을 권장하지 않습니다.</div>

{#if autofilled}<div class="ok">현재 탭에서 자동 입력됨 (수정 가능)</div>{/if}

<label>서비스 명 *</label>
<input bind:value={serviceName} placeholder="예: GitHub PAT - CI 배포용" />

<label>URL (선택)</label>
<input bind:value={url} type="url" placeholder="https://github.com/settings/tokens" />

<div class="row">
  <div style="flex:1"><label>발급일</label><input type="date" bind:value={issued} /></div>
  <div style="flex:1"><label>만료일</label><input type="date" bind:value={expires} /></div>
</div>
{#if !expires}<div class="sub" style="color:#b45309;margin-top:4px">만료일 미설정 = 무기한(보안 경고 대상)</div>{/if}

<label>노트</label>
<textarea bind:value={note} rows="3" placeholder="회전 정책, 용도 등 (토큰 값 입력 금지)"></textarea>

{#if err}<div class="err">{err}</div>{/if}

<div class="row" style="margin-top:14px">
  <button style="flex:1" onclick={submit}>저장</button>
  {#if existing}
    <button class="ghost" style="color:#b91c1c;border-color:#b91c1c" onclick={remove}>삭제</button>
  {/if}
  <button class="ghost" onclick={onCancel}>취소</button>
</div>
