import test from 'node:test';
import assert from 'node:assert/strict';
import { CoachingAccessError, createMemoryClient, handleCoachingRequest, memoryConfig } from '../coaching-notes.mjs';
import { startAtomicMemoryFixture } from './atomic-memory-fixture.mjs';

const at = millis => ({ toMillis: () => millis });
const docs = {
  'organizations/andes': { status: 'ACTIVE' },
  'organizations/andes/members/ana': { userId: 'ana', organizationId: 'andes', role: 'DRIVER', status: 'ACTIVE' },
  'organizations/andes/members/beto': { userId: 'beto', organizationId: 'andes', role: 'DRIVER', status: 'ACTIVE' },
  'organizations/andes/members/olga': { userId: 'olga', organizationId: 'andes', role: 'OPERATOR', status: 'ACTIVE' },
  'organizations/andes/members/luis': { userId: 'luis', organizationId: 'andes', role: 'DRIVER', status: 'INACTIVE' },
  'organizations/andes/trips/done-ana': { organizationId: 'andes', driverId: 'ana', status: 'COMPLETED', origin: 'Arequipa', destination: 'Puno', startTime: at(Date.UTC(2026, 9, 18, 15)) },
  'organizations/andes/trips/done-ana-2': { organizationId: 'andes', driverId: 'ana', status: 'COMPLETED', origin: 'Puno', destination: 'Arequipa', startTime: at(Date.UTC(2026, 9, 19, 15)) },
  'organizations/andes/trips/active-ana': { organizationId: 'andes', driverId: 'ana', status: 'ACTIVE', origin: 'Arequipa', destination: 'Juliaca', startTime: at(Date.UTC(2026, 9, 20, 15)) },
  'organizations/andes/trips/done-beto': { organizationId: 'andes', driverId: 'beto', status: 'COMPLETED', origin: 'Cusco', destination: 'Puno', startTime: at(Date.UTC(2026, 9, 17, 15)) },
};
const readDoc = async path => docs[path] ?? null;

async function withFixture(run) {
  const fixture = await startAtomicMemoryFixture();
  try { await run(fixture, createMemoryClient({ config: memoryConfig({ ATOMICMEMORY_API_URL: fixture.url, ATOMICMEMORY_API_KEY: fixture.apiKey }), timeoutMs: 300 })); }
  finally { await fixture.close(); }
}
const request = (uid, data, memory) => handleCoachingRequest({ uid, data: { organizationId: 'andes', ...data }, readDoc, memory });
const save = (note, extra = {}) => ({ action: 'save', tripId: 'done-ana', note, consent: true, ...extra });

test('feature stays disabled without both provider settings, and rejects remote plain HTTP', () => {
  assert.equal(memoryConfig({}), null);
  assert.equal(memoryConfig({ ATOMICMEMORY_API_URL: 'https://api.atomicstrata.ai' }), null);
  assert.equal(memoryConfig({ ATOMICMEMORY_API_URL: 'http://memory.example.com', ATOMICMEMORY_API_KEY: 'k' }), null);
  assert.deepEqual(memoryConfig({ ATOMICMEMORY_API_URL: 'https://api.atomicstrata.ai/', ATOMICMEMORY_API_KEY: 'k' }), { url: 'https://api.atomicstrata.ai', apiKey: 'k' });
});

test('disabled deployment answers without contacting any provider', async () => {
  assert.deepEqual(await request('ana', { action: 'list' }, null), { status: 'disabled' });
});

test('a driver saves a post-trip note and recalls it with the trip route on the next visit', () => withFixture(async (fixture, memory) => {
  const saved = await request('ana', save('Tras el turno nocturno, descansar 20 min en Juliaca antes de volver.'), memory);
  assert.equal(saved.status, 'ok');
  const sent = fixture.state.requests.find(item => item.path === '/v1/memories/ingest/quick').body;
  assert.equal(sent.user_id, 'driverawaken:andes:ana');
  assert.equal(sent.skip_extraction, true);
  assert.match(sent.conversation, /Arequipa → Puno/);

  const recalled = await request('ana', { action: 'list' }, memory);
  assert.equal(recalled.status, 'ok');
  assert.equal(recalled.notes.length, 1);
  assert.deepEqual({ ...recalled.notes[0], id: 'x', createdAt: 'x' }, { id: 'x', createdAt: 'x', tripId: 'done-ana', route: 'Arequipa → Puno', note: 'Tras el turno nocturno, descansar 20 min en Juliaca antes de volver.' });
}));

test('notes are isolated per driver: another driver neither sees nor deletes them', () => withFixture(async (_fixture, memory) => {
  await request('ana', save('Hidratarme antes de subir a Santa Lucía.'), memory);
  const [anaNote] = (await request('ana', { action: 'list' }, memory)).notes;
  assert.deepEqual((await request('beto', { action: 'list' }, memory)).notes, []);
  await assert.rejects(request('beto', { action: 'delete', noteId: anaNote.id }, memory), { code: 'failed-precondition' });
  await assert.rejects(request('beto', { action: 'save', tripId: 'done-ana', note: 'Intento ajeno', consent: true }, memory), { code: 'permission-denied' });
  assert.equal((await request('ana', { action: 'list' }, memory)).notes.length, 1);
}));

