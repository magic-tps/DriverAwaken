import test from 'node:test';
import assert from 'node:assert/strict';
import { alertText, recipients, shouldDispatch } from '../alert-policy.mjs';

test('only warning and critical incidents from active organizations dispatch', () => {
  assert.equal(shouldDispatch({ severity: 'WARNING', driverId: 'd', tripId: 't' }, { status: 'ACTIVE' }), true);
  assert.equal(shouldDispatch({ severity: 'INFO', driverId: 'd', tripId: 't' }, { status: 'ACTIVE' }), false);
  assert.equal(shouldDispatch({ severity: 'CRITICAL', driverId: 'd', tripId: 't' }, { status: 'INACTIVE' }), false);
});

test('recipients are active staff only, deduplicated and never the driver', () => {
  const memberships = new Map([
    ['operator', { role: 'OPERATOR', status: 'ACTIVE' }],
    ['admin', { role: 'ADMIN', status: 'ACTIVE' }],
    ['inactive', { role: 'OPERATOR', status: 'INACTIVE' }],
    ['driver', { role: 'DRIVER', status: 'ACTIVE' }],
  ]);
  const subscriptions = [
    { userId: 'operator', platform: 'WEB', token: 'a' },
    { userId: 'operator', platform: 'WEB', token: 'a' },
    { userId: 'admin', platform: 'WEB', token: 'b' },
    { userId: 'inactive', platform: 'WEB', token: 'c' },
    { userId: 'driver', platform: 'WEB', token: 'd' },
  ];
  assert.deepEqual(recipients(subscriptions, memberships, { severity: 'CRITICAL', driverId: 'driver' }).map(x => x.token), ['a', 'b']);
  assert.deepEqual(recipients(subscriptions, memberships, { severity: 'INFO', driverId: 'driver' }), []);
  assert.match(alertText({ severity: 'CRITICAL' }).body, /parada segura/);
});
