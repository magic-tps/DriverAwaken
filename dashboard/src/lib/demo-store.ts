import { DEMO_STORAGE_KEY, demoReducer, initialDemo, restoreDemo, type DemoEvent } from './demo';

// An external browser store keeps static HTML deterministic and persists each dispatch atomically.
const serverSnapshot = { state: initialDemo(), warning: '' };
let snapshot = serverSnapshot;
let initialized = false;
const listeners = new Set<() => void>();
export function getDemoServerSnapshot() { return serverSnapshot; }
export function getDemoSnapshot() {
  if (!initialized && typeof window !== 'undefined') {
    initialized = true;
    try { snapshot = { state: restoreDemo(localStorage.getItem(DEMO_STORAGE_KEY)), warning: '' }; }
    catch { snapshot = { state: initialDemo(), warning: 'El navegador bloqueó el almacenamiento. La demo funciona solo durante esta sesión.' }; }
  }
  return snapshot;
}
export function subscribeDemo(listener: () => void) {
  listeners.add(listener);
  function storage(event: StorageEvent) {
    if (event.key !== DEMO_STORAGE_KEY) return;
    snapshot = { state: restoreDemo(event.newValue), warning: '' };
    listeners.forEach(notify => notify());
  }
  window.addEventListener('storage', storage);
  return () => { listeners.delete(listener); window.removeEventListener('storage', storage); };
}
export function dispatchDemo(event: DemoEvent) {
  const state = demoReducer(getDemoSnapshot().state, event);
  let warning = '';
  try { localStorage.setItem(DEMO_STORAGE_KEY, JSON.stringify(state)); }
  catch { warning = 'No se pudo persistir la demo; evita recargar para conservar esta sesión.'; }
  snapshot = { state, warning };
  listeners.forEach(notify => notify());
}
