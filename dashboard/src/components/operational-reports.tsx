'use client';
import { useState } from 'react';
import { formatDate, incidentStatus, STATUS_LABELS, TYPE_LABELS, type Incident, type OperatorAction, type Trip } from '@/lib/domain';
import { EMPTY_INCIDENT_FILTERS, filterIncidents, incidentAnalytics, incidentCsv, limaDay, type IncidentFilters } from '@/lib/reports';
import { Badge, Empty, Stat } from './ui';

export function OperationalReports({ incidents, actions, trips }: { incidents: Incident[]; actions: OperatorAction[]; trips: Trip[] }) {
  const [filters, setFilters] = useState<IncidentFilters>({ ...EMPTY_INCIDENT_FILTERS });
  const filtered = filterIncidents(incidents, trips, filters);
  const analytics = incidentAnalytics(filtered, actions);
  const update = (key: keyof IncidentFilters, value: string) => setFilters(current => ({ ...current, [key]: value }));
  const options = (values: string[]) => [...new Set(values)].sort().map(value => <option key={value} value={value}>{value}</option>);
  const days = new Map<string, number>();
  filtered.forEach(incident => { const day = limaDay(incident.detectedAt); days.set(day, (days.get(day) ?? 0) + 1); });
  const maximum = Math.max(1, ...days.values());
  function csvExport() {
    const url = URL.createObjectURL(new Blob([incidentCsv(filtered, actions)], { type: 'text/csv;charset=utf-8' }));
    const link = document.createElement('a'); link.href = url; link.download = 'guardian-incidentes-filtrados.csv'; link.click(); URL.revokeObjectURL(url);
  }
  return <><section className="panel form-panel"><span className="eyebrow">VENTANA AUTORIZADA · FECHA DE DETECCIÓN EN AMERICA/LIMA</span><h2>Filtrar incidentes recibidos</h2><div className="inline-form report-filters">
    <label>Desde<input type="date" value={filters.from} onChange={e => update('from', e.target.value)}/></label><label>Hasta<input type="date" value={filters.to} min={filters.from || undefined} onChange={e => update('to', e.target.value)}/></label>
    <label>Vehículo<select value={filters.vehicleId} onChange={e => update('vehicleId', e.target.value)}><option value="">Todos</option>{options(trips.map(t => t.vehicleId))}</select></label>
    <label>Conductor<select value={filters.driverId} onChange={e => update('driverId', e.target.value)}><option value="">Todos</option>{options(incidents.map(i => i.driverId))}</select></label>
    <label>Viaje<select value={filters.tripId} onChange={e => update('tripId', e.target.value)}><option value="">Todos</option>{options(incidents.map(i => i.tripId))}</select></label>
    <label>Severidad<select value={filters.severity} onChange={e => update('severity', e.target.value)}><option value="">Todas</option><option value="CRITICAL">Crítica</option><option value="WARNING">Advertencia</option><option value="INFO">Informativa</option></select></label>
    <label>Tipo de señal<select value={filters.type} onChange={e => update('type', e.target.value)}><option value="">Todos</option>{Object.entries(TYPE_LABELS).map(([value, label]) => <option value={value} key={value}>{label}</option>)}</select></label>
    <button className="button secondary" onClick={() => setFilters({ ...EMPTY_INCIDENT_FILTERS })}>Limpiar filtros</button></div>{filters.from && filters.to && filters.from > filters.to && <p className="notice warning" role="alert">La fecha de inicio debe ser anterior o igual a la fecha final.</p>}<p className="microcopy">Los filtros se aplican al gráfico, los indicadores de incidentes, la tabla y el CSV. Si el viaje no está en la ventana recibida, no se puede asociar su vehículo.</p></section>
    <div className="stats-row"><Stat label="Incidentes filtrados" value={filtered.length} detail="Eventos recibidos en esta ventana"/><Stat label="Alertas críticas" value={analytics.critical} detail="Severidad reportada por Android" tone="stat-danger"/><Stat label="Eventos sin señal fiable" value={analytics.signalUnavailable} detail="No implican fatiga" tone="stat-warning"/><Stat label="Tiempo medio a reconocimiento" value={analytics.meanAcknowledgementMs === null ? '—' : `${Math.round(analytics.meanAcknowledgementMs / 1000)} s`} detail={`${analytics.acknowledgedCount} eventos con reconocimiento válido`}/></div>
    <section className="panel"><div className="panel-heading"><div><span className="eyebrow">EVENTOS FILTRADOS</span><h2>Evolución por fecha de detección</h2></div><button className="button secondary small" disabled={!filtered.length} onClick={csvExport}>Exportar CSV</button></div>{!filtered.length ? <Empty title="Sin datos para estos filtros">Ajusta los filtros o espera incidentes autorizados. No se generan resultados de ejemplo.</Empty> : <div className="bar-chart" role="img" aria-label="Cantidad de incidentes filtrados por fecha de detección">{[...days.entries()].sort(([a], [b]) => a.localeCompare(b)).map(([day, count]) => <div className="bar-row" key={day}><span>{day}</span><div><i style={{ width: `${count / maximum * 100}%` }}/></div><strong>{count}</strong></div>)}</div>}</section>
    <section className="panel"><div className="panel-heading"><h2>Historial de incidentes</h2><Badge>{filtered.length} resultados</Badge></div>{!filtered.length ? <Empty title="Historial vacío">No hay eventos que coincidan en la ventana autorizada.</Empty> : <div className="table-wrap"><table><thead><tr><th>Señal / incidente</th><th>Conductor / viaje</th><th>Detección</th><th>Recepción</th><th>Estado</th></tr></thead><tbody>{filtered.map(incident => <tr key={incident.id}><td>{TYPE_LABELS[incident.type] ?? incident.type}<span className="table-sub">{incident.id}</span></td><td className="mono">{incident.driverId}<span className="table-sub">{incident.tripId}</span></td><td>{formatDate(incident.detectedAt)}</td><td>{incident.receivedAt === null ? 'Pendiente' : formatDate(incident.receivedAt)}</td><td>{STATUS_LABELS[incidentStatus(incident.id, actions)]}</td></tr>)}</tbody></table></div>}<p className="microcopy" style={{ padding: '0 22px 18px' }}>El tiempo de reconocimiento se mide desde la detección hasta la primera acción ACKNOWLEDGED recibida; incluye demoras de conectividad. No estima precisión clínica ni accidentes evitados.</p></section>
  </>;
}
