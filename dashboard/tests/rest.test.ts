import { describe, expect, it } from 'vitest';
import { demoReducer, initialDemo, restoreDemo } from '../src/lib/demo';
describe('synthetic destinations and confirmed rest sessions', () => {
  it('requires explicit trip start and validates destination identity', () => {
    const initial = initialDemo();
    expect(initial.trip.monitoringStatus).toBe('PAUSED');
    expect(demoReducer(initial, { type: 'CRITICAL' }).incidents).toHaveLength(0);
    const destination = demoReducer(initial, { type: 'DESTINATION_SELECTED', destinationId: 'ica' });
    expect(destination.trip.destination).toBe('Ica');
    expect(demoReducer(destination, { type: 'DESTINATION_SELECTED', destinationId: 'invented' }).trip.destination).toBe('Ica');
    expect(demoReducer(destination, { type: 'START_TRIP' }).trip.monitoringStatus).toBe('ACTIVE');
  });
  it('critical local alert and recommendation appear even offline without a place search', () => {
    const started = demoReducer(initialDemo(), { type: 'START_TRIP' });
    const state = demoReducer(demoReducer(started, { type: 'DISCONNECT' }), { type: 'CRITICAL' });
    expect(state.incidents[0].syncStatus).toBe('QUEUED');
    expect(state.restRecommendation).toContain('detente de manera segura');
    expect(state.selectedPlaceId).toBeNull();
    expect(state.rests).toEqual([]);
  });
  it('selecting a synthetic place never implies a rest and voluntary confirmation is required', () => {
    const started = demoReducer(initialDemo(), { type: 'START_TRIP' });
    const recommendation = demoReducer(started, { type: 'REQUEST_REST' });
    const selected = demoReducer(recommendation, { type: 'PLACE_SELECTED', placeId: 'rest-demo-01' });
    expect(selected.selectedPlaceId).toBe('rest-demo-01');
    expect(selected.rests).toHaveLength(0);
    const denied = demoReducer(selected, { type: 'START_REST', confirmed: false });
    expect(denied.rests).toHaveLength(0);
    expect(denied.trip.monitoringStatus).toBe('ACTIVE');
    const confirmed = demoReducer(denied, { type: 'START_REST', confirmed: true });
    expect(confirmed.rests[0].voluntarilyConfirmed).toBe(true);
    expect(confirmed.trip.monitoringStatus).toBe('PAUSED');
    expect(confirmed.rests[0].endedAt).toBeNull();
  });
  it('rest persists offline, pauses monitoring and ends only with an explicit action', () => {
    let state = demoReducer(initialDemo(), { type: 'START_TRIP' });
    state = demoReducer(state, { type: 'DISCONNECT' });
    state = demoReducer(state, { type: 'CAUTION' });
    state = demoReducer(state, { type: 'START_REST', confirmed: true });
    const id = state.rests[0].id;
    state = restoreDemo(JSON.stringify(state));
    expect(demoReducer(state, { type: 'CRITICAL' }).incidents).toHaveLength(1);
    expect(demoReducer(state, { type: 'FINISH' }).finished).toBe(false);
    const ended = demoReducer(state, { type: 'END_REST' });
    expect(ended.rests[0].id).toBe(id);
    expect(ended.rests[0].durationMs).toBe(30_000);
    expect(ended.trip.monitoringStatus).toBe('ACTIVE');
    expect(ended.online).toBe(false);
    expect(ended.incidents[0].syncStatus).toBe('QUEUED');
    expect(demoReducer(ended, { type: 'END_REST' }).rests).toEqual(ended.rests);
  });
});
