// Optional post-trip coaching notes stored in Atomic Memory.
// Independent of detection, alerts and incident handling: nothing here is read by those paths.
// The memory subject is derived from the verified Firebase uid and a server-checked DRIVER membership.

export const SOURCE_SITE = 'driverawaken-coaching';
export const NOTE_MAX_LENGTH = 280;
export const LIST_LIMIT = 20;
// A correction makes at most five provider calls; 5 × 2.5 s stays below the 15 s client timeout.
const REQUEST_TIMEOUT_MS = 2_500;
const idPattern = /^[a-zA-Z0-9_-]{1,128}$/;
const memoryIdPattern = /^[a-zA-Z0-9-]{1,64}$/;

export class CoachingAccessError extends Error {
  constructor(code, message) { super(message); this.code = code; }
}
class ProviderError extends Error {}

// Missing configuration disables the feature; it never falls back to another store.
export function memoryConfig(env) {
  const url = typeof env.ATOMICMEMORY_API_URL === 'string' ? env.ATOMICMEMORY_API_URL.trim().replace(/\/+$/, '') : '';
  const apiKey = typeof env.ATOMICMEMORY_API_KEY === 'string' ? env.ATOMICMEMORY_API_KEY.trim() : '';
  if (!url || !apiKey) return null;
  let parsed;
  try { parsed = new URL(url); } catch { return null; }
  const loopback = parsed.hostname === '127.0.0.1' || parsed.hostname === 'localhost';
  if (parsed.protocol !== 'https:' && !(parsed.protocol === 'http:' && loopback)) return null;
  // The key is sent as a bearer token; refuse URLs that could leak or redirect it.
  if (parsed.username || parsed.password || parsed.search || parsed.hash) return null;
  return { url, apiKey };
}

// One subject per driver and organization; never shared with staff or other drivers.
export function coachingSubject(organizationId, uid) {
  return `driverawaken:${organizationId}:${uid}`;
}

function cleanNote(value) {
  if (typeof value !== 'string') return null;
  const note = value.replace(/[\u0000-\u001f\u007f]+/g, ' ').replace(/\s+/g, ' ').trim();
  return note.length >= 3 && note.length <= NOTE_MAX_LENGTH ? note : null;
}

export function parseRequest(data) {
  const input = data && typeof data === 'object' ? data : {};
  const organizationId = typeof input.organizationId === 'string' && idPattern.test(input.organizationId) ? input.organizationId : null;
  if (!organizationId) throw new CoachingAccessError('invalid-argument', 'Organización inválida.');
  if (input.action === 'list') return { action: 'list', organizationId };
  if (input.action === 'delete') {
    if (typeof input.noteId !== 'string' || !memoryIdPattern.test(input.noteId)) throw new CoachingAccessError('invalid-argument', 'Nota inválida.');
    return { action: 'delete', organizationId, noteId: input.noteId };
  }
  if (input.action === 'save') {
    if (input.consent !== true) throw new CoachingAccessError('failed-precondition', 'Se requiere tu consentimiento explícito para guardar la nota.');
    const tripId = typeof input.tripId === 'string' && idPattern.test(input.tripId) ? input.tripId : null;
    const note = cleanNote(input.note);
    if (!tripId || !note) throw new CoachingAccessError('invalid-argument', `La nota debe tener entre 3 y ${NOTE_MAX_LENGTH} caracteres y referirse a un viaje.`);
    const replaces = input.replaces === undefined ? null : input.replaces;
    if (replaces !== null && (typeof replaces !== 'string' || !memoryIdPattern.test(replaces))) throw new CoachingAccessError('invalid-argument', 'Nota inválida.');
    return { action: 'save', organizationId, tripId, note, replaces };
  }
  throw new CoachingAccessError('invalid-argument', 'Acción no admitida.');
}

function tripDate(value) {
  const millis = value && typeof value.toMillis === 'function' ? value.toMillis() : null;
  return millis ? new Intl.DateTimeFormat('es-PE', { timeZone: 'America/Lima', dateStyle: 'short' }).format(millis) : 'fecha no registrada';
}

