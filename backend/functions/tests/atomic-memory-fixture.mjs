// LOCAL TEST FIXTURE — not Atomic Memory. Implements only the three documented
// atomicmemory-core routes used by coaching-notes.mjs, scoped by user_id, on 127.0.0.1.
import { createServer } from 'node:http';
import { randomUUID } from 'node:crypto';
import { pathToFileURL } from 'node:url';

export async function startAtomicMemoryFixture({ apiKey = 'fixture-key', port = 0 } = {}) {
  const memories = [];
  const state = { mode: 'ok', requests: [] };
  const server = createServer(async (req, res) => {
    const url = new URL(req.url, 'http://127.0.0.1');
    let raw = '';
    for await (const chunk of req) raw += chunk;
    state.requests.push({ method: req.method, path: url.pathname, query: Object.fromEntries(url.searchParams), body: raw ? JSON.parse(raw) : null });
    const send = (status, body) => { res.writeHead(status, { 'Content-Type': 'application/json' }); res.end(JSON.stringify(body)); };
    if (req.headers.authorization !== `Bearer ${apiKey}`) return send(401, { error: 'unauthorized' });
    if (state.mode === 'error') return send(503, { error: 'fixture outage', retryable: true });
    if (state.mode === 'slow') await new Promise(resolve => setTimeout(resolve, 5_000));
    if (req.method === 'POST' && url.pathname === '/v1/memories/ingest/quick') {
      const body = JSON.parse(raw);
      if (!body.user_id || !body.conversation || !body.source_site) return send(400, { error: 'user_id, conversation and source_site are required' });
      const memory = { id: randomUUID(), user_id: body.user_id, content: body.conversation, source_site: body.source_site, metadata: body.metadata ?? {}, created_at: new Date(Date.now() + memories.length).toISOString() };
      // 'skipped' mimics a deduplicated write with no stored id; 'unindexed' returns an id that never appears in list.
      if (state.mode === 'skipped') return send(200, { episode_id: randomUUID(), facts_extracted: 0, memories_stored: 0, memories_updated: 0, memories_deleted: 0, memories_skipped: 1, stored_memory_ids: [], updated_memory_ids: [], links_created: 0, composites_created: 0 });
      if (state.mode !== 'unindexed') memories.push(memory);
      return send(state.mode === 'created' ? 201 : 200, { episode_id: randomUUID(), facts_extracted: 0, memories_stored: 1, memories_updated: 0, memories_deleted: 0, memories_skipped: 0, stored_memory_ids: [memory.id], updated_memory_ids: [], links_created: 0, composites_created: 0 });
    }
    if (req.method === 'GET' && url.pathname === '/v1/memories/list') {
      const user = url.searchParams.get('user_id');
      if (!user) return send(400, { error: 'user_id (string) is required' });
      const site = url.searchParams.get('source_site');
      const found = memories.filter(item => item.user_id === user && (!site || item.source_site === site));
      return send(200, { memories: found, count: found.length });
    }
    const match = /^\/v1\/memories\/([^/]+)$/.exec(url.pathname);
    if (req.method === 'DELETE' && match) {
      const index = memories.findIndex(item => item.id === match[1] && item.user_id === url.searchParams.get('user_id'));
      if (index < 0) return send(404, { error: 'Memory not found' });
      // 'retain' answers success but keeps the record; 'refuse' answers 200 with success:false.
      if (state.mode === 'retain') return send(200, { success: true });
      if (state.mode === 'refuse') return send(200, { success: false });
      memories.splice(index, 1);
      return send(200, { success: true });
    }
    return send(404, { error: 'not found' });
  });
  await new Promise(resolve => server.listen(port, '127.0.0.1', resolve));
  const { port: actual } = server.address();
  return {
    url: `http://127.0.0.1:${actual}`, apiKey, memories, state,
    close: () => new Promise(resolve => { server.closeAllConnections(); server.close(resolve); }),
  };
}

// Manual demos: node tests/atomic-memory-fixture.mjs 4717
if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const fixture = await startAtomicMemoryFixture({ port: Number(process.argv[2] ?? 4717) });
  console.log(`LOCAL Atomic Memory TEST FIXTURE (not the real service) on ${fixture.url}`);
}
