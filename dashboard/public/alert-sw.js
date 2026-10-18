/* DriverAwaken supervisor alerts. No incident data is cached by this worker. */
self.addEventListener('push', event => {
  let payload = {};
  try { payload = event.data ? event.data.json() : {}; } catch { /* Ignore malformed payloads. */ }
  const notification = payload.notification || payload.webpush?.notification || {};
  const data = payload.data || {};
  const incidentId = typeof data.incidentId === 'string' ? data.incidentId : '';
  const title = typeof notification.title === 'string' ? notification.title : 'DriverAwaken · alerta de flota';
  const body = typeof notification.body === 'string' ? notification.body : 'Hay un incidente nuevo en la central.';
  event.waitUntil(self.registration.showNotification(title, {
    body,
    tag: incidentId || 'driverawaken-fleet',
    requireInteraction: data.severity === 'CRITICAL',
    data: { path: new URL('dashboard/incidents/', self.registration.scope).href },
  }));
});
self.addEventListener('notificationclick', event => {
  event.notification.close();
  event.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(async clients => {
    const target = new URL('dashboard/incidents/', self.registration.scope).href;
    const current = clients.find(client => client.url.startsWith(self.registration.scope));
    if (current) { await current.navigate(target); return current.focus(); }
    return self.clients.openWindow(target);
  }));
});