test('only active drivers with explicit consent may annotate their own completed trips', () => withFixture(async (fixture, memory) => {
  await assert.rejects(request(undefined, { action: 'list' }, memory), { code: 'unauthenticated' });
  await assert.rejects(request('olga', { action: 'list' }, memory), { code: 'permission-denied' });
  await assert.rejects(request('luis', { action: 'list' }, memory), { code: 'permission-denied' });
  await assert.rejects(request('ana', save('Sin consentimiento', { consent: false }), memory), { code: 'failed-precondition' });
  await assert.rejects(request('ana', save('Viaje aún activo', { tripId: 'active-ana' }), memory), { code: 'permission-denied' });
  await assert.rejects(request('ana', save('x'.repeat(281)), memory), CoachingAccessError);
  assert.equal(fixture.memories.length, 0);
}));

test('correcting a note replaces it and deleting removes it', () => withFixture(async (fixture, memory) => {
  await request('ana', save('Parar en Santa Lucía.'), memory);
  const [original] = (await request('ana', { action: 'list' }, memory)).notes;
  const corrected = await request('ana', save('Parar en Imata, no en Santa Lucía.', { replaces: original.id }), memory);
  assert.equal(corrected.status, 'ok');
  assert.deepEqual(corrected.notes.map(note => note.note), ['Parar en Imata, no en Santa Lucía.']);
  const removed = await request('ana', { action: 'delete', noteId: corrected.notes[0].id }, memory);
  assert.deepEqual(removed, { status: 'ok', notes: [] });
  assert.equal(fixture.memories.length, 0);
}));

test('provider outage and timeout report the note as not saved within the time bound', () => withFixture(async (fixture, memory) => {
  fixture.state.mode = 'error';
  const failed = await request('ana', save('Nota durante caída'), memory);
  assert.equal(failed.status, 'unavailable');
  assert.match(failed.message, /no se guardó/);

  fixture.state.mode = 'slow';
  const started = Date.now();
  const slow = await request('ana', { action: 'list' }, memory);
  assert.equal(slow.status, 'unavailable');
  assert.ok(Date.now() - started < 2_000);
  assert.equal(fixture.memories.length, 0);
}));

test('a failed correction keeps the original note', () => withFixture(async (fixture, memory) => {
  await request('ana', save('Original'), memory);
  const [original] = (await request('ana', { action: 'list' }, memory)).notes;
  fixture.state.mode = 'error';
  assert.equal((await request('ana', save('Corrección', { replaces: original.id }), memory)).status, 'unavailable');
  assert.deepEqual(fixture.memories.map(item => item.id), [original.id]);
}));

test('a write without a stored id or readback is reported as unconfirmed and keeps the original', () => withFixture(async (fixture, memory) => {
  await request('ana', save('Original'), memory);
  const [original] = (await request('ana', { action: 'list' }, memory)).notes;
  for (const mode of ['skipped', 'unindexed']) {
    fixture.state.mode = mode;
    const result = await request('ana', save('Corrección ambigua', { replaces: original.id }), memory);
    assert.equal(result.status, 'unconfirmed', mode);
    assert.doesNotMatch(result.message, /guardada\./);
  }
  assert.deepEqual(fixture.memories.map(item => item.id), [original.id]);
}));

test('a correction must stay on the original note trip', () => withFixture(async (fixture, memory) => {
  await request('ana', save('Original'), memory);
  const [original] = (await request('ana', { action: 'list' }, memory)).notes;
  await assert.rejects(request('ana', save('Otro viaje', { tripId: 'done-ana-2', replaces: original.id }), memory), { code: 'invalid-argument' });
  assert.deepEqual(fixture.memories.map(item => item.id), [original.id]);
}));

test('a save that times out is unconfirmed, never reported as saved or as definitely lost', () => withFixture(async (fixture, memory) => {
  fixture.state.mode = 'slow';
  const result = await request('ana', save('Nota lenta'), memory);
  assert.equal(result.status, 'unconfirmed');
}));

test('a 201 ingest with a confirmed readback counts as saved', () => withFixture(async (fixture, memory) => {
  fixture.state.mode = 'created';
  const result = await request('ana', save('Guardada con 201'), memory);
  assert.equal(result.status, 'ok');
  assert.deepEqual(result.notes.map(note => note.note), ['Guardada con 201']);
}));

test('a delete is only reported when the note is really gone', () => withFixture(async (fixture, memory) => {
  await request('ana', save('Persistente'), memory);
  const [note] = (await request('ana', { action: 'list' }, memory)).notes;
  for (const mode of ['retain', 'refuse']) {
    fixture.state.mode = mode;
    const result = await request('ana', { action: 'delete', noteId: note.id }, memory);
    assert.equal(result.status, 'unavailable', mode);
    assert.match(result.message, /No se pudo confirmar que la nota se eliminó/);
  }
  fixture.state.mode = 'retain';
  const corrected = await request('ana', save('Corregida', { replaces: note.id }), memory);
  assert.equal(corrected.status, 'partial');
  assert.equal(fixture.memories.length, 2);
}));

test('provider URLs that could leak the key disable the feature', () => {
  for (const url of ['https://user:pw@api.atomicstrata.ai', 'https://api.atomicstrata.ai/?x=1', 'https://api.atomicstrata.ai/#f']) {
    assert.equal(memoryConfig({ ATOMICMEMORY_API_URL: url, ATOMICMEMORY_API_KEY: 'k' }), null, url);
  }
});

test('redirects are refused so the bearer key never follows them', async () => {
  const { createServer } = await import('node:http');
  const server = createServer((_req, res) => { res.writeHead(307, { Location: 'http://127.0.0.1:9/steal' }); res.end(); });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  try {
    const memory = createMemoryClient({ config: memoryConfig({ ATOMICMEMORY_API_URL: `http://127.0.0.1:${server.address().port}`, ATOMICMEMORY_API_KEY: 'k' }), timeoutMs: 500 });
    assert.equal((await request('ana', { action: 'list' }, memory)).status, 'unavailable');
  } finally { server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); }
});
