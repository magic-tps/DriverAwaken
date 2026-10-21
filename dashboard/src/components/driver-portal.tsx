'use client';

import Link from 'next/link';
import { useEffect, useMemo, useState } from 'react';
import { onAuthStateChanged, signInWithEmailAndPassword, signOut, type User } from 'firebase/auth';
import { collection, doc, limit, onSnapshot, query, where, type DocumentData, type Firestore } from 'firebase/firestore';
import { firebaseClient, firebaseError } from '@/lib/firebase';
import { formatDate, type FleetRestSession, type Incident, type Membership, type Trip, TYPE_LABELS } from '@/lib/domain';
import { monitoringObservation, reportedRiskLabel } from '@/lib/operations-model';
import { coachingNotesEnabled } from '@/lib/coaching-notes';
import { CoachingNotes } from './coaching-notes';
import styles from './driver-portal.module.css';

type Client = NonNullable<ReturnType<typeof firebaseClient>>;
type DriverData = { trips: Trip[]; incidents: Incident[]; rests: FleetRestSession[] };
type VerifiedOrganization = { id: string; name: string; emergencyPhone: string | null; emergencyLabel: string };
const emptyData = (): DriverData => ({ trips: [], incidents: [], rests: [] });
const orgPattern = /^[a-zA-Z0-9_-]{1,128}$/;
const phonePattern = /^\+?[0-9]{3,15}$/;

function toMillis(value: unknown): number | null {
  return value && typeof value === 'object' && 'toMillis' in value && typeof value.toMillis === 'function'
    ? value.toMillis() as number : null;
}

function decodeRecord(id: string, data: DocumentData, kind: keyof DriverData): Trip | Incident | FleetRestSession {
  const common = { ...data, id };
  if (kind === 'trips') return {
    ...common,
    startTime: toMillis(data.startTime) ?? 0,
    endTime: toMillis(data.endTime),
    lastEventAt: toMillis(data.lastEventAt),
    lastSeenAt: toMillis(data.lastSeenAt),
  } as Trip;
  if (kind === 'incidents') return {
    ...common,
    detectedAt: toMillis(data.detectedAt) ?? 0,
    receivedAt: toMillis(data.receivedAt),
    syncStatus: 'SYNCED',
  } as Incident;
  return {
    ...common,
    startedAt: toMillis(data.startedAt) ?? 0,
    endedAt: toMillis(data.endedAt) ?? 0,
    receivedAt: toMillis(data.receivedAt),
  } as FleetRestSession;
}

function authorizedDataStreams(
  db: Firestore,
  org: string,
  uid: string,
  onData: (kind: keyof DriverData, records: Trip[] | Incident[] | FleetRestSession[], fromCache: boolean) => void,
  onError: (error: unknown) => void,
) {
  const specifications = [
    { kind: 'trips', count: 200 },
    { kind: 'incidents', count: 300 },
    { kind: 'rests', collectionName: 'restSessions', count: 200 },
  ] as const;
  return specifications.map(({ kind, count, ...rest }) => {
    const name = 'collectionName' in rest ? rest.collectionName : kind;
    // The driverId equality is required by Firestore rules. No organization-wide listener is created.
    const scoped = query(collection(db, 'organizations', org, name), where('driverId', '==', uid), limit(count));
    return onSnapshot(scoped, { includeMetadataChanges: true }, snapshot => {
      const records = snapshot.docs.map(item => decodeRecord(item.id, item.data(), kind));
      onData(kind, records as Trip[] | Incident[] | FleetRestSession[], snapshot.metadata.fromCache);
    }, onError);
  });
}

function byNewest<T>(items: T[], field: (item: T) => number) {
  return [...items].sort((a, b) => field(b) - field(a));
}

function displayDate(value: number | null) {
  return value && value > 0 ? formatDate(value) : 'Aún no recibido';
}

function riskTone(severity: string) {
  return severity === 'CRITICAL' ? styles.critical : severity === 'WARNING' ? styles.warning : styles.informational;
}

function riskLabel(severity: string) {
  return severity === 'CRITICAL' ? 'Crítico' : severity === 'WARNING' ? 'Advertencia' : 'Informativo';
}

