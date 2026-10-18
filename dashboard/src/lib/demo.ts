import { TYPE_LABELS, type ActionType, type Incident, type IncidentType, type OperatorAction, type Trip } from './domain';

export const DEMO_STORAGE_KEY = 'guardian.demo.v2';
export const DEMO_EPOCH = Date.UTC(2026, 9, 17, 13, 0, 0);
export const DEMO_DESTINATIONS = [{ id: 'juliaca', name: 'Juliaca' }, { id: 'huancayo', name: 'Huancayo' }, { id: 'ica', name: 'Ica' }] as const;
export const DEMO_PLACES = [
  { id: 'rest-demo-01', name: 'Área Demo de Descanso', category: 'Área de descanso ficticia', description: 'Estacionamiento y acceso para bus: condiciones simuladas.' },
  { id: 'rest-demo-02', name: 'Terminal Demo Ruta Sur', category: 'Terminal ficticio', description: 'Servicios y disponibilidad simulados. No es un lugar real.' },
] as const;
export interface DemoRestSession { id: string; tripId: string; startedAt: number; endedAt: number | null; durationMs: number | null; recommendationReason: string; voluntarilyConfirmed: true; placeId: string | null }
export interface TimelineEntry { id: string; at: number; message: string; kind: 'normal' | 'warning' | 'critical' | 'sync' | 'action' }
export interface DemoState {
  version: 2; clock: number; sequence: number; online: boolean; finished: boolean;
  trip: Trip; incidents: Incident[]; actions: OperatorAction[]; timeline: TimelineEntry[];
  cooldowns: Partial<Record<IncidentType, number>>; notice: string;
  destinationId: string; selectedPlaceId: string | null; restRecommendation: string | null; rests: DemoRestSession[];
}
export type DemoEvent =
  | { type: 'NORMAL' } | { type: 'CAUTION' } | { type: 'CRITICAL' }
  | { type: 'DISCONNECT' } | { type: 'RECONNECT' } | { type: 'FINISH' } | { type: 'RESET' }
  | { type: 'START_TRIP' } | { type: 'DESTINATION_SELECTED'; destinationId: string }
  | { type: 'REQUEST_REST' } | { type: 'PLACE_SELECTED'; placeId: string }
  | { type: 'START_REST'; confirmed: boolean } | { type: 'END_REST' }
  | { type: 'ACTION'; incidentId: string; actionType: ActionType; note: string; attemptId: string };

