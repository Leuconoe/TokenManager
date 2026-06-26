<script lang="ts">
  import { onMount } from 'svelte';
  import { getNoExpiryInterval, setNoExpiryInterval, type NoExpiryInterval } from '../lib/settings';

  let current = $state<NoExpiryInterval>('30');
  let saved = $state(false);

  onMount(async () => {
    current = await getNoExpiryInterval();
  });

  async function choose(v: NoExpiryInterval) {
    current = v;
    await setNoExpiryInterval(v);
    saved = true;
    setTimeout(() => (saved = false), 1500);
  }

  const opts: { v: NoExpiryInterval; label: string }[] = [
    { v: 'off', label: '끄기' },
    { v: '15', label: '15일마다' },
    { v: '30', label: '30일마다' },
  ];
</script>

<div><b style="font-size:13px">무기한 토큰 경고</b></div>
<p class="sub">만료일이 없는 토큰에 대한 주기적 보안 경고 알림 주기</p>

{#each opts as o (o.v)}
  <label class="row" style="margin:6px 0;cursor:pointer">
    <input type="radio" name="noexpiry" style="width:auto" checked={current === o.v} onclick={() => choose(o.v)} />
    <span>{o.label}</span>
  </label>
{/each}

{#if saved}<div class="ok">저장됨</div>{/if}

<div class="banner" style="margin-top:16px">
  알림은 백그라운드에서 동작하며, 개수만 표시합니다(어떤 서비스인지는 노출하지 않음). 상세는 잠금 해제 후 확인하세요.
</div>
