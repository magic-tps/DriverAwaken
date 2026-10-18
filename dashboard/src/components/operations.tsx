'use client';
import Link from 'next/link';
import { useCallback, useEffect, useRef, useState } from 'react';
import { onAuthStateChanged, signInWithEmailAndPassword, signOut, type User } from 'firebase/auth';
import { collection, deleteField, doc, limit, onSnapshot, orderBy, query, runTransaction, serverTimestamp, setDoc, updateDoc, type DocumentData } from 'firebase/firestore';
import { firebaseClient, firebaseError } from '@/lib/firebase';
import type { ActionType, FleetRestSession, Incident, Membership, OperatorAction, Trip, Vehicle } from '@/lib/domain';
import { formatDate, isFresh, metrics, TYPE_LABELS } from '@/lib/domain';
import { OperationalReports } from './operational-reports';
import { driverRows, latestIncident, monitoringObservation, reportedRiskLabel } from '@/lib/operations-model';
import { Badge, Empty, Icon, Mark, navigation, Stat } from './ui';
import { IncidentBoard } from './incidents';
import { AlertSubscription, disableSupervisorAlerts } from './alert-subscription';

type Section = 'overview' | 'trips' | 'incidents' | 'fleet' | 'drivers' | 'rest' | 'reports' | 'settings';
type Client = NonNullable<ReturnType<typeof firebaseClient>>;
type Data = { trips: Trip[]; incidents: Incident[]; actions: OperatorAction[]; vehicles: Vehicle[]; rests: FleetRestSession[]; members: Membership[] };
const emptyData = (): Data => ({ trips: [], incidents: [], actions: [], vehicles: [], rests: [], members: [] });
function timestamp(value: unknown): number | null { return value && typeof value === 'object' && 'toMillis' in value && typeof value.toMillis === 'function' ? value.toMillis() as number : null; }
function parseRecord(id: string, data: DocumentData, kind: keyof Data) {
  const common = { ...data, id };
  if (kind === 'trips') return { ...common, startTime: timestamp(data.startTime) ?? 0, endTime: timestamp(data.endTime), lastSeenAt: timestamp(data.lastSeenAt), lastEventAt: timestamp(data.lastEventAt) } as Trip;
  if (kind === 'incidents') return { ...common, detectedAt: timestamp(data.detectedAt) ?? 0, receivedAt: timestamp(data.receivedAt), syncStatus: 'SYNCED' } as Incident;
  if (kind === 'actions') return { ...common, createdAt: timestamp(data.createdAt) ?? 0 } as OperatorAction;
  if (kind === 'rests') return { ...common, startedAt: timestamp(data.startedAt) ?? 0, endedAt: timestamp(data.endedAt) ?? 0, receivedAt: timestamp(data.receivedAt) } as FleetRestSession;
  if (kind === 'members') return common as unknown as Membership;
  return common as Vehicle;
}
export function Operations({ section = 'overview' }: { section?: Section }) {
  const [client, setClient] = useState<Client | null>(null);
  const [initialized, setInitialized] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [orgInput, setOrgInput] = useState('');
  const [org, setOrg] = useState('');
  const [subscriptionRevision, setSubscriptionRevision] = useState(0);
  const [membership, setMembership] = useState<Membership | null>(null);
  const [orgName, setOrgName] = useState('');
  const [emergencyPhone, setEmergencyPhone] = useState('');
  const [emergencyLabel, setEmergencyLabel] = useState('');
  const [data, setData] = useState<Data>(emptyData);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [liveAlert, setLiveAlert] = useState('');
  const [loading, setLoading] = useState(false);
  const [busy, setBusy] = useState(false);
  const [cached, setCached] = useState(true);
  const [selected, setSelected] = useState<string | null>(null);
  const [now, setNow] = useState(0);
  const attempt = useRef<{ key: string; id: string } | null>(null);
  const writing = useRef(false);
  useEffect(() => {
    let c: Client | null = null;
    // Firebase initialization must follow static hydration; the SDK uses browser APIs.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    try { c = firebaseClient(); setClient(c); } catch { setError('No se pudo inicializar Firebase. Revisa las variables de entorno.'); }
    setInitialized(true);
    if (!c) return;
    return onAuthStateChanged(c.auth, u => {
      setUser(u); setAuthReady(true); setNow(Date.now()); setMembership(null); setData(emptyData()); setError('');
      let remembered = '';
      try { if (u) remembered = sessionStorage.getItem(`guardian.org.${u.uid}`) ?? ''; } catch { /* Organization entry remains available when session storage is blocked. */ }
      setOrg(/^[a-zA-Z0-9_-]{1,128}$/.test(remembered) ? remembered : ''); setOrgInput(remembered);
    });
  }, []);
  useEffect(() => { const interval = setInterval(() => setNow(Date.now()), 30_000); return () => clearInterval(interval); }, []);
  useEffect(() => {
    if (!client || !user || !org) return;
    let streams: (() => void)[] = [];
    let stopped = false;
    const seenIncidents = new Set<string>();
    let incidentServerBaseline = false;
    function clearStreams() { streams.forEach(stop => stop()); streams = []; }
    function fail(e: unknown) { if (stopped) return; clearStreams(); setData(emptyData()); setMembership(null); setLoading(false); setError(firebaseError(e)); }
    const stopMembership = onSnapshot(doc(client.db, 'organizations', org, 'members', user.uid), snap => {
      clearStreams(); setData(emptyData());
      const member = snap.data() as Membership | undefined;
      if (!snap.exists() || !member || member.status !== 'ACTIVE' || member.organizationId !== org || member.userId !== user.uid) { setMembership(null); setLoading(false); setError('No tienes una membresía activa en esta organización. Solicita acceso al administrador.'); return; }
      if (member.role !== 'ADMIN' && member.role !== 'OPERATOR') { setMembership(null); setLoading(false); setError('Esta central requiere el rol OPERATOR o ADMIN. Los conductores usan la aplicación Android y sus viajes asignados.'); return; }
      setMembership(member); setLoading(true); setCached(true);
      streams.push(onSnapshot(doc(client.db, 'organizations', org), s => {
        setOrgName(String(s.data()?.name ?? org));
        setEmergencyPhone(typeof s.data()?.emergencyPhone === 'string' ? s.data()!.emergencyPhone : '');
        setEmergencyLabel(typeof s.data()?.emergencyLabel === 'string' ? s.data()!.emergencyLabel : '');
      }, fail));
      const specs: { kind: keyof Data; collection: string; field?: string; count: number }[] = [
        { kind: 'trips', collection: 'trips', field: 'startTime', count: 200 },
        { kind: 'incidents', collection: 'incidents', field: 'detectedAt', count: 300 },
        { kind: 'actions', collection: 'operatorActions', field: 'createdAt', count: 1000 },
        { kind: 'vehicles', collection: 'vehicles', count: 300 },
        { kind: 'rests', collection: 'restSessions', field: 'startedAt', count: 200 },
        { kind: 'members', collection: 'members', count: 300 },
      ];
      const loaded = new Set<string>();
      const cacheState = new Map<string, boolean>();
      specs.forEach(spec => {
        const base = collection(client.db, 'organizations', org, spec.collection);
        const scoped = spec.field ? query(base, orderBy(spec.field, 'desc'), limit(spec.count)) : query(base, limit(spec.count));
        streams.push(onSnapshot(scoped, { includeMetadataChanges: true }, result => {
          if (stopped) return;
          if (spec.kind === 'incidents') {
            const incoming = result.docs.filter(d => !seenIncidents.has(d.id) && ['WARNING', 'CRITICAL'].includes(String(d.data().severity)));
            if (!result.metadata.fromCache && incidentServerBaseline && incoming.length) {
              const critical = incoming.some(d => d.data().severity === 'CRITICAL');
              const label = incoming.length === 1 ? (critical ? 'alerta crítica' : 'alerta de fatiga') : 'alertas de fatiga';
              setLiveAlert(`${incoming.length} ${label} recibida${incoming.length === 1 ? '' : 's'} en la central. Abre Incidentes para atenderla${incoming.length === 1 ? '' : 's'}.`);
            }
            result.docs.forEach(d => seenIncidents.add(d.id));
            if (!result.metadata.fromCache) incidentServerBaseline = true;
          }
          setData(current => ({ ...current, [spec.kind]: result.docs.map(d => parseRecord(d.id, d.data(), spec.kind)) }));
          cacheState.set(spec.kind, result.metadata.fromCache);
          setCached(cacheState.size !== specs.length || [...cacheState.values()].some(fromCache => fromCache));
          loaded.add(spec.kind); if (loaded.size === specs.length) setLoading(false);
        }, fail));
      });
    }, fail);
    return () => { stopped = true; stopMembership(); clearStreams(); };
  }, [client, user, org, subscriptionRevision]);

  const recordAction = useCallback(async (incidentId: string, actionType: ActionType, note: string) => {
    if (!client || !user || !membership || writing.current) return;
    const text = note.trim();
    if (!text || text.length > 1000) throw new Error('La nota debe tener entre 1 y 1000 caracteres.');
    const key = JSON.stringify([org, incidentId, actionType, text]);
    if (attempt.current?.key !== key) attempt.current = { key, id: crypto.randomUUID() };
    const actionId = attempt.current.id;
    writing.current = true; setBusy(true);
    try {
      const ref = doc(client.db, 'organizations', org, 'operatorActions', actionId);
      await runTransaction(client.db, async transaction => {
        const existing = await transaction.get(ref);
        if (existing.exists()) return;
        transaction.set(ref, { id: actionId, organizationId: org, incidentId, operatorId: user.uid, actionType, note: text, createdAt: serverTimestamp() });
      });
      setNotice('Acción registrada. La evidencia de detección se conserva.');
      attempt.current = null;
    } catch (e) { throw new Error(firebaseError(e)); }
    finally { writing.current = false; setBusy(false); }
  }, [client, user, org, membership]);

  async function login(form: FormData) {
    if (!client) return;
    setBusy(true); setError('');
    try { await signInWithEmailAndPassword(client.auth, String(form.get('email')), String(form.get('password'))); }
    catch (e) { setError(firebaseError(e)); } finally { setBusy(false); }
  }
  async function logout() {
    if (!client || !user) return;
    try {
      if (org) await disableSupervisorAlerts(client, org, user.uid);
      await signOut(client.auth);
    } catch (e) { setError(`No se pudo desactivar las notificaciones antes de salir: ${firebaseError(e)}`); }
  }
  async function switchOrganization() {
    if (!client || !user) return;
    try {
      if (org) await disableSupervisorAlerts(client, org, user.uid);
      setOrg(''); setOrgInput(''); setData(emptyData()); setMembership(null); setLiveAlert('');
    } catch (e) { setError(`Desactiva los avisos de este navegador antes de cambiar de organización: ${firebaseError(e)}`); }
  }
  function connectOrg(form: FormData) {
    const value = String(form.get('organizationId') ?? '').trim();
    if (!/^[a-zA-Z0-9_-]{1,128}$/.test(value)) { setError('Usa un identificador de organización válido (letras, números, _ o -).'); return; }
    try { if (user) sessionStorage.setItem(`guardian.org.${user.uid}`, value); } catch { /* The selection can still be used in this page. */ }
    setLoading(true); setOrg(value); setOrgInput(value); setSubscriptionRevision(v => v + 1); setError(''); setNotice(''); setLiveAlert('');
  }
  const count = metrics(data.trips, data.incidents, data.actions);
  const freshMonitoring = data.trips.filter(t => t.status === 'ACTIVE' && t.monitoringStatus === 'ACTIVE' && isFresh(t.lastSeenAt, now)).length;
  const href = section === 'overview' ? '/dashboard' : `/dashboard/${section}`;
  if (!initialized || (client && !authReady)) return <AccessFrame><div className="loading-state" role="status"><span className="spinner"/> Conectando con la central…</div></AccessFrame>;
  if (!client) return <AccessFrame><Empty title="Central pendiente de configurar">Configura las variables NEXT_PUBLIC_FIREBASE_* en dashboard/.env.local y vuelve a compilar. La demo pública funciona de forma independiente.</Empty>{error && <p className="notice danger">{error}</p>}<Link href="/demo" className="button primary full">Abrir demo pública <Icon name="arrow"/></Link></AccessFrame>;
  if (!user) return <AccessFrame><span className="eyebrow">ACCESO AUTORIZADO</span><h1>Bienvenido a la central.</h1><p className="muted">Ingresa con tu cuenta de operador o administrador.</p><form action={login} className="stack-form"><label htmlFor="email">Correo electrónico</label><input id="email" name="email" type="email" autoComplete="username" required placeholder="operador@tu-organizacion.pe"/><label htmlFor="password">Contraseña</label><input id="password" name="password" type="password" autoComplete="current-password" required minLength={6}/><button className="button primary full" disabled={busy}>{busy ? 'Iniciando sesión…' : 'Ingresar a la central'}<Icon name="arrow" size={18}/></button></form>{error && <p className="notice danger" role="alert">{error}</p>}<p className="microcopy">Las cuentas y membresías se provisionan por un administrador autorizado. La demo no requiere cuenta.</p></AccessFrame>;
  if (!membership) return <AccessFrame><span className="eyebrow">ORGANIZACIÓN</span><h1>Conecta con tu flota.</h1><p className="muted">Introduce el identificador entregado por tu administrador. El acceso se verifica en Firestore.</p><form action={connectOrg} className="stack-form"><label htmlFor="organizationId">Identificador de organización</label><input name="organizationId" id="organizationId" required value={orgInput} onChange={e => setOrgInput(e.target.value)} maxLength={128} placeholder="mi-organizacion"/><button className="button primary full" disabled={loading}>{loading ? 'Verificando membresía…' : 'Abrir organización'}</button></form>{error && <p className="notice danger" role="alert">{error}</p>}<button className="text-button" onClick={() => void logout()}>Cerrar sesión</button></AccessFrame>;
  return <div className="app-shell"><aside className="sidebar"><Mark small/><div className="workspace-label">ESPACIO DE TRABAJO</div><div className="org-card"><span className="org-avatar">{orgName.slice(0, 2).toUpperCase()}</span><div><strong>{orgName}</strong><span>{membership.role === 'ADMIN' ? 'Administración' : 'Operación'}</span></div></div><nav aria-label="Central operativa">{navigation.map(item => <Link key={item.href} className={`nav-item ${item.href === href ? 'active' : ''}`} href={item.href}><Icon name={item.icon}/>{item.label}</Link>)}</nav><div className="sidebar-bottom"><Link href="/demo" className="nav-item"><Icon name="play"/> Explorar demo</Link><button className="nav-item" onClick={() => void logout()}><Icon name="logout"/> Cerrar sesión</button></div></aside><div className="app-body"><header className="operational-header"><div><span className="eyebrow">CENTRAL DE OPERACIONES · {orgName}</span><h1>{navigation.find(n => n.href === href)?.label ?? 'Resumen operativo'}<span className="heading-dot">.</span></h1></div><div className="header-status"><Badge tone={cached ? 'warning' : 'success'}><span className="status-dot"/>{cached ? 'Esperando confirmación del servidor' : 'Datos confirmados por Firestore'}</Badge><AlertSubscription client={client} org={org} uid={user.uid}/><span className="logical-clock">{membership.role} · America/Lima</span></div></header><main id="main" className="dashboard-content">{error && <p className="notice danger" role="alert">{error}</p>}{liveAlert && <p className="notice danger" role="alert">{liveAlert}<button className="text-button" aria-label="Cerrar alerta" onClick={() => setLiveAlert('')}>×</button></p>}{notice && <p className="notice success" role="status">{notice}<button className="text-button" aria-label="Cerrar notificación" onClick={() => setNotice('')}>×</button></p>}{loading ? <div className="loading-state" role="status"><span className="spinner"/> Cargando datos autorizados…</div> : <>
    {(section === 'overview' || section === 'reports') && <><div className="stats-row"><Stat label="Viajes activos" value={count.activeTrips} detail="Estado de viaje ACTIVE"/><Stat label="Monitoreos con señal reciente" value={freshMonitoring} detail="Última señal hace menos de 2 min" tone="stat-success"/><Stat label="Incidentes nuevos" value={count.newIncidents} detail={`${count.acknowledged} reconocidos`} tone="stat-danger"/><Stat label="Incidentes atendidos" value={count.attendedPercent === null ? '—' : `${count.attendedPercent}%`} detail="Reconocidos o con acción registrada"/></div><p className="microcopy">Alcance: hasta 200 viajes recientes, 300 incidentes y 1000 acciones. Las cifras describen esta ventana; no son un histórico completo. La cola pendiente del teléfono no es observable desde la central.</p></>}
    {(section === 'overview' || section === 'trips') && <TripTable trips={data.trips} incidents={data.incidents} now={now}/>}
    {section === 'trips' && membership.role === 'ADMIN' && <AdminTripForm client={client} org={org} vehicles={data.vehicles} onNotice={setNotice}/>}
    {section === 'trips' && <RestHistory rests={data.rests}/>}
    {section === 'rest' && <RestHistory rests={data.rests}/>}
    {section === 'drivers' && <DriverTable members={data.members} trips={data.trips} incidents={data.incidents} now={now}/>}
    {(section === 'overview' || section === 'incidents') && <IncidentBoard incidents={data.incidents} actions={data.actions} selectedId={selected} onSelect={setSelected} onAction={recordAction} busy={busy}/>}
    {section === 'fleet' && <><section className="panel"><div className="panel-heading"><h2>Vehículos de la organización</h2><Badge>{data.vehicles.length} registrados</Badge></div>{data.vehicles.length ? <div className="table-wrap"><table><thead><tr><th>Código interno</th><th>Tipo</th><th>Estado</th><th>ID</th></tr></thead><tbody>{data.vehicles.map(v => <tr key={v.id}><td><strong>{v.internalCode}</strong></td><td>{v.vehicleType}</td><td><Badge tone={v.status === 'ACTIVE' ? 'success' : 'neutral'}>{v.status}</Badge></td><td className="mono">{v.id}</td></tr>)}</tbody></table></div> : <Empty title="Tu flota aún no tiene vehículos">Un administrador autorizado puede registrar el primer vehículo.</Empty>}</section>{membership.role === 'ADMIN' && <AdminVehicleForm client={client} org={org} onNotice={setNotice}/>}</>}
    {section === 'reports' && <Reports data={data}/>}
    {section === 'settings' && <><section className="panel settings-panel"><span className="eyebrow">ACCESO Y PRIVACIDAD</span><h2>Tu espacio operativo</h2><dl className="detail-grid"><div><dt>Organización</dt><dd>{orgName}</dd></div><div><dt>ID de organización</dt><dd className="mono">{org}</dd></div><div><dt>Rol autorizado</dt><dd>{membership.role}</dd></div><div><dt>Usuario autenticado</dt><dd className="mono">{user.uid}</dd></div><div><dt>Emergencia de flota</dt><dd>{emergencyPhone || 'Sin número configurado'}</dd></div></dl><p>Los permisos se validan mediante membresías y reglas de Firestore. Solo un administrador activo puede gestionar membresías; el primer administrador se provisiona mediante bootstrap local.</p><p>El conductor da su consentimiento en Android antes de compartir incidentes. La central recibe eventos operativos, sin video, fotografías ni vectores biométricos.</p><p className="microcopy">Las preferencias de retención y eliminación deben definirse con el responsable de cada organización antes de un lanzamiento público.</p><button className="button secondary" onClick={() => void switchOrganization()}>Cambiar organización</button></section>{membership.role === 'ADMIN' && <><AdminEmergencyForm client={client} org={org} phone={emergencyPhone} label={emergencyLabel} onNotice={setNotice}/><AdminMembershipForm client={client} org={org} currentUid={user.uid} onNotice={setNotice}/></>}</>}
    </>}<p className="dashboard-disclaimer">El monitoreo refleja la última observación del teléfono confirmada por el servidor. Android puede suspender la aplicación. Sin una observación reciente, la central no confirma continuidad del monitoreo.</p></main></div></div>;
}
function AccessFrame({ children }: { children: React.ReactNode }) { return <div className="access-page"><header><Mark/><Link className="button ghost small" href="/demo">Explorar demo <Icon name="arrow" size={16}/></Link></header><main id="main" className="access-panel">{children}</main><footer>Sesión protegida · Procesamiento facial en el dispositivo</footer></div>; }
function RestHistory({ rests }: { rests: FleetRestSession[] }) {
  return <section className="panel"><div className="panel-heading"><div><span className="eyebrow">REGISTRO VOLUNTARIO · HASTA 200 SESIONES RECIENTES</span><h2>Descansos autodeclarados</h2></div><Badge>{rests.length} recibidos</Badge></div>{!rests.length ? <Empty title="Sin descansos compartidos">Solo aparecen sesiones finalizadas que el conductor autorizó compartir. Su ausencia no indica que no haya descansado.</Empty> : <div className="table-wrap"><table><thead><tr><th>Viaje</th><th>Inicio declarado</th><th>Fin declarado</th><th>Duración registrada</th><th>Motivo</th></tr></thead><tbody>{rests.map(rest => <tr key={rest.id}><td className="mono">{rest.tripId}</td><td>{formatDate(rest.startedAt)}</td><td>{formatDate(rest.endedAt)}</td><td>{Math.floor(rest.durationMs / 60_000)} min {Math.floor(rest.durationMs % 60_000 / 1000)} s</td><td>{rest.recommendationReason}</td></tr>)}</tbody></table></div>}<p className="microcopy" style={{ padding: '0 22px 18px' }}>Registro confirmado por la persona, sin ubicación compartida. No demuestra recuperación fisiológica ni aptitud para conducir.</p></section>;
}
function Observation({ trip, now }: { trip: Trip; now: number }) {
  const observation = monitoringObservation(trip, now);
  return <Badge tone={observation.tone}>{observation.label}</Badge>;
}
function DriverTable({ members, trips, incidents, now }: { members: Membership[]; trips: Trip[]; incidents: Incident[]; now: number }) {
  const rows = driverRows(members, trips, incidents);
  return <section className="panel"><div className="panel-heading"><div><span className="eyebrow">MEMBRESÍAS AUTORIZADAS · HASTA 300 CUENTAS</span><h2>Conductores de la organización</h2></div><Badge>{rows.length} conductores</Badge></div>{!rows.length ? <Empty title="Sin conductores registrados">Un administrador puede asignar el rol DRIVER a una cuenta existente desde Ajustes.</Empty> : <div className="table-wrap"><table><thead><tr><th>Conductor / UID</th><th>Membresía</th><th>Viaje operativo o último conocido</th><th>Monitoreo reportado</th><th>Último riesgo del viaje</th><th>Última señal recibida</th></tr></thead><tbody>{rows.map(({ member, trip, incident }) => <tr key={member.userId}><td className="mono">{member.userId}</td><td><Badge tone={member.status === 'ACTIVE' ? 'success' : 'neutral'}>{member.status === 'ACTIVE' ? 'Activo' : 'Inactivo'}</Badge></td><td>{trip ? <><strong>{trip.origin} → {trip.destination}</strong><span className="table-sub">{trip.id} · {trip.vehicleId}</span></> : 'Sin viaje en esta ventana'}</td><td>{trip ? <Observation trip={trip} now={now}/> : 'Sin observación'}</td><td>{incident ? <><strong>{reportedRiskLabel(incident)}</strong><span className="table-sub">{formatDate(incident.detectedAt)} · índice heurístico</span></> : 'Sin evento recibido'}</td><td>{trip?.lastSeenAt ? formatDate(trip.lastSeenAt) : 'Aún no recibida'}</td></tr>)}</tbody></table></div>}<p className="microcopy" style={{ padding: '0 22px 18px' }}>Se muestran identificadores reales, sin inventar nombres ni ubicación. La membresía activa no confirma que la persona esté conduciendo.</p></section>;
}
function TripTable({ trips, incidents, now }: { trips: Trip[]; incidents: Incident[]; now: number }) {
  const statuses = { ASSIGNED: 'Asignado', ACTIVE: 'Activo', COMPLETED: 'Finalizado', CANCELLED: 'Cancelado' };
  return <section className="panel"><div className="panel-heading"><h2>Viajes y estado de monitoreo</h2><Badge>{trips.length} viajes</Badge></div>{!trips.length ? <Empty title="Aún no hay viajes">Los viajes asignados por un administrador aparecerán aquí. Los conductores los seleccionan desde Android.</Empty> : <div className="table-wrap"><table><thead><tr><th>Ruta / viaje</th><th>Vehículo / conductor</th><th>Viaje</th><th>Monitoreo</th><th>Último evento / riesgo</th><th>Última señal</th></tr></thead><tbody>{trips.map(t => { const incident = latestIncident(incidents, t.id); return <tr key={t.id}><td><strong>{t.origin} → {t.destination}</strong><span className="table-sub">{t.id}</span></td><td className="mono">{t.vehicleId}<span className="table-sub">{t.driverId}</span></td><td><Badge tone={t.status === 'ACTIVE' ? 'success' : 'neutral'}>{statuses[t.status]}</Badge></td><td><Observation trip={t} now={now}/></td><td>{incident ? <><strong>{TYPE_LABELS[incident.type] ?? incident.type}</strong><span className="table-sub">{formatDate(incident.detectedAt)} · {reportedRiskLabel(incident)} heurístico</span></> : 'Sin evento recibido'}</td><td>{t.lastSeenAt ? formatDate(t.lastSeenAt) : 'Aún no recibida'}</td></tr>; })}</tbody></table></div>}</section>;
}
function Reports({ data }: { data: Data }) {
  return <><OperationalReports incidents={data.incidents} actions={data.actions} trips={data.trips}/><RestHistory rests={data.rests}/></>;
}
function AdminEmergencyForm({ client, org, phone, label, onNotice }: { client: Client; org: string; phone: string; label: string; onNotice: (s: string) => void }) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  async function save(form: FormData) {
    const nextPhone = String(form.get('phone') ?? '').trim();
    const nextLabel = String(form.get('label') ?? '').trim();
    if (nextPhone && !/^\+?[0-9]{3,15}$/.test(nextPhone)) { setError('Usa solo dígitos, con + opcional y entre 3 y 15 cifras.'); return; }
    if (nextLabel.length > 80) { setError('La etiqueta no puede superar 80 caracteres.'); return; }
    setBusy(true); setError('');
    try {
      await updateDoc(doc(client.db, 'organizations', org), {
        emergencyPhone: nextPhone || deleteField(),
        emergencyLabel: nextLabel || deleteField(),
      });
      onNotice(nextPhone ? 'Número de emergencia de la flota actualizado.' : 'Número de emergencia retirado.');
    } catch (e) { setError(firebaseError(e)); }
    finally { setBusy(false); }
  }
  return <section className="panel form-panel"><span className="eyebrow">SOLO ADMINISTRACIÓN</span><h2>Contacto de emergencia</h2><p className="muted">El número aparece en el panel del conductor para llamar voluntariamente. Las alertas de riesgo se muestran en la central; este campo no envía SMS ni realiza llamadas automáticas.</p><form action={save} className="inline-form"><label>Número<input name="phone" type="tel" inputMode="tel" maxLength={16} defaultValue={phone} placeholder="Número autorizado"/></label><label>Etiqueta<input name="label" maxLength={80} defaultValue={label} placeholder="Central de emergencia"/></label><button className="button primary" disabled={busy}>{busy ? 'Guardando…' : 'Guardar contacto'}</button></form>{error && <p className="notice danger" role="alert">{error}</p>}</section>;
}
function AdminVehicleForm({ client, org, onNotice }: { client: Client; org: string; onNotice: (s: string) => void }) {
  const [busy, setBusy] = useState(false); const [error, setError] = useState('');
  const attemptId = useRef<string | null>(null);
  async function save(form: FormData) {
    setBusy(true); setError('');
    if (!attemptId.current) attemptId.current = crypto.randomUUID();
    try { const id = attemptId.current; await setDoc(doc(client.db, 'organizations', org, 'vehicles', id), { id, organizationId: org, internalCode: String(form.get('code')).trim(), vehicleType: String(form.get('vehicleType')), status: 'ACTIVE' }); attemptId.current = null; onNotice('Vehículo registrado en tu organización.'); }
    catch (e) { setError(firebaseError(e)); } finally { setBusy(false); }
  }
  return <section className="panel form-panel"><span className="eyebrow">SOLO ADMINISTRACIÓN</span><h2>Registrar vehículo</h2><form action={save} className="inline-form"><label>Código interno<input name="code" required maxLength={40} placeholder="BUS-001"/></label><label>Tipo<select name="vehicleType"><option value="BUS">Bus</option><option value="MINIBUS">Minibús</option><option value="TRUCK">Camión</option><option value="VAN">Van</option></select></label><button className="button primary" disabled={busy}>{busy ? 'Guardando…' : 'Registrar vehículo'}</button></form>{error && <p className="notice danger" role="alert">{error}</p>}</section>;
}
function AdminTripForm({ client, org, vehicles, onNotice }: { client: Client; org: string; vehicles: Vehicle[]; onNotice: (s: string) => void }) {
  const [busy, setBusy] = useState(false); const [error, setError] = useState('');
  const attemptId = useRef<string | null>(null);
  async function save(form: FormData) {
    setBusy(true); setError(''); if (!attemptId.current) attemptId.current = crypto.randomUUID();
    const driverId = String(form.get('driverId')).trim(); const vehicleId = String(form.get('vehicleId'));
    if (!/^[a-zA-Z0-9_-]{1,128}$/.test(driverId)) { setError('UID de conductor inválido.'); setBusy(false); return; }
    try {
      await setDoc(doc(client.db, 'organizations', org, 'assignments', driverId), { userId: driverId, organizationId: org, vehicleId, status: 'ACTIVE' });
      const id = attemptId.current;
      const tripRef = doc(client.db, 'organizations', org, 'trips', id);
      await runTransaction(client.db, async transaction => {
        const existing = await transaction.get(tripRef); if (existing.exists()) return;
        transaction.set(tripRef, { id, organizationId: org, vehicleId, driverId, origin: String(form.get('origin')).trim(), destination: String(form.get('destination')).trim(), startTime: serverTimestamp(), endTime: null, status: 'ASSIGNED', monitoringStatus: 'PAUSED', lastEventAt: null, lastSeenAt: null });
      });
      attemptId.current = null; onNotice('Viaje asignado. El conductor lo puede seleccionar desde Android con consentimiento.');
    } catch (e) { setError(firebaseError(e)); } finally { setBusy(false); }
  }
  return <section className="panel form-panel"><span className="eyebrow">SOLO ADMINISTRACIÓN</span><h2>Asignar viaje</h2><p className="muted">El conductor debe tener una membresía DRIVER activa. La asignación vincula su vehículo antes de crear el viaje.</p><form action={save} className="inline-form"><label>Vehículo<select name="vehicleId" required><option value="">Seleccionar…</option>{vehicles.filter(v => v.status === 'ACTIVE').map(v => <option key={v.id} value={v.id}>{v.internalCode}</option>)}</select></label><label>UID del conductor<input name="driverId" required maxLength={128}/></label><label>Origen<input name="origin" required maxLength={120}/></label><label>Destino<input name="destination" required maxLength={120}/></label><button className="button primary" disabled={busy || !vehicles.length}>{busy ? 'Asignando…' : 'Asignar viaje'}</button></form>{error && <p className="notice danger" role="alert">{error}</p>}<p className="microcopy">Si la creación falla después de vincular el vehículo, la asignación permanece y puede reintentarse con el mismo ID de viaje.</p></section>;
}
function AdminMembershipForm({ client, org, currentUid, onNotice }: { client: Client; org: string; currentUid: string; onNotice: (s: string) => void }) {
  const [busy, setBusy] = useState(false); const [error, setError] = useState('');
  async function save(form: FormData) {
    const uid = String(form.get('uid')).trim();
    if (!/^[a-zA-Z0-9_-]{1,128}$/.test(uid)) { setError('UID inválido. Usa el identificador de Firebase Authentication.'); return; }
    if (uid === currentUid) { setError('Esta pantalla no cambia tu propia membresía para evitar perder el acceso administrativo.'); return; }
    setBusy(true); setError('');
    try { await setDoc(doc(client.db, 'organizations', org, 'members', uid), { userId: uid, organizationId: org, role: String(form.get('role')), status: String(form.get('status')) }); onNotice('Membresía actualizada. La cuenta debe existir en Firebase Authentication.'); }
    catch (e) { setError(firebaseError(e)); } finally { setBusy(false); }
  }
  return <section className="panel form-panel"><span className="eyebrow">SOLO ADMINISTRACIÓN</span><h2>Gestionar membresía</h2><p className="muted">Introduce el UID de una cuenta ya creada en Firebase Authentication. Este formulario asigna o actualiza el acceso únicamente a esta organización.</p><form action={save} className="inline-form"><label>UID de la cuenta<input name="uid" required maxLength={128}/></label><label>Rol<select name="role"><option value="DRIVER">Conductor · DRIVER</option><option value="OPERATOR">Operador · OPERATOR</option><option value="ADMIN">Administrador · ADMIN</option></select></label><label>Estado<select name="status"><option value="ACTIVE">Activo</option><option value="INACTIVE">Inactivo</option></select></label><button className="button primary" disabled={busy}>{busy ? 'Guardando…' : 'Guardar membresía'}</button></form>{error && <p className="notice danger" role="alert">{error}</p>}</section>;
}
