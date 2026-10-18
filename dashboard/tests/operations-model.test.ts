import { describe, expect, it } from 'vitest';
import { demoReducer, initialDemo } from '../src/lib/demo';
import type { Membership, OperatorAction } from '../src/lib/domain';
import { driverRows, latestIncident, monitoringObservation, reportedRiskLabel } from '../src/lib/operations-model';
import { EMPTY_INCIDENT_FILTERS, filterIncidents, incidentAnalytics, limaDay } from '../src/lib/reports';

const started = demoReducer(initialDemo(), { type: 'START_TRIP' });
const scenario = demoReducer(started, { type: 'CRITICAL' });
const trip = scenario.trip;
const incident = scenario.incidents[0];

describe('operational observations from received records', () => {
  it('does not interpret an unavailable signal and its contract score of zero as a low risk observation', () => {
    expect(reportedRiskLabel(incident)).toBe('85/100');
    expect(reportedRiskLabel({ ...incident, signalQuality: 'INSUFFICIENT', riskScore: 0 })).toBe('No evaluable');
  });
  it('never describes completed, assigned, stale or future observations as ongoing monitoring', () => {
    expect(monitoringObservation(trip, trip.lastSeenAt!).tone).toBe('success');
    expect(monitoringObservation({ ...trip, status: 'COMPLETED' }, trip.lastSeenAt!).tone).toBe('neutral');
    expect(monitoringObservation({ ...trip, status: 'ASSIGNED' }, trip.lastSeenAt!).tone).toBe('neutral');
    expect(monitoringObservation(trip, trip.lastSeenAt! + 120_000).label).toBe('Sin señal reciente');
    expect(monitoringObservation(trip, trip.lastSeenAt! - 1).label).toBe('Sin señal reciente');
    expect(monitoringObservation({ ...trip, monitoringStatus: 'OFFLINE' }, trip.lastSeenAt!).tone).toBe('warning');
  });
  it('selects the latest detection within a trip despite delayed receipt and unordered input', () => {
    const late = { ...incident, id: 'late', detectedAt: incident.detectedAt - 1, receivedAt: incident.detectedAt + 999_000 };
    expect(latestIncident([late, { ...incident, tripId: 'another' }, incident], trip.id)).toBe(incident);
    expect(latestIncident([incident], 'missing')).toBeNull();
  });
  it('lists actual DRIVER memberships and prioritizes an active trip over a newer assignment', () => {
    const driver: Membership = { userId: trip.driverId, organizationId: trip.organizationId, role: 'DRIVER', status: 'ACTIVE' };
    const rows = driverRows([driver, { ...driver, userId: 'operator', role: 'OPERATOR' }, { ...driver, userId: 'unassigned' }], [{ ...trip, id: 'new', status: 'ASSIGNED', startTime: trip.startTime + 90_000 }, trip], [incident]);
    expect(rows).toHaveLength(2);
    expect(rows[0].trip?.id).toBe(trip.id);
    expect(rows[0].incident).toBe(incident);
    expect(rows[1].trip).toBeNull();
  });
});

describe('filtered operational report scope', () => {
  it('uses Lima dates on both sides of midnight and inclusive date bounds', () => {
    const beforeMidnight = Date.UTC(2026, 9, 18, 4, 59, 59);
    const midnight = Date.UTC(2026, 9, 18, 5);
    expect(limaDay(beforeMidnight)).toBe('2026-10-17');
    expect(limaDay(midnight)).toBe('2026-10-18');
    const events = [{ ...incident, id: 'before', detectedAt: beforeMidnight }, { ...incident, id: 'after', detectedAt: midnight }];
    expect(filterIncidents(events, [trip], { ...EMPTY_INCIDENT_FILTERS, from: '2026-10-17', to: '2026-10-17' }).map(i => i.id)).toEqual(['before']);
  });
  it('intersects every filter and excludes missing vehicle associations without inventing records', () => {
    const filters = { ...EMPTY_INCIDENT_FILTERS, vehicleId: trip.vehicleId, driverId: trip.driverId, tripId: trip.id, severity: incident.severity, type: incident.type };
    expect(filterIncidents([incident, { ...incident, id: 'other', driverId: 'another' }], [trip], filters)).toEqual([incident]);
    expect(filterIncidents([incident], [], filters)).toEqual([]);
    expect(filterIncidents([incident], [trip], { ...filters, severity: 'INFO' })).toEqual([]);
  });
  it('calculates first valid acknowledgement delay per filtered event, ignoring unrelated and invalid actions', () => {
    const action: OperatorAction = { id: 'a', organizationId: trip.organizationId, incidentId: incident.id, operatorId: 'operator', actionType: 'ACKNOWLEDGED', note: 'Confirmado', createdAt: incident.detectedAt + 60_000 };
    const analytics = incidentAnalytics([incident], [action, { ...action, id: 'b', createdAt: incident.detectedAt + 30_000 }, { ...action, id: 'future', createdAt: incident.detectedAt - 1 }, { ...action, id: 'another', incidentId: 'another' }]);
    expect(analytics.meanAcknowledgementMs).toBe(30_000);
    expect(analytics.acknowledgedCount).toBe(1);
    expect(incidentAnalytics([incident], []).meanAcknowledgementMs).toBeNull();
    expect(incidentAnalytics([], [action]).critical).toBe(0);
  });
});