export function initialDemo(): DemoState {
  return {
    version: 2, clock: DEMO_EPOCH, sequence: 0, online: true, finished: false,
    trip: { id: 'trip-demo-001', organizationId: 'andes-demo', vehicleId: 'BUS-001', driverId: 'driver-demo-01', origin: 'Arequipa', destination: 'Juliaca', startTime: DEMO_EPOCH, endTime: null, status: 'ASSIGNED', monitoringStatus: 'PAUSED', lastEventAt: null, lastSeenAt: null },
    incidents: [], actions: [], cooldowns: {}, notice: 'Selecciona un destino e inicia el viaje simulado para comenzar.',
    destinationId: 'juliaca', selectedPlaceId: null, restRecommendation: null, rests: [],
    timeline: [{ id: 'timeline-0', at: DEMO_EPOCH, message: 'Escenario listo · inicia el viaje simulado', kind: 'normal' }],
  };
}
export function demoReducer(previous: DemoState, event: DemoEvent): DemoState {
  if (event.type === 'RESET') return initialDemo();
  if (event.type === 'ACTION' && previous.actions.some(a => a.id === event.attemptId)) return previous;
  if (previous.finished && event.type !== 'ACTION' && event.type !== 'RECONNECT') return { ...previous, notice: 'Escenario finalizado. Reinicia para comenzar otro viaje.' };
  const state: DemoState = { ...previous, clock: previous.clock + 30_000, sequence: previous.sequence + 1, trip: { ...previous.trip }, timeline: [...previous.timeline], cooldowns: { ...previous.cooldowns } };
  const log = (message: string, kind: TimelineEntry['kind'] = 'normal') => {
    state.timeline = [{ id: `timeline-${state.sequence}`, at: state.clock, message, kind }, ...state.timeline].slice(0, 120);
    state.notice = message;
  };
  const activeRest = state.rests.find(rest => rest.endedAt === null);
  if (['NORMAL', 'CAUTION', 'CRITICAL', 'REQUEST_REST', 'START_REST'].includes(event.type) && (state.trip.status !== 'ACTIVE' || (activeRest && event.type !== 'REQUEST_REST'))) {
    log(activeRest ? 'Descanso simulado activo · termina el descanso antes de reanudar las señales.' : 'Inicia el viaje simulado para continuar.'); return state;
  }
  switch (event.type) {
    case 'START_TRIP':
      if (state.trip.status === 'ACTIVE') { log('El viaje simulado ya está activo.'); break; }
      state.trip.status = 'ACTIVE'; state.trip.monitoringStatus = 'ACTIVE'; state.trip.startTime = state.clock;
      state.trip.lastSeenAt = state.online ? state.clock : null;
      log('Viaje simulado iniciado · monitoreo local activo');
      break;
    case 'DESTINATION_SELECTED': {
      const destination = DEMO_DESTINATIONS.find(d => d.id === event.destinationId);
      if (!destination || activeRest) { log('Destino no disponible o descanso en curso.', 'warning'); break; }
      state.destinationId = destination.id; state.trip.destination = destination.name; state.selectedPlaceId = null;
      log(`Destino simulado seleccionado: ${destination.name} · esquema ficticio, sin ruta de un proveedor`);
      break;
    }
    case 'REQUEST_REST':
      state.restRecommendation = 'Solicitud voluntaria de pausa. Busca un lugar seguro para detenerte.';
      log('Recomendación manual de descanso · lugares ficticios disponibles', 'warning');
      break;
    case 'PLACE_SELECTED':
      if (!DEMO_PLACES.some(p => p.id === event.placeId) || !state.restRecommendation || activeRest) { log('Selecciona una opción del catálogo ficticio después de solicitar una pausa.', 'warning'); break; }
      state.selectedPlaceId = event.placeId;
      log('Lugar ficticio seleccionado · no se inició ni se confirmó un descanso');
      break;
    case 'START_REST':
      if (state.rests.length >= 100) { log('Límite de 100 descansos simulados. Reinicia el escenario.', 'warning'); break; }
      if (!event.confirmed || !state.restRecommendation) { log('Confirma voluntariamente el inicio del descanso simulado.', 'warning'); break; }
      state.rests = [...state.rests, { id: `demo-rest-${state.sequence}`, tripId: state.trip.id, startedAt: state.clock, endedAt: null, durationMs: null, recommendationReason: state.restRecommendation, voluntarilyConfirmed: true, placeId: state.selectedPlaceId }];
      state.trip.monitoringStatus = 'PAUSED';
      log('Descanso simulado iniciado por confirmación voluntaria · monitoreo pausado', 'action');
      break;
    case 'END_REST':
      if (!activeRest) { log('No hay un descanso simulado en curso.'); break; }
      state.rests = state.rests.map(rest => rest.id === activeRest.id ? { ...rest, endedAt: state.clock, durationMs: state.clock - rest.startedAt } : rest);
      state.trip.monitoringStatus = 'ACTIVE'; state.trip.lastSeenAt = state.online ? state.clock : state.trip.lastSeenAt;
      state.restRecommendation = null; state.selectedPlaceId = null;
      log('Descanso simulado finalizado · duración registrada sin inferir recuperación fisiológica', 'action');
      break;
    case 'NORMAL':
      state.trip.monitoringStatus = 'ACTIVE';
      state.trip.lastSeenAt = state.online ? state.clock : state.trip.lastSeenAt;
      log('Conducción normal simulada · señal fiable · sin nuevo incidente');
      break;
    case 'CAUTION':
    case 'CRITICAL': {
      const type = event.type === 'CRITICAL' ? 'PROLONGED_EYE_CLOSURE' : 'REPEATED_YAWNING';
      const last = state.cooldowns[type];
      if (last !== undefined && state.clock - last < 90_000) {
        log('Señal repetida agrupada: cooldown de 90 s · sin duplicar incidente', 'warning');
        break;
      }
      if (state.incidents.length >= 100) { log('Límite de 100 incidentes demo. Reinicia el escenario.', 'warning'); break; }
      const incident: Incident = {
        id: `demo-incident-${String(state.sequence).padStart(4, '0')}`, organizationId: 'andes-demo', tripId: state.trip.id,
        driverId: state.trip.driverId, type, severity: event.type === 'CRITICAL' ? 'CRITICAL' : 'WARNING',
        detectedAt: state.clock, receivedAt: state.online ? state.clock : null, riskScore: event.type === 'CRITICAL' ? 85 : 45,
        reasonCode: event.type === 'CRITICAL' ? 'DEMO_SUSTAINED_CLOSURE' : 'DEMO_REPEATED_YAWNS',
        signalQuality: 'RELIABLE', monitoringHealth: 'HEALTHY', syncStatus: state.online ? 'SYNCED' : 'QUEUED',
      };
      state.incidents = [incident, ...state.incidents];
      state.cooldowns[type] = state.clock;
      state.restRecommendation = event.type === 'CRITICAL' ? 'Señal crítica simulada: detente de manera segura. No continúes conduciendo para buscar café.' : 'Señales de precaución simuladas: planifica una parada segura y sigue el protocolo de tu flota.';
      state.trip.lastEventAt = state.clock;
      state.trip.lastSeenAt = state.online ? state.clock : state.trip.lastSeenAt;
      log(`${event.type === 'CRITICAL' ? 'Cierre ocular prolongado' : 'Bostezos repetidos'} · alerta local simulada · ${state.online ? 'recibido en central' : 'guardado en outbox local'}`, event.type === 'CRITICAL' ? 'critical' : 'warning');
      break;
    }
    case 'DISCONNECT':
      state.online = false;
      log('Sin conexión con la central · monitoreo y alertas locales continúan', 'sync');
      break;
    case 'RECONNECT': {
      state.online = true;
      const queued = state.incidents.filter(i => i.syncStatus === 'QUEUED').length;
      state.incidents = state.incidents.map(i => i.syncStatus === 'QUEUED' ? { ...i, receivedAt: state.clock, syncStatus: 'SYNCED' } : i);
      state.trip.lastSeenAt = state.clock;
      log(`Conexión restaurada · ${queued} incidente${queued === 1 ? '' : 's'} sincronizado${queued === 1 ? '' : 's'} con sus IDs originales`, 'sync');
      break;
    }
    case 'ACTION': {
      if (state.actions.length >= 1000) { log('Limite de 1000 acciones demo. Reinicia el escenario.', 'warning'); break; }
      const incident = state.incidents.find(i => i.id === event.incidentId);
      if (!incident || incident.syncStatus !== 'SYNCED') { log('La central necesita recibir el incidente antes de registrar una acción.', 'warning'); break; }
      if (!event.attemptId || event.attemptId.length > 200 || !event.note.trim() || event.note.length > 1000) { log('Escribe una nota de 1 a 1000 caracteres.', 'warning'); break; }
      state.actions = [...state.actions, { id: event.attemptId, organizationId: 'andes-demo', incidentId: incident.id, operatorId: 'operator-demo', actionType: event.actionType, note: event.note.trim(), createdAt: state.clock }];
      log(event.actionType === 'ACKNOWLEDGED' ? 'Incidente reconocido por la central' : event.actionType === 'RESOLVED' ? 'Incidente resuelto · evidencia original conservada' : 'Acción humana registrada en el historial', 'action');
      break;
    }
    case 'FINISH':
      if (activeRest) { log('Termina el descanso simulado antes de finalizar el escenario.', 'warning'); break; }
      state.finished = true;
      state.trip.status = 'COMPLETED'; state.trip.monitoringStatus = 'PAUSED'; state.trip.endTime = state.clock;
      log('Escenario finalizado · monitoreo pausado · historial conservado');
      break;
  }
  return state;
}
export function restoreDemo(raw: string | null): DemoState {
  if (!raw) return initialDemo();
  try {
    const state: unknown = JSON.parse(raw);
    if (!state || typeof state !== 'object') return initialDemo();
    const s = state as DemoState;
    if (s.version !== 2 || !Number.isFinite(s.clock) || s.clock < DEMO_EPOCH || !Number.isInteger(s.sequence) || s.sequence < 0 || typeof s.online !== 'boolean' || typeof s.finished !== 'boolean' || !s.trip || s.trip.id !== 'trip-demo-001' || !Array.isArray(s.incidents) || s.incidents.length > 100 || !Array.isArray(s.actions) || !Array.isArray(s.timeline) || !s.cooldowns || typeof s.notice !== 'string') return initialDemo();
    if (typeof s.trip.origin !== 'string' || typeof s.trip.destination !== 'string' || !Number.isFinite(s.trip.startTime) || !['ASSIGNED', 'ACTIVE', 'COMPLETED'].includes(s.trip.status) || !['ACTIVE', 'PAUSED'].includes(s.trip.monitoringStatus) || s.timeline.length > 120 || s.actions.length > 1000 || !DEMO_DESTINATIONS.some(d => d.id === s.destinationId) || !Array.isArray(s.rests) || s.rests.length > 100 || !(s.restRecommendation === null || typeof s.restRecommendation === 'string') || !(s.selectedPlaceId === null || DEMO_PLACES.some(p => p.id === s.selectedPlaceId))) return initialDemo();
    if (s.rests.filter(r => r.endedAt === null).length > 1 || new Set(s.rests.map(r => r.id)).size !== s.rests.length || !s.rests.every(r => r && typeof r.id === 'string' && r.tripId === s.trip.id && Number.isFinite(r.startedAt) && (r.endedAt === null ? r.durationMs === null : Number.isFinite(r.endedAt) && r.endedAt >= r.startedAt && r.durationMs === r.endedAt - r.startedAt) && r.voluntarilyConfirmed === true && typeof r.recommendationReason === 'string')) return initialDemo();
    if (!s.incidents.every(i => i && typeof i.id === 'string' && Object.hasOwn(TYPE_LABELS, i.type) && Number.isFinite(i.detectedAt) && (i.receivedAt === null || Number.isFinite(i.receivedAt)) && Number.isFinite(i.riskScore) && i.riskScore >= 0 && i.riskScore <= 100 && ['WARNING', 'CRITICAL', 'INFO'].includes(i.severity) && ['QUEUED', 'SYNCED'].includes(i.syncStatus ?? '')) || !s.actions.every(a => a && typeof a.id === 'string' && typeof a.note === 'string' && Number.isFinite(a.createdAt) && ['ACKNOWLEDGED', 'ACTION_RECORDED', 'RESOLVED'].includes(a.actionType)) || !s.timeline.every(e => e && typeof e.message === 'string' && Number.isFinite(e.at))) return initialDemo();
    return s;
  } catch { return initialDemo(); }
}