async function authorizeDriver(readDoc, uid, organizationId) {
  const [member, organization] = await Promise.all([
    readDoc(`organizations/${organizationId}/members/${uid}`),
    readDoc(`organizations/${organizationId}`),
  ]);
  if (!member || member.userId !== uid || member.organizationId !== organizationId || member.role !== 'DRIVER' || member.status !== 'ACTIVE' || organization?.status !== 'ACTIVE') {
    throw new CoachingAccessError('permission-denied', 'Las notas requieren una membresía DRIVER activa en esta organización.');
  }
}

function toNote(memory) {
  if (!memory || typeof memory !== 'object' || typeof memory.id !== 'string' || typeof memory.content !== 'string') return null;
  if (memory.source_site !== undefined && memory.source_site !== SOURCE_SITE) return null;
  const metadata = memory.metadata && typeof memory.metadata === 'object' ? memory.metadata : {};
  return {
    id: memory.id,
    tripId: typeof metadata.driverawaken_trip_id === 'string' ? metadata.driverawaken_trip_id : null,
    route: typeof metadata.driverawaken_route === 'string' ? metadata.driverawaken_route : null,
    note: typeof metadata.driverawaken_note === 'string' ? metadata.driverawaken_note : memory.content,
    createdAt: typeof memory.created_at === 'string' ? memory.created_at : null,
  };
}

export function createMemoryClient({ config, fetchImpl = fetch, timeoutMs = REQUEST_TIMEOUT_MS }) {
  async function call(path, init, { absentOk = false } = {}) {
    let response;
    try {
      response = await fetchImpl(`${config.url}${path}`, {
        ...init,
        headers: { Authorization: `Bearer ${config.apiKey}`, 'Content-Type': 'application/json' },
        signal: AbortSignal.timeout(timeoutMs),
        redirect: 'error',
      });
    } catch (error) {
      throw new ProviderError(error?.name === 'TimeoutError' ? 'timeout' : 'network');
    }
    if (absentOk && response.status === 404) return null;
    if (!response.ok) throw new ProviderError(`status ${response.status}`);
    try { return await response.json(); } catch { throw new ProviderError('invalid body'); }
  }
  return {
    async list(subject) {
      const query = new URLSearchParams({ user_id: subject, source_site: SOURCE_SITE, limit: String(LIST_LIMIT) });
      const body = await call(`/v1/memories/list?${query}`, { method: 'GET' });
      if (!Array.isArray(body?.memories)) throw new ProviderError('invalid list');
      return body.memories.map(toNote).filter(Boolean)
        .sort((a, b) => (b.createdAt ?? '').localeCompare(a.createdAt ?? ''));
    },
    async save(subject, { content, metadata }) {
      const body = await call('/v1/memories/ingest/quick', {
        method: 'POST',
        body: JSON.stringify({ user_id: subject, conversation: content, source_site: SOURCE_SITE, skip_extraction: true, content_class: 'summary', metadata }),
      });
      if (!Array.isArray(body?.stored_memory_ids)) throw new ProviderError('invalid ingest');
      return body.stored_memory_ids.filter(id => typeof id === 'string' && id);
    },
    async remove(subject, noteId) {
      const query = new URLSearchParams({ user_id: subject });
      // 404 after an ownership check means the note is already gone, which is the requested outcome.
      // Any other 2xx must carry the documented { success: true }; callers still confirm absence by readback.
      const body = await call(`/v1/memories/${encodeURIComponent(noteId)}?${query}`, { method: 'DELETE' }, { absentOk: true });
      if (body !== null && body?.success !== true) throw new ProviderError('unconfirmed delete');
    },
  };
}

const UNAVAILABLE = 'Atomic Memory no respondió a tiempo o rechazó la solicitud.';

