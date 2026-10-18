import { describe, expect, it } from 'vitest';
import { DEMO_EPOCH, demoReducer, initialDemo, restoreDemo, type DemoEvent } from '../src/lib/demo';
import { incidentStatus, isFresh, metrics } from '../src/lib/domain';
const run = (events: DemoEvent[]) => events.reduce(demoReducer, demoReducer(initialDemo(), { type: 'START_TRIP' }));

describe('isolated deterministic public demo', () => {
  it('replays an identical typed scenario with identical IDs and logical timestamps', () => {
    const events: DemoEvent[] = [{ type: 'NORMAL' }, { type: 'DISCONNECT' }, { type: 'CRITICAL' }, { type: 'RECONNECT' }];
    expect(run(events)).toEqual(run(events));
    expect(run(events).clock).toBe(DEMO_EPOCH + 150_000);
  });
  it('persists an offline event and receives it later with its original identity and detection time', () => {
    const offline = run([{ type: 'DISCONNECT' }, { type: 'CRITICAL' }]);
    expect(offline.incidents[0].syncStatus).toBe('QUEUED');
    expect(offline.incidents[0].receivedAt).toBeNull();
    const restored = restoreDemo(JSON.stringify(offline));
    const online = demoReducer(restored, { type: 'RECONNECT' });
    expect(online.incidents).toHaveLength(1);
    expect(online.incidents[0].id).toBe(offline.incidents[0].id);
    expect(online.incidents[0].detectedAt).toBe(offline.incidents[0].detectedAt);
    expect(online.incidents[0].receivedAt).toBeGreaterThan(online.incidents[0].detectedAt);
    expect(online.incidents[0].syncStatus).toBe('SYNCED');
    expect(demoReducer(online, { type: 'RECONNECT' }).incidents).toEqual(online.incidents);
  });
  it('groups repeated signals inside the cooldown but permits another event after 90 seconds', () => {
    const first = run([{ type: 'CRITICAL' }, { type: 'CRITICAL' }]);
    expect(first.incidents).toHaveLength(1);
    expect(first.notice).toContain('cooldown');
    const second = demoReducer(demoReducer(first, { type: 'NORMAL' }), { type: 'CRITICAL' });
    expect(second.incidents).toHaveLength(2);
    expect(new Set(second.incidents.map(i => i.id)).size).toBe(2);
  });
  it('continues local monitoring and normal signals without central connectivity', () => {
    const state = run([{ type: 'DISCONNECT' }, { type: 'NORMAL' }]);
    expect(state.online).toBe(false);
    expect(state.trip.monitoringStatus).toBe('ACTIVE');
    expect(state.incidents).toHaveLength(0);
    expect(state.trip.lastSeenAt).toBe(DEMO_EPOCH + 30_000);
  });
  it('rejects operator actions until the central receives an incident', () => {
    const state = run([{ type: 'DISCONNECT' }, { type: 'CRITICAL' }]);
    const next = demoReducer(state, { type: 'ACTION', incidentId: state.incidents[0].id, actionType: 'ACKNOWLEDGED', note: 'Recibido', attemptId: 'action-1' });
    expect(next.actions).toHaveLength(0);
  });
  it('appends human responses without mutating detection, deduplicates stable action attempts', () => {
    const detected = run([{ type: 'CRITICAL' }]);
    const before = JSON.stringify(detected.incidents[0]);
    const action: DemoEvent = { type: 'ACTION', incidentId: detected.incidents[0].id, actionType: 'ACKNOWLEDGED', note: 'La central recibió el evento', attemptId: 'action-1' };
    const acknowledged = demoReducer(detected, action);
    expect(acknowledged.actions).toHaveLength(1);
    expect(JSON.stringify(acknowledged.incidents[0])).toBe(before);
    expect(demoReducer(acknowledged, action)).toBe(acknowledged);
    expect(incidentStatus(detected.incidents[0].id, acknowledged.actions)).toBe('ACKNOWLEDGED');
  });
  it('prevents empty operator notes', () => {
    const state = run([{ type: 'CRITICAL' }]);
    expect(demoReducer(state, { type: 'ACTION', incidentId: state.incidents[0].id, actionType: 'ACTION_RECORDED', note: '   ', attemptId: 'empty' }).actions).toHaveLength(0);
  });
  it('completes a trip without deleting offline pending incidents and lets them sync afterward', () => {
    const state = run([{ type: 'DISCONNECT' }, { type: 'CRITICAL' }, { type: 'FINISH' }]);
    expect(state.trip.status).toBe('COMPLETED');
    expect(state.trip.monitoringStatus).toBe('PAUSED');
    expect(state.incidents[0].syncStatus).toBe('QUEUED');
    expect(demoReducer(state, { type: 'CRITICAL' }).incidents).toHaveLength(1);
    expect(demoReducer(state, { type: 'RECONNECT' }).incidents[0].syncStatus).toBe('SYNCED');
    expect(demoReducer(state, { type: 'RESET' })).toEqual(initialDemo());
  });
  it('recovers safely from missing, corrupt and wrong-version persisted state', () => {
    for (const raw of [null, '{', '{}', 'null', JSON.stringify({ ...initialDemo(), version: 99 }), JSON.stringify({ ...initialDemo(), clock: 'wrong' })]) expect(restoreDemo(raw)).toEqual(initialDemo());
  });
  it('does not call an empty dataset 0% attended or invent pending remote outbox size', () => {
    expect(metrics([], [], []).attendedPercent).toBeNull();
    const state = run([{ type: 'DISCONNECT' }, { type: 'CAUTION' }, { type: 'CRITICAL' }]);
    expect(metrics([state.trip], state.incidents, []).pending).toBe(2);
    expect(metrics([state.trip], state.incidents, []).newIncidents).toBe(2);
  });
  it('marks heartbeat as stale independently of active trip state', () => {
    expect(isFresh(null, DEMO_EPOCH)).toBe(false);
    expect(isFresh(DEMO_EPOCH, DEMO_EPOCH + 119_000)).toBe(true);
    expect(isFresh(DEMO_EPOCH, DEMO_EPOCH + 120_000)).toBe(false);
    expect(isFresh(DEMO_EPOCH + 5000, DEMO_EPOCH)).toBe(false);
  });
});
