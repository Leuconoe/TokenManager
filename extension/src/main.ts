import { mount } from 'svelte';
import './app.css';
import App from './App.svelte';
import { initLocale } from './lib/i18n.svelte';

// Resolve saved/browser locale before mounting (no top-level await — not
// supported by the extension target). t() is reactive regardless.
initLocale().finally(() => {
  mount(App, { target: document.getElementById('app')! });
});
