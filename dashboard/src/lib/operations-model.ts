import { isFresh, type Incident, type Membership, type Trip } from './domain';

export function reportedRiskLabel(incident: Incident) {
  return incident.signalQuality === 'RELIABLE' ? `${incident.riskScore}/100` : 'No evaluable';
}

// Use detection order, rather than snapshot order or delayed reception time.
export function latestIncident(incidents: Incident[], tripId: string): Incident | null {
  return incidents.filter(i => i.tripId === tripId).reduce<Incident | null>((latest, i) =>
    !latest || i.detectedAt > latest.detectedAt || (i.detectedAt === latest.detectedAt && i.id > latest.id) ? i : latest, null);
}

export function monitoringObservation(trip: Trip, now: number) {
  if (trip.status !== 'ACTIVE') return { label: 'Sin monitoreo en curso', tone: 'neutral' as const };
  if (trip.monitoringStatus === 'PAUSED') return { label: 'Pausado', tone: 'warning' as const };
  if (trip.monitoringStatus === 'UNAVAILABLE') return { label: 'No disponible', tone: 'warning' as const };
  if (trip.monitoringStatus === 'OFFLINE') return { label: 'Sin conexión reportada', tone: 'warning' as const };
  if (!isFresh(trip.lastSeenAt, now)) return { label: 'Sin señal reciente', tone: 'warning' as const };
  return { label: 'Señal reciente', tone: 'success' as const };
}

export function driverRows(members: Membership[], trips: Trip[], incidents: Incident[]) {
  return members.filter(m => m.role === 'DRIVER').map(member => {
    const assignedTrips = trips.filter(t => t.driverId === member.userId);
    // Prioritize operational trips; a recently created assignment does not hide an active trip.
    const rank = (trip: Trip) => trip.status === 'ACTIVE' ? 2 : trip.status === 'ASSIGNED' ? 1 : 0;
    const trip = assignedTrips.reduce<Trip | null>((latest, item) => !latest || rank(item) > rank(latest) || (rank(item) === rank(latest) && item.startTime > latest.startTime) ? item : latest, null);
    return { member, trip, incident: trip ? latestIncident(incidents, trip.id) : null };
  });
}
