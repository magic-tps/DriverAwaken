export const ALERT_SEVERITIES = new Set(['WARNING', 'CRITICAL']);
export const STAFF_ROLES = new Set(['ADMIN', 'OPERATOR']);

export function shouldDispatch(incident, organization) {
  return organization?.status === 'ACTIVE'
    && ALERT_SEVERITIES.has(incident?.severity)
    && typeof incident?.driverId === 'string'
    && typeof incident?.tripId === 'string';
}

export function recipients(subscriptions, memberships, incident) {
  if (!ALERT_SEVERITIES.has(incident?.severity)) return [];
  const unique = new Set();
  return subscriptions.filter(subscription => {
    const member = memberships.get(subscription.userId);
    if (!member || member.status !== 'ACTIVE' || !STAFF_ROLES.has(member.role)) return false;
    if (subscription.userId === incident.driverId || subscription.platform !== 'WEB') return false;
    if (typeof subscription.token !== 'string' || !subscription.token.trim()) return false;
    if (unique.has(subscription.token)) return false;
    unique.add(subscription.token);
    return true;
  });
}

export function alertText(incident) {
  if (incident.severity === 'CRITICAL') {
    return { title: 'DriverAwaken · alerta crítica', body: 'Se recibió una señal crítica de fatiga. Abre la central y aplica el protocolo de parada segura.' };
  }
  return { title: 'DriverAwaken · alerta de fatiga', body: 'Se recibió una señal de fatiga. Revisa el incidente en la central.' };
}