// Returns a discriminated result; provider failures are reported, never presented as success.
export async function handleCoachingRequest({ uid, data, readDoc, memory }) {
  if (typeof uid !== 'string' || !uid) throw new CoachingAccessError('unauthenticated', 'Inicia sesión para usar tus notas.');
  const request = parseRequest(data);
  if (!memory) return { status: 'disabled' };
  await authorizeDriver(readDoc, uid, request.organizationId);
  const subject = coachingSubject(request.organizationId, uid);

  if (request.action === 'list') {
    try { return { status: 'ok', notes: await memory.list(subject) }; }
    catch { return { status: 'unavailable', message: `${UNAVAILABLE} No se pudieron cargar tus notas.` }; }
  }

  if (request.action === 'delete') {
    try {
      const notes = await memory.list(subject);
      if (!notes.some(note => note.id === request.noteId)) throw new CoachingAccessError('failed-precondition', 'La nota no existe en tu espacio.');
      await memory.remove(subject, request.noteId);
      const remaining = await memory.list(subject);
      if (remaining.some(note => note.id === request.noteId)) throw new ProviderError('still present');
      return { status: 'ok', notes: remaining };
    } catch (error) {
      if (error instanceof CoachingAccessError) throw error;
      return { status: 'unavailable', message: `${UNAVAILABLE} No se pudo confirmar que la nota se eliminó; revisa tu lista.` };
    }
  }

  const trip = await readDoc(`organizations/${request.organizationId}/trips/${request.tripId}`);
  if (!trip || trip.driverId !== uid || trip.organizationId !== request.organizationId || trip.status !== 'COMPLETED') {
    throw new CoachingAccessError('permission-denied', 'Solo puedes anotar viajes finalizados asignados a tu cuenta.');
  }
  const route = `${trip.origin} → ${trip.destination}`;
  const content = `Nota post-viaje del conductor (${route}, viaje del ${tripDate(trip.startTime)}): ${request.note}`;
  const metadata = { driverawaken_trip_id: request.tripId, driverawaken_route: route, driverawaken_note: request.note };
  let storedIds;
  try {
    if (request.replaces) {
      const previous = (await memory.list(subject)).find(note => note.id === request.replaces);
      if (!previous) throw new CoachingAccessError('failed-precondition', 'La nota a corregir no existe en tu espacio.');
      if (previous.tripId !== request.tripId) throw new CoachingAccessError('invalid-argument', 'La corrección debe referirse al mismo viaje que la nota original.');
    }
  } catch (error) {
    if (error instanceof CoachingAccessError) throw error;
    return { status: 'unavailable', message: `${UNAVAILABLE} La nota no se guardó.` };
  }
  // Success requires a stored id from the provider and a readback of that exact note.
  // Until then the original of a correction is kept, so an ambiguous write never loses it.
  const UNCONFIRMED = 'No se pudo confirmar que la nota se guardó. Revisa tu lista antes de volver a intentarlo.';
  try { storedIds = await memory.save(subject, { content, metadata }); }
  catch (error) {
    // A timed-out or dropped request may still have been stored; an explicit rejection was not.
    if (error instanceof ProviderError && (error.message === 'timeout' || error.message === 'network')) return { status: 'unconfirmed', message: UNCONFIRMED };
    return { status: 'unavailable', message: `${UNAVAILABLE} La nota no se guardó.` };
  }
  if (!storedIds.length) return { status: 'unconfirmed', message: UNCONFIRMED };
  let notes;
  try { notes = await memory.list(subject); }
  catch { return { status: 'unconfirmed', message: UNCONFIRMED }; }
  const confirmed = notes.some(note => storedIds.includes(note.id) && note.tripId === request.tripId && note.note === request.note);
  if (!confirmed) return { status: 'unconfirmed', message: UNCONFIRMED };
  if (request.replaces && !storedIds.includes(request.replaces)) {
    try {
      await memory.remove(subject, request.replaces);
      notes = await memory.list(subject);
      if (notes.some(note => note.id === request.replaces)) throw new ProviderError('still present');
    } catch { return { status: 'partial', message: 'La corrección se guardó, pero no se pudo confirmar que la versión anterior se eliminó. Revisa tu lista.' }; }
  }
  return { status: 'ok', notes };
}
