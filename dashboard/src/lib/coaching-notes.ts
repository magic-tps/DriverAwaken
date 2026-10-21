import type { FirebaseApp } from 'firebase/app';
import { connectFunctionsEmulator, getFunctions, httpsCallable, type Functions } from 'firebase/functions';
import { emulatorPort } from './firebase';

// Optional post-trip notes. They never feed detection, alerts or incident handling.
export const NOTE_MAX_LENGTH = 280;
export type CoachingNote = { id: string; tripId: string | null; route: string | null; note: string; createdAt: string | null };
export type CoachingRequest =
  | { action: 'list' }
  | { action: 'save'; tripId: string; note: string; consent: true; replaces?: string }
  | { action: 'delete'; noteId: string };
export type CoachingResult =
  | { status: 'disabled' }
  | { status: 'ok'; notes: CoachingNote[] }
  | { status: 'partial' | 'unconfirmed' | 'unavailable' | 'rejected'; message: string };

export function coachingNotesEnabled() {
  return process.env.NEXT_PUBLIC_COACHING_NOTES_ENABLED === 'true';
}

const nullableString = (value: unknown) => typeof value === 'string' ? value : null;

function parseNote(value: unknown): CoachingNote | null {
  if (!value || typeof value !== 'object' || !('id' in value) || !('note' in value)) return null;
  if (typeof value.id !== 'string' || typeof value.note !== 'string') return null;
  return {
    id: value.id, note: value.note,
    tripId: 'tripId' in value ? nullableString(value.tripId) : null,
    route: 'route' in value ? nullableString(value.route) : null,
    createdAt: 'createdAt' in value ? nullableString(value.createdAt) : null,
  };
}

export function parseCoachingResult(value: unknown): CoachingResult | null {
  if (!value || typeof value !== 'object' || !('status' in value)) return null;
  switch (value.status) {
    case 'disabled': return { status: 'disabled' };
    case 'ok': {
      if (!('notes' in value) || !Array.isArray(value.notes)) return null;
      const notes = value.notes.map(parseNote);
      return notes.every(note => note !== null) ? { status: 'ok', notes } : null;
    }
    case 'partial': case 'unconfirmed': case 'unavailable':
      return 'message' in value && typeof value.message === 'string' ? { status: value.status, message: value.message } : null;
    default: return null;
  }
}

const notSaved: Record<CoachingRequest['action'], string> = {
  list: 'No se pudieron cargar tus notas.',
  save: 'No se pudo confirmar que la nota se guardó; revisa tu lista antes de reintentar.',
  delete: 'No se pudo confirmar que la nota se eliminó; revisa tu lista.',
};
const callerErrors = new Set(['functions/invalid-argument', 'functions/failed-precondition', 'functions/permission-denied', 'functions/unauthenticated']);

// Caller errors carry the server's Spanish reason; anything else means the service did not answer.
export function failureResult(action: CoachingRequest['action'], error: unknown): CoachingResult {
  const code = error && typeof error === 'object' && 'code' in error ? String(error.code) : '';
  const message = error && typeof error === 'object' && 'message' in error && typeof error.message === 'string' ? error.message : '';
  if (callerErrors.has(code) && message) return { status: 'rejected', message };
  return { status: 'unavailable', message: `El servicio de notas no respondió. ${notSaved[action]}` };
}

let functions: Functions | null = null;
function coachingFunctions(app: FirebaseApp) {
  if (functions) return functions;
  functions = getFunctions(app, 'us-central1');
  if (process.env.NEXT_PUBLIC_USE_EMULATORS === 'true') connectFunctionsEmulator(functions, '127.0.0.1', emulatorPort(process.env.NEXT_PUBLIC_FUNCTIONS_EMULATOR_PORT, 5001));
  return functions;
}

export async function callCoachingNotes(app: FirebaseApp, organizationId: string, request: CoachingRequest): Promise<CoachingResult> {
  try {
    const callable = httpsCallable(coachingFunctions(app), 'driverCoachingNotes', { timeout: 15_000 });
    const response = await callable({ organizationId, ...request });
    return parseCoachingResult(response.data) ?? failureResult(request.action, null);
  } catch (error) {
    return failureResult(request.action, error);
  }
}
