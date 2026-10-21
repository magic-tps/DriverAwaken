'use client';

import { useCallback, useEffect, useState } from 'react';
import type { FirebaseApp } from 'firebase/app';
import { callCoachingNotes, NOTE_MAX_LENGTH, type CoachingNote, type CoachingRequest } from '@/lib/coaching-notes';
import { formatDate, type Trip } from '@/lib/domain';
import styles from './driver-portal.module.css';

type Notice = { tone: 'success' | 'error'; text: string } | null;
type Notes = { kind: 'loading' } | { kind: 'disabled' } | { kind: 'ready'; notes: CoachingNote[] } | { kind: 'failed' };

function consentKey(uid: string, organizationId: string) {
  return `driver.coaching.consent.${uid}.${organizationId}`;
}

function noteDate(value: string | null) {
  const millis = value ? Date.parse(value) : NaN;
  return Number.isFinite(millis) ? formatDate(millis) : 'Fecha no disponible';
}

export function CoachingNotes({ app, uid, organizationId, completedTrips }: { app: FirebaseApp; uid: string; organizationId: string; completedTrips: Trip[] }) {
  const [consent, setConsent] = useState(false);
  const [accepted, setAccepted] = useState(false);
  const [notes, setNotes] = useState<Notes>({ kind: 'loading' });
  const [notice, setNotice] = useState<Notice>(null);
  const [busy, setBusy] = useState(false);
  const [tripId, setTripId] = useState('');
  const [draft, setDraft] = useState('');
  const [editing, setEditing] = useState<CoachingNote | null>(null);

  useEffect(() => {
    let stored = false;
    try { stored = localStorage.getItem(consentKey(uid, organizationId)) === 'granted'; } catch { /* Consent can be granted again for this page. */ }
    // Consent is read after hydration; no provider request happens before it.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setConsent(stored);
  }, [uid, organizationId]);

  const send = useCallback(async (request: CoachingRequest) => {
    setBusy(true);
    const result = await callCoachingNotes(app, organizationId, request);
    setBusy(false);
    if (result.status === 'disabled') { setNotes({ kind: 'disabled' }); return result.status; }
    if (result.status === 'ok') { setNotes({ kind: 'ready', notes: result.notes }); return result.status; }
    setNotice({ tone: 'error', text: result.message });
    if (request.action === 'list') setNotes({ kind: 'failed' });
    // The write may have landed; show what the provider actually holds instead of guessing.
    if (result.status === 'partial' || result.status === 'unconfirmed') {
      const current = await callCoachingNotes(app, organizationId, { action: 'list' });
      if (current.status === 'ok') setNotes({ kind: 'ready', notes: current.notes });
    }
    return result.status;
  }, [app, organizationId]);

  useEffect(() => {
    if (!consent) return;
    let active = true;
    void callCoachingNotes(app, organizationId, { action: 'list' }).then(result => {
      if (!active) return;
      if (result.status === 'disabled') setNotes({ kind: 'disabled' });
      else if (result.status === 'ok') setNotes({ kind: 'ready', notes: result.notes });
      else { setNotes({ kind: 'failed' }); setNotice({ tone: 'error', text: result.message }); }
    });
    return () => { active = false; };
  }, [app, organizationId, consent]);

  function grant() {
    try { localStorage.setItem(consentKey(uid, organizationId), 'granted'); } catch { /* Applies to this page session. */ }
    setNotice(null); setNotes({ kind: 'loading' }); setConsent(true);
  }
  function withdraw() {
    try { localStorage.removeItem(consentKey(uid, organizationId)); } catch { /* Nothing else is stored locally. */ }
    setConsent(false); setAccepted(false); setEditing(null); setDraft(''); setNotes({ kind: 'loading' });
    setNotice({ tone: 'success', text: 'Consentimiento retirado: no se guardarán ni consultarán notas. Las notas ya guardadas se conservan hasta que las elimines.' });
  }
  async function submit(form: FormData) {
    const note = String(form.get('note') ?? '').trim();
    const trip = editing?.tripId ?? String(form.get('tripId') ?? '');
    if (!trip) { setNotice({ tone: 'error', text: 'Elige un viaje finalizado.' }); return; }
    setNotice(null);
    const status = await send({ action: 'save', tripId: trip, note, consent: true, ...(editing ? { replaces: editing.id } : {}) });
    if (status === 'ok') setNotice({ tone: 'success', text: editing ? 'Corrección guardada en Atomic Memory.' : 'Nota guardada en Atomic Memory.' });
    // After 'partial' the correction exists; keeping the editor open would invite a duplicate.
    if (status === 'ok' || status === 'partial') { setDraft(''); setTripId(''); setEditing(null); }
  }
  async function remove(note: CoachingNote) {
    setNotice(null);
    if (await send({ action: 'delete', noteId: note.id }) === 'ok') setNotice({ tone: 'success', text: 'Nota eliminada de Atomic Memory.' });
    if (editing?.id === note.id) { setEditing(null); setDraft(''); }
  }
  function edit(note: CoachingNote) {
    setEditing(note); setDraft(note.note); setNotice(null);
  }

  const list = notes.kind === 'ready' ? notes.notes : [];
  const editableTrip = editing ? completedTrips.find(trip => trip.id === editing.tripId) : null;
  return <section id="notas" className={styles.section} aria-labelledby="coaching-title">
    <div className={styles.sectionHeading}><div><span className={styles.kicker}>05 / NOTAS POST-VIAJE · OPCIONAL</span><h2 id="coaching-title">Tus notas de coaching</h2></div>{consent && notes.kind === 'ready' && <span className={styles.count}>{list.length} guardadas</span>}</div>
    {!consent ? <div className={styles.coachingConsent}>
      <p>Al terminar un viaje, escribe qué te funcionó (una parada, un horario, un recordatorio) y vuelve a leerlo antes del siguiente. Es opcional y no cambia la detección ni las alertas.</p>
      <label className={styles.coachingCheck}><input type="checkbox" checked={accepted} onChange={event => setAccepted(event.target.checked)}/> Acepto que mis notas se guarden en Atomic Memory, un servicio externo, asociadas solo a mi cuenta en esta organización.</label>
      <button type="button" disabled={!accepted} onClick={grant}>Activar mis notas <span aria-hidden="true">↗</span></button>
    </div> : notes.kind === 'disabled' ? <p className={styles.coachingNotice} role="status">Las notas de coaching no están configuradas en este despliegue. No se guarda nada.</p> : <div className={styles.coachingGrid}>
      <form action={submit} className={styles.coachingForm} aria-label={editing ? 'Corregir nota' : 'Nueva nota post-viaje'}>
        <label htmlFor="coaching-trip">Viaje finalizado</label>
        {editing ? <p className={styles.coachingTrip}>{editableTrip ? `${editableTrip.origin} → ${editableTrip.destination}` : editing.route ?? 'Viaje anterior'}</p> : <select id="coaching-trip" name="tripId" value={tripId} onChange={event => setTripId(event.target.value)} required disabled={!completedTrips.length}>
          <option value="">{completedTrips.length ? 'Elige un viaje' : 'Sin viajes finalizados'}</option>
          {completedTrips.map(trip => <option key={trip.id} value={trip.id}>{trip.origin} → {trip.destination} · {formatDate(trip.startTime)}</option>)}
        </select>}
        <label htmlFor="coaching-note">{editing ? 'Corrige tu nota' : '¿Qué te ayudó en este viaje?'}</label>
        <textarea id="coaching-note" name="note" value={draft} onChange={event => setDraft(event.target.value)} minLength={3} maxLength={NOTE_MAX_LENGTH} rows={3} required placeholder="Ej.: Descansar 20 min en Imata antes de bajar a Juliaca."/>
        <small>{draft.length}/{NOTE_MAX_LENGTH}</small>
        <div className={styles.coachingActions}>
          <button type="submit" disabled={busy || notes.kind === 'loading'}>{busy ? 'Enviando…' : editing ? 'Guardar corrección' : 'Guardar nota'}</button>
          {editing && <button type="button" className={styles.coachingSecondary} onClick={() => { setEditing(null); setDraft(''); }}>Cancelar</button>}
        </div>
      </form>
      <div className={styles.coachingList} aria-live="polite">
        <span className={styles.kicker}>REPASA ANTES DE TU PRÓXIMO VIAJE</span>
        {notes.kind === 'loading' ? <p className={styles.waiting} role="status">Cargando tus notas…</p>
          : notes.kind === 'failed' ? <p className={styles.coachingEmpty}>No se pudieron cargar tus notas.</p>
          : list.length ? <ul>{list.map(note => <li key={note.id}>
            <div><strong>{note.route ?? 'Viaje anterior'}</strong><span>{noteDate(note.createdAt)}</span></div>
            <p>{note.note}</p>
            <div className={styles.coachingActions}><button type="button" className={styles.coachingSecondary} disabled={busy} onClick={() => edit(note)}>Corregir</button><button type="button" className={styles.coachingSecondary} disabled={busy} onClick={() => void remove(note)}>Eliminar</button></div>
          </li>)}</ul> : <p className={styles.coachingEmpty}>Aún no tienes notas guardadas.</p>}
      </div>
    </div>}
    {notice && <p className={notice.tone === 'error' ? styles.error : styles.coachingNotice} role={notice.tone === 'error' ? 'alert' : 'status'}>{notice.text}</p>}
    <p className={styles.sectionNote}>Las notas se guardan en Atomic Memory solo con tu consentimiento, separadas por cuenta y organización. No intervienen en la detección, las alertas ni los incidentes, y la central no las consulta.{consent && <> <button type="button" className={styles.coachingWithdraw} onClick={withdraw}>Retirar consentimiento</button></>}</p>
  </section>;
}
