import { incidentStatus, type Incident, type OperatorAction, type Trip } from './domain';

export interface IncidentFilters { from: string; to: string; vehicleId: string; driverId: string; tripId: string; severity: string; type: string }
export const EMPTY_INCIDENT_FILTERS: IncidentFilters = { from: '', to: '', vehicleId: '', driverId: '', tripId: '', severity: '', type: '' };
export function limaDay(time: number) {
  const parts = new Intl.DateTimeFormat('en', { timeZone: 'America/Lima', year: 'numeric', month: '2-digit', day: '2-digit' }).formatToParts(time);
  const part = (type: string) => parts.find(p => p.type === type)?.value ?? '';
  return `${part('year')}-${part('month')}-${part('day')}`;
}
export function filterIncidents(incidents: Incident[], trips: Trip[], filters: IncidentFilters) {
  const vehicleByTrip = new Map(trips.map(trip => [trip.id, trip.vehicleId]));
  return incidents.filter(incident => {
    const day = limaDay(incident.detectedAt);
    return (!filters.from || day >= filters.from) && (!filters.to || day <= filters.to)
      && (!filters.vehicleId || vehicleByTrip.get(incident.tripId) === filters.vehicleId)
      && (!filters.driverId || incident.driverId === filters.driverId) && (!filters.tripId || incident.tripId === filters.tripId)
      && (!filters.severity || incident.severity === filters.severity) && (!filters.type || incident.type === filters.type);
  });
}
export function incidentAnalytics(incidents: Incident[], actions: OperatorAction[]) {
  const delays = incidents.flatMap(incident => {
    const acknowledgements = actions.filter(action => action.incidentId === incident.id && action.actionType === 'ACKNOWLEDGED' && action.createdAt >= incident.detectedAt);
    return acknowledgements.length ? [Math.min(...acknowledgements.map(action => action.createdAt)) - incident.detectedAt] : [];
  });
  return {
    critical: incidents.filter(i => i.severity === 'CRITICAL').length,
    signalUnavailable: incidents.filter(i => i.signalQuality === 'INSUFFICIENT').length,
    acknowledgedCount: delays.length,
    meanAcknowledgementMs: delays.length ? Math.round(delays.reduce((total, delay) => total + delay, 0) / delays.length) : null,
  };
}

// Quote every field and prevent spreadsheet formulas from untrusted identifiers.
export function csvCell(value: string) {
  const safe = /^[\s]*[=+@-]/u.test(value) ? `'${value}` : value;
  return `"${safe.replaceAll('"', '""')}"`;
}
export function incidentCsv(incidents: Incident[], actions: OperatorAction[]) {
  const rows = [['id', 'tripId', 'type', 'severity', 'detectedAt', 'receivedAt', 'riskScore', 'status'], ...incidents.map(i => [i.id, i.tripId, i.type, i.severity, new Date(i.detectedAt).toISOString(), i.receivedAt === null ? '' : new Date(i.receivedAt).toISOString(), String(i.riskScore), incidentStatus(i.id, actions)])];
  return '\uFEFF' + rows.map(row => row.map(csvCell).join(',')).join('\r\n');
}
