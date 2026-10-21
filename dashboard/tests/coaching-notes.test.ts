import { describe, expect, it } from 'vitest';
import { failureResult, parseCoachingResult } from '../src/lib/coaching-notes';

describe('post-trip coaching notes client boundary', () => {
  it('accepts recalled notes and rejects malformed server payloads', () => {
    const note = { id: 'n1', tripId: 'trip-1', route: 'Arequipa → Puno', note: 'Parar en Imata.', createdAt: '2026-10-20T12:00:00.000Z' };
    expect(parseCoachingResult({ status: 'ok', notes: [note] })).toEqual({ status: 'ok', notes: [note] });
    expect(parseCoachingResult({ status: 'ok', notes: [{ id: 3 }] })).toBeNull();
    expect(parseCoachingResult({ status: 'unconfirmed' })).toBeNull();
    expect(parseCoachingResult({ status: 'saved', message: 'ok' })).toBeNull();
    expect(parseCoachingResult({ status: 'unconfirmed', message: 'No se pudo confirmar' })).toEqual({ status: 'unconfirmed', message: 'No se pudo confirmar' });
    expect(parseCoachingResult({ status: 'disabled' })).toEqual({ status: 'disabled' });
  });
  it('never reports a failed call as saved', () => {
    expect(failureResult('save', { code: 'functions/deadline-exceeded', message: 'deadline-exceeded' })).toEqual({ status: 'unavailable', message: 'El servicio de notas no respondió. No se pudo confirmar que la nota se guardó; revisa tu lista antes de reintentar.' });
    expect(failureResult('delete', { code: 'functions/not-found', message: 'NOT FOUND' }).status).toBe('unavailable');
    expect(failureResult('save', { code: 'functions/permission-denied', message: 'Solo puedes anotar viajes finalizados asignados a tu cuenta.' })).toEqual({ status: 'rejected', message: 'Solo puedes anotar viajes finalizados asignados a tu cuenta.' });
  });
});
