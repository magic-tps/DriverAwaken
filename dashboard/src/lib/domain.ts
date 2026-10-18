export type IncidentType = 'PROLONGED_EYE_CLOSURE' | 'HIGH_PERCLOS' | 'REPEATED_YAWNING' | 'SUSTAINED_HEAD_DOWN' | 'POSSIBLE_DISTRACTION' | 'SIGNAL_UNAVAILABLE' | 'MONITORING_INTERRUPTED';
export type Severity = 'WARNING' | 'CRITICAL' | 'INFO';
export type ActionType = 'ACKNOWLEDGED' | 'ACTION_RECORDED' | 'RESOLVED';
export type IncidentStatus = 'NEW' | ActionType;
export type SyncStatus = 'LOCAL_ONLY' | 'QUEUED' | 'SYNCING' | 'SYNCED' | 'FAILED';
export interface Incident {
  id: string; organizationId: string; tripId: string; driverId: string;
  type: IncidentType; severity: Severity; detectedAt: number; receivedAt: number | null;
  riskScore: number; reasonCode: string; signalQuality: 'RELIABLE' | 'INSUFFICIENT';
  monitoringHealth: 'HEALTHY' | 'DEGRADED' | 'UNAVAILABLE'; syncStatus?: SyncStatus;
}
export interface OperatorAction {
  id: string; organizationId: string; incidentId: string; operatorId: string;
  actionType: ActionType; note: string; createdAt: number;
}
export interface Trip {
  id: string; organizationId: string; vehicleId: string; driverId: string;
  origin: string; destination: string; startTime: number; endTime: number | null;
  status: 'ASSIGNED' | 'ACTIVE' | 'COMPLETED' | 'CANCELLED';
  monitoringStatus: 'ACTIVE' | 'PAUSED' | 'UNAVAILABLE' | 'OFFLINE';
  lastEventAt: number | null; lastSeenAt: number | null;
}
export interface Vehicle { id: string; organizationId: string; internalCode: string; vehicleType: string; status: string }
export interface FleetRestSession {
  id: string; organizationId: string; tripId: string; driverId: string; startedAt: number; endedAt: number;
  durationMs: number; recommendationReason: string; voluntarilyConfirmed: true; receivedAt: number | null;
}
export interface Membership { userId: string; organizationId: string; role: 'ADMIN' | 'OPERATOR' | 'DRIVER'; status: 'ACTIVE' | 'INACTIVE' }
export const TYPE_LABELS: Record<IncidentType, string> = {
  PROLONGED_EYE_CLOSURE: 'Cierre ocular prolongado', HIGH_PERCLOS: 'Cierre ocular acumulado',
  REPEATED_YAWNING: 'Bostezos repetidos', SUSTAINED_HEAD_DOWN: 'Inclinación sostenida',
  POSSIBLE_DISTRACTION: 'Posible distracción', SIGNAL_UNAVAILABLE: 'Señal insuficiente',
  MONITORING_INTERRUPTED: 'Monitoreo interrumpido',
};
export const STATUS_LABELS: Record<IncidentStatus, string> = { NEW: 'Nuevo', ACKNOWLEDGED: 'Reconocido', ACTION_RECORDED: 'Acción registrada', RESOLVED: 'Resuelto' };
export function incidentStatus(id: string, actions: OperatorAction[]): IncidentStatus {
  // Resolve ties deterministically without letting a delayed acknowledgement reopen a resolved incident.
  const rank: Record<IncidentStatus, number> = { NEW: 0, ACKNOWLEDGED: 1, ACTION_RECORDED: 2, RESOLVED: 3 };
  return actions.filter(a => a.incidentId === id).reduce<IncidentStatus>((current, action) => rank[action.actionType] > rank[current] ? action.actionType : current, 'NEW');
}
export function metrics(trips: Trip[], incidents: Incident[], actions: OperatorAction[]) {
  const attended = incidents.filter(i => incidentStatus(i.id, actions) !== 'NEW').length;
  return {
    activeTrips: trips.filter(t => t.status === 'ACTIVE').length,
    activeMonitoring: trips.filter(t => t.status === 'ACTIVE' && t.monitoringStatus === 'ACTIVE').length,
    newIncidents: incidents.filter(i => incidentStatus(i.id, actions) === 'NEW').length,
    acknowledged: incidents.filter(i => incidentStatus(i.id, actions) === 'ACKNOWLEDGED').length,
    pending: incidents.filter(i => i.syncStatus && i.syncStatus !== 'SYNCED').length,
    attendedPercent: incidents.length ? Math.round(100 * attended / incidents.length) : null,
  };
}
export function formatTime(time: number | null) {
  return time === null ? 'Pendiente' : new Intl.DateTimeFormat('es-PE', { timeZone: 'America/Lima', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false }).format(time);
}
export function formatDate(time: number) {
  return new Intl.DateTimeFormat('es-PE', { timeZone: 'America/Lima', dateStyle: 'short', timeStyle: 'short' }).format(time);
}
export function isFresh(lastSeenAt: number | null, now: number) { return lastSeenAt !== null && now - lastSeenAt >= 0 && now - lastSeenAt < 120_000; }
