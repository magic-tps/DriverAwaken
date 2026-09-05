// Creates two temporary synthetic accounts and removes them and their report.
// Run explicitly: node scripts/firebase_smoke_test.mjs --live
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { randomBytes } from 'node:crypto';

assert(process.argv.includes('--live'), 'Pass --live to test the configured Firebase project.');
const config = JSON.parse(readFileSync(new URL('../google-services.json', import.meta.url), 'utf8').replace(/^\uFEFF/, ''));
const project = config.project_info.project_id;
assert.equal(project, 'driverawaken', 'Refusing to test an unrelated project.');
const key = config.client[0].api_key[0].current_key;
const authUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:';
const database = `projects/${project}/databases/(default)`;
const firestore = `https://firestore.googleapis.com/v1/${database}/documents`;
const accounts = [];
let reportPath;

async function request(url, method = 'GET', body, token) {
  const response = await fetch(url, {
    method, signal: AbortSignal.timeout(25000),
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  const data = await response.json().catch(() => ({}));
  return { status: response.status, data };
}
function field(value) {
  if (value === null) return { nullValue: null };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') return Number.isInteger(value) ? { integerValue: String(value) } : { doubleValue: value };
  return { stringValue: value };
}
try {
  for (let i = 0; i < 2; i++) {
    const result = await request(`${authUrl}signUp?key=${key}`, 'POST', {
      email: `driverawake-test-${randomBytes(8).toString('hex')}@example.invalid`,
      password: randomBytes(24).toString('base64url'), returnSecureToken: true,
    });
    assert.equal(result.status, 200, `Account creation failed: ${result.data.error?.message}`);
    accounts.push(result.data);
  }
  console.log('PASS: email/password registration');
  const [owner, other] = accounts;
  reportPath = `/users/${owner.localId}/reports/smoke-test`;
  const summary = {
    schemaVersion: 1, tripId: 'synthetic-smoke-test', startedAtMs: 1788600000000,
    endedAtMs: 1788600060000, drivingDurationMs: 60000, warningAlerts: 1,
    dangerAlerts: 0, yawnCount: 1, closedEyeDurationMs: 1000, noFaceEvents: 0,
    averageRisk: 18.5, maxRisk: 40, dominantLevel: 'normal',
    startBatteryLevel: null, endBatteryLevel: null, startTemperatureC: null,
    endTemperatureC: null, maxTemperatureC: null, isCharging: false,
  };
  const write = (data) => ({ writes: [{
    update: { name: database + '/documents' + reportPath, fields: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, field(v)])) },
    updateTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }],
  }] });
  assert.equal((await request(firestore + ':commit', 'POST', write(summary), owner.idToken)).status, 200);
  assert.equal((await request(firestore + ':commit', 'POST', write(summary), owner.idToken)).status, 200);
  const read = await request(firestore + reportPath, 'GET', undefined, owner.idToken);
  assert.equal(read.status, 200);
  assert.equal(read.data.fields.averageRisk.doubleValue, 18.5);
  console.log('PASS: owner can save, update and read a report');
  assert.equal((await request(firestore + reportPath)).status, 403);
  assert.equal((await request(firestore + reportPath, 'GET', undefined, other.idToken)).status, 403);
  assert.equal((await request(firestore + ':commit', 'POST', write(summary), other.idToken)).status, 403);
  assert.equal((await request(firestore + reportPath, 'DELETE', undefined, other.idToken)).status, 403);
  console.log('PASS: unauthenticated and cross-account access denied');
  assert.equal((await request(firestore + ':commit', 'POST', write({ ...summary, image: 'not-allowed' }), owner.idToken)).status, 403);
  assert.equal((await request(firestore + ':commit', 'POST', write({ ...summary, averageRisk: -1 }), owner.idToken)).status, 403);
  console.log('PASS: extra fields and invalid risk rejected');
  const query = await request(`${firestore}/users/${owner.localId}:runQuery`, 'POST', {
    structuredQuery: { from: [{ collectionId: 'reports' }], orderBy: [{ field: { fieldPath: 'startedAtMs' }, direction: 'DESCENDING' }], limit: 100 },
  }, owner.idToken);
  assert.equal(query.status, 200);
  assert.equal(query.data.filter(row => row.document).length, 1);
  console.log('PASS: report listing matches app query');
} finally {
  if (reportPath && accounts[0]) {
    const result = await request(firestore + reportPath, 'DELETE', undefined, accounts[0].idToken);
    assert([200, 404].includes(result.status), 'Test report cleanup failed.');
  }
  for (const account of accounts) {
    const result = await request(`${authUrl}delete?key=${key}`, 'POST', { idToken: account.idToken });
    assert.equal(result.status, 200, 'Test account cleanup failed.');
  }
  console.log('PASS: temporary accounts and report removed');
}