export function DriverPortal() {
  const [client, setClient] = useState<Client | null>(null);
  const [initialized, setInitialized] = useState(false);
  const [authReady, setAuthReady] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [orgInput, setOrgInput] = useState('');
  const [org, setOrg] = useState('');
  const [verified, setVerified] = useState<VerifiedOrganization | null>(null);
  const [data, setData] = useState<DriverData>(emptyData);
  const [dataReady, setDataReady] = useState(false);
  const [fromCache, setFromCache] = useState(false);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const [now, setNow] = useState(0);

  useEffect(() => {
    let firebase: Client | null = null;
    // Firebase initialization must wait for client hydration.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    try { firebase = firebaseClient(); } catch { setError('No se pudo inicializar Firebase.'); }
    setClient(firebase);
    setInitialized(true);
    if (!firebase) return;
    return onAuthStateChanged(firebase.auth, currentUser => {
      // Clear the prior identity's data before rendering a new identity or a signed-out state.
      setVerified(null);
      setData(emptyData());
      setDataReady(false);
      setFromCache(false);
      setError('');
      setUser(currentUser);
      setAuthReady(true);
      setNow(Date.now());
      let remembered = '';
      try { if (currentUser) remembered = sessionStorage.getItem(`driver.org.${currentUser.uid}`) ?? ''; } catch { /* Manual selection remains available. */ }
      const validRemembered = orgPattern.test(remembered) ? remembered : '';
      setOrg(validRemembered);
      setOrgInput(validRemembered);
    });
  }, []);

  useEffect(() => {
    const timer = window.setInterval(() => setNow(Date.now()), 30_000);
    return () => window.clearInterval(timer);
  }, []);

  useEffect(() => {
    if (!client || !user || !org) return;
    let stopped = false;
    let member: { data: Membership | null; server: boolean } | null = null;
    let organization: { data: DocumentData | null; server: boolean } | null = null;
    let dataStops: (() => void)[] = [];
    let subscribed = false;
    const loaded = new Set<keyof DriverData>();
    const cached = new Map<keyof DriverData, boolean>();

    function clearData() {
      dataStops.forEach(stop => stop());
      dataStops = [];
      subscribed = false;
      loaded.clear();
      cached.clear();
      setVerified(null);
      setData(emptyData());
      setDataReady(false);
      setFromCache(false);
    }
    function fail(reason: unknown) {
      if (stopped) return;
      clearData();
      setError(firebaseError(reason));
    }
    function evaluate() {
      if (stopped || !member || !organization) return;
      // Cached membership is never sufficient to unlock private fleet records.
      if (!member.server || !organization.server) {
        if (subscribed) clearData();
        return;
      }
      const m = member.data;
      const o = organization.data;
      if (!m || m.userId !== user!.uid || m.organizationId !== org || m.role !== 'DRIVER' || m.status !== 'ACTIVE' || !o || o.status !== 'ACTIVE') {
        clearData();
        setError('No hay una membresía DRIVER activa en esta organización, o la organización no está activa.');
        return;
      }
      setError('');
      const verifiedOrganization: VerifiedOrganization = {
        id: org,
        name: typeof o.name === 'string' && o.name.trim() ? o.name : org,
        emergencyPhone: typeof o.emergencyPhone === 'string' && phonePattern.test(o.emergencyPhone) ? o.emergencyPhone : null,
        emergencyLabel: typeof o.emergencyLabel === 'string' && o.emergencyLabel.trim() ? o.emergencyLabel : 'Contacto de emergencia',
      };
      setVerified(previous => previous && previous.id === verifiedOrganization.id && previous.name === verifiedOrganization.name && previous.emergencyPhone === verifiedOrganization.emergencyPhone && previous.emergencyLabel === verifiedOrganization.emergencyLabel ? previous : verifiedOrganization);
      if (subscribed) return;
      subscribed = true;
      dataStops = authorizedDataStreams(client!.db, org, user!.uid, (kind, records, isCache) => {
        if (stopped || !subscribed) return;
        setData(previous => ({ ...previous, [kind]: records }));
        loaded.add(kind);
        cached.set(kind, isCache);
        setFromCache([...cached.values()].some(value => value));
        if (loaded.size === 3) setDataReady(true);
      }, fail);
    }

    const memberStop = onSnapshot(doc(client.db, 'organizations', org, 'members', user.uid), { includeMetadataChanges: true }, snapshot => {
      member = { data: snapshot.exists() ? snapshot.data() as Membership : null, server: !snapshot.metadata.fromCache };
      evaluate();
    }, fail);
    const orgStop = onSnapshot(doc(client.db, 'organizations', org), { includeMetadataChanges: true }, snapshot => {
      organization = { data: snapshot.exists() ? snapshot.data() : null, server: !snapshot.metadata.fromCache };
      evaluate();
    }, fail);
    return () => { stopped = true; memberStop(); orgStop(); dataStops.forEach(stop => stop()); };
  }, [client, user, org]);

  const trips = useMemo(() => byNewest(data.trips, item => item.startTime), [data.trips]);
  const incidents = useMemo(() => byNewest(data.incidents, item => item.detectedAt), [data.incidents]);
  const rests = useMemo(() => byNewest(data.rests, item => item.startedAt), [data.rests]);
  const currentTrip = trips.find(item => item.status === 'ACTIVE') ?? trips.find(item => item.status === 'ASSIGNED') ?? trips[0];
  const observation = currentTrip ? monitoringObservation(currentTrip, now) : null;
  const latestRisk = incidents.find(item => item.signalQuality === 'RELIABLE') ?? null;
  const completedTrips = useMemo(() => trips.filter(item => item.status === 'COMPLETED'), [trips]);
  const coaching = coachingNotesEnabled();

  async function login(form: FormData) {
    if (!client) return;
    setBusy(true); setError('');
    try { await signInWithEmailAndPassword(client.auth, String(form.get('email') ?? ''), String(form.get('password') ?? '')); }
    catch (reason) { setError(firebaseError(reason)); }
    finally { setBusy(false); }
  }
  async function logout() {
    if (!client) return;
    setVerified(null); setData(emptyData()); setDataReady(false); setOrg('');
    try { await signOut(client.auth); }
    catch (reason) { setError(firebaseError(reason)); }
  }
  function switchOrganization() {
    setVerified(null); setData(emptyData()); setDataReady(false); setOrg(''); setOrgInput(''); setError('');
    try { if (user) sessionStorage.removeItem(`driver.org.${user.uid}`); } catch { /* No persistent driver data is written. */ }
  }
  function connectOrganization(form: FormData) {
    const value = String(form.get('organizationId') ?? '').trim();
    if (!orgPattern.test(value)) { setError('El ID de organización admite letras, números, guiones y guiones bajos (máximo 128 caracteres).'); return; }
    setVerified(null); setData(emptyData()); setDataReady(false); setError(''); setOrg(value); setOrgInput(value);
    try { if (user) sessionStorage.setItem(`driver.org.${user.uid}`, value); } catch { /* Works for this page session. */ }
  }

  if (!initialized || (client && !authReady)) return <AccessShell><p className={styles.waiting} role="status">Conectando con DriverAwaken…</p></AccessShell>;
  if (!client) return <AccessShell><span className={styles.kicker}>PORTAL DEL CONDUCTOR</span><h1>Servicio no disponible.</h1><p>La conexión Firebase de este sitio aún no está configurada. No se muestran datos de prueba como si fueran registros reales.</p>{error && <p className={styles.error} role="alert">{error}</p>}</AccessShell>;
  if (!user) return <AccessShell><span className={styles.kicker}>ACCESO PERSONAL</span><h1>Tu ruta, tus registros.</h1><p>Inicia sesión para consultar solo los viajes y eventos que tu organización ha vinculado a tu cuenta.</p><form action={login} className={styles.form}><label htmlFor="driver-email">Correo electrónico</label><input id="driver-email" name="email" type="email" autoComplete="username" required/><label htmlFor="driver-password">Contraseña</label><input id="driver-password" name="password" type="password" autoComplete="current-password" required/><button type="submit" disabled={busy}>{busy ? 'Ingresando…' : 'Ingresar al portal'}<span aria-hidden="true">↗</span></button></form>{error && <p className={styles.error} role="alert">{error}</p>}<p className={styles.finePrint}>Necesitas una cuenta Firebase y una membresía DRIVER activa. La cámara y las alertas locales funcionan únicamente en la aplicación Android.</p></AccessShell>;
  if (!org || !verified) return <AccessShell><span className={styles.kicker}>CUENTA VERIFICADA</span><h1>Elige tu organización.</h1><p>Introduce el ID facilitado por tu administrador. Comprobaremos en Firebase tu rol de conductor antes de consultar cualquier viaje.</p><form action={connectOrganization} className={styles.form}><label htmlFor="driver-organization">ID de organización</label><input id="driver-organization" name="organizationId" value={orgInput} onChange={event => setOrgInput(event.target.value)} maxLength={128} required autoComplete="off" placeholder="mi-organizacion"/><button type="submit" disabled={busy}>Verificar acceso <span aria-hidden="true">↗</span></button></form>{org && !error && <p className={styles.waiting} role="status">Verificando membresía y organización con el servidor…</p>}{error && <p className={styles.error} role="alert">{error}</p>}<div className={styles.accessActions}><button type="button" onClick={switchOrganization}>Cambiar ID</button><button type="button" onClick={() => void logout()}>Cerrar sesión</button></div></AccessShell>;

  return <div className={styles.portal}>
    <header className={styles.header}>
      <Link href="/" className={styles.wordmark} aria-label="DriverAwaken, volver al inicio"><span className={styles.brandMark}>D<span>.</span></span><span>DRIVERAWAKEN<small>PORTAL CONDUCTOR</small></span></Link>
      <nav aria-label="Navegación del conductor"><a href="#estado">Estado</a><a href="#riesgos">Riesgos</a><a href="#historial">Historial</a>{coaching && <a href="#notas">Notas</a>}</nav>
      <button type="button" className={styles.logout} onClick={() => void logout()}>Cerrar sesión <span aria-hidden="true">↗</span></button>
    </header>
    <main id="main" className={styles.main}>
      <div className={styles.intro}><div><span className={styles.kicker}>ESPACIO PERSONAL · {verified.name}</span><h1>Lo que reportó tu viaje<span>.</span></h1><p>Observaciones compartidas desde Android. Esta página no accede a la cámara ni supervisa la conducción en tiempo real.</p></div><div className={styles.introAside}><span>CUENTA AUTORIZADA</span><strong>{user.email ?? user.uid}</strong><button type="button" onClick={switchOrganization}>Cambiar organización ↗</button></div></div>
      {error && <p className={styles.error} role="alert">{error}</p>}
      {fromCache && <p className={styles.cacheNotice} role="status">Conexión pendiente: se muestran datos de caché. Pueden estar desactualizados.</p>}
      {!dataReady ? <section className={styles.loadingPanel} role="status"><span className={styles.pulse} aria-hidden="true"/> Cargando tus registros autorizados…</section> : <>
        <section id="estado" className={styles.summaryGrid} aria-labelledby="status-title">
          <div className={`${styles.statusPanel} ${observation?.tone === 'success' ? styles.statusFresh : styles.statusCaution}`}>
            <div className={styles.panelTop}><span className={styles.kicker}>01 / ESTADO REPORTADO</span><span className={styles.smallTime}>Actualizado según registros recibidos</span></div>
            <div className={styles.statusMiddle}><span className={styles.bigIndicator} aria-hidden="true"><span/></span><div><h2 id="status-title">{observation?.label ?? 'Sin viaje reportado'}</h2><p>{currentTrip ? `${currentTrip.origin} → ${currentTrip.destination}` : 'Aún no hay viajes asignados en la ventana consultada.'}</p></div></div>
            <dl className={styles.statusDetails}><div><dt>Última señal recibida</dt><dd>{displayDate(currentTrip?.lastSeenAt ?? null)}</dd></div><div><dt>Estado del viaje</dt><dd>{currentTrip ? tripStatusLabel(currentTrip.status) : 'Sin registro'}</dd></div></dl>
            <p className={styles.statusCaveat}>Una señal reciente no confirma que sea seguro conducir. Si la aplicación está pausada o sin conexión, esta página no puede continuar el monitoreo.</p>
          </div>
          <aside className={styles.safetyColumn} aria-label="Riesgo y emergencia">
            <div className={styles.riskPanel}><span className={styles.kicker}>ÚLTIMO RIESGO CON SEÑAL FIABLE</span><div className={styles.riskValue}>{latestRisk ? reportedRiskLabel(latestRisk) : '—'}</div><p>{latestRisk ? `${TYPE_LABELS[latestRisk.type] ?? latestRisk.type} · ${displayDate(latestRisk.detectedAt)}` : 'No hay un índice evaluable recibido en esta ventana.'}</p><small>Índice heurístico de somnolencia, no diagnóstico ni probabilidad de accidente.</small></div>
            <div className={styles.emergencyPanel}><div><span className={styles.kicker}>CONTACTO DE EMERGENCIA</span><h2>{verified.emergencyLabel}</h2><p>{verified.emergencyPhone ? 'Número configurado por tu organización.' : 'Tu organización aún no configuró un número válido.'}</p></div>{verified.emergencyPhone ? <a href={`tel:${verified.emergencyPhone}`} aria-label={`Llamar a ${verified.emergencyLabel}: ${verified.emergencyPhone}`}>{verified.emergencyPhone}<span aria-hidden="true">↗</span></a> : <span className={styles.noPhone}>Número no disponible</span>}<small>La llamada se inicia solo si pulsas el número. Este portal nunca llama ni envía SMS por sí mismo.</small></div>
          </aside>
        </section>
        <section id="riesgos" className={styles.section} aria-labelledby="risk-title"><div className={styles.sectionHeading}><div><span className={styles.kicker}>02 / EVENTOS RECIBIDOS</span><h2 id="risk-title">Alertas y señales</h2></div><span className={styles.count}>{incidents.length} en esta ventana</span></div>{incidents.length ? <div className={styles.incidentList}>{incidents.slice(0, 8).map(item => <article key={item.id} className={`${styles.incident} ${riskTone(item.severity)}`}><div className={styles.incidentStripe} aria-hidden="true"/><div className={styles.incidentMain}><div className={styles.incidentHeading}><span>{riskLabel(item.severity)}</span><time dateTime={new Date(item.detectedAt).toISOString()}>{displayDate(item.detectedAt)}</time></div><h3>{TYPE_LABELS[item.type] ?? item.type}</h3><p>{item.signalQuality === 'RELIABLE' ? `Índice de riesgo ${reportedRiskLabel(item)} · señal fiable` : 'Señal insuficiente · riesgo no evaluable'}</p></div><div className={styles.incidentMeta}><span>Detectado: {displayDate(item.detectedAt)}</span><span>Recibido: {displayDate(item.receivedAt)}</span></div></article>)}</div> : <EmptyMessage title="No se recibieron alertas en esta ventana" text="La ausencia de registros no confirma ausencia de fatiga. Los eventos aún pendientes en el teléfono no aparecen aquí."/>}<p className={styles.sectionNote}>Se muestran hasta 8 eventos de una ventana de hasta 300 documentos vinculados a tu cuenta, ordenados por detección. Una recepción tardía no cambia la hora del evento.</p></section>
        <section id="historial" className={styles.historyGrid} aria-label="Historial personal"><div className={styles.historyPanel}><div className={styles.sectionHeading}><div><span className={styles.kicker}>03 / TUS TRAYECTOS</span><h2>Viajes</h2></div><span className={styles.count}>{trips.length} cargados</span></div>{trips.length ? <ul className={styles.historyList}>{trips.slice(0, 6).map(item => <li key={item.id}><div><strong>{item.origin} → {item.destination}</strong><span>{displayDate(item.startTime)} · {tripStatusLabel(item.status)}</span></div><small>{monitoringObservation(item, now).label}</small></li>)}</ul> : <EmptyMessage title="Sin viajes vinculados" text="Cuando te asignen un viaje, aparecerá aquí tras confirmarse en Firebase."/>}<p className={styles.sectionNote}>Ventana de hasta 200 viajes tuyos; puede no incluir todo el histórico.</p></div><div className={styles.historyPanel}><div className={styles.sectionHeading}><div><span className={styles.kicker}>04 / DESCANSO VOLUNTARIO</span><h2>Sesiones de descanso</h2></div><span className={styles.count}>{rests.length} cargadas</span></div>{rests.length ? <ul className={styles.historyList}>{rests.slice(0, 6).map(item => <li key={item.id}><div><strong>{displayDate(item.startedAt)}</strong><span>{item.recommendationReason}</span></div><small>{Math.floor(item.durationMs / 60_000)} min</small></li>)}</ul> : <EmptyMessage title="Sin descansos compartidos" text="Solo aparecen sesiones finalizadas que autorizaste compartir. No implica que no hayas descansado."/>}<p className={styles.sectionNote}>Un descanso autodeclarado no demuestra recuperación ni aptitud para conducir.</p></div></section>
        {coaching && <CoachingNotes key={`${user.uid}:${verified.id}`} app={client.app} uid={user.uid} organizationId={verified.id} completedTrips={completedTrips}/>}
      </>}
      <footer className={styles.footer}><div><strong>DriverAwaken</strong><span>La detección y las alertas inmediatas permanecen en Android.</span></div><a href="https://drive.google.com/drive/folders/1NjN0jGmj71hKqM0LcRYwEPFRaxBtJ92T?hl=es">Abrir APK en Google Drive ↗</a><Link href="/">Volver al inicio ↗</Link></footer>
    </main>
  </div>;
}

function tripStatusLabel(status: Trip['status']) {
  return ({ ASSIGNED: 'Asignado', ACTIVE: 'Activo', COMPLETED: 'Finalizado', CANCELLED: 'Cancelado' })[status] ?? status;
}

function EmptyMessage({ title, text }: { title: string; text: string }) {
  return <div className={styles.empty}><span aria-hidden="true">—</span><h3>{title}</h3><p>{text}</p></div>;
}

function AccessShell({ children }: { children: React.ReactNode }) {
  return <div className={styles.access}><header><Link href="/" className={styles.wordmark}><span className={styles.brandMark}>D<span>.</span></span><span>DRIVERAWAKEN<small>PORTAL CONDUCTOR</small></span></Link><Link href="/" className={styles.backLink}>Volver al inicio ↗</Link></header><main id="main" className={styles.accessPanel}>{children}</main><footer>Acceso privado · La cámara solo funciona en Android</footer></div>;
}
