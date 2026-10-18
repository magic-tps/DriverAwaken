import Link from 'next/link';
import type { ReactNode } from 'react';

export function Mark({ small = false }: { small?: boolean }) {
  return <Link href="/" className={`brand ${small ? 'brand-small' : ''}`} aria-label="DriverAwaken Guardian, inicio"><span className="brand-symbol"><svg viewBox="0 0 32 32" aria-hidden="true"><path d="M16 3 27 8v8c0 6-6 10-11 13C11 26 5 22 5 16V8Z"/><path d="m9 16 4 4 10-10"/></svg></span><span>DRIVERAWAKEN<span className="brand-sub">GUARDIAN</span></span></Link>;
}
export function Icon({ name, size = 20 }: { name: 'grid' | 'route' | 'alert' | 'bus' | 'chart' | 'settings' | 'arrow' | 'play' | 'check' | 'wifi' | 'shield' | 'clock' | 'logout'; size?: number }) {
  const paths = {
    grid: 'M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 14h7v7h-7z',
    route: 'M5 6a2 2 0 1 0 0 .1M19 18a2 2 0 1 0 0 .1M7 6h8a4 4 0 0 1 0 8H9a4 4 0 0 0 0 8h8',
    alert: 'm12 3 10 18H2L12 3Zm0 6v5m0 3v1', bus: 'M5 17H3V5q0-3 3-3h12q3 0 3 3v12h-2M3 11h18M7 17h10M7 20v-3M17 20v-3M7 14v.1M17 14v.1M12 2v9',
    chart: 'M3 3v18h18M7 16v-4m5 4V7m5 9V4', settings: 'M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8ZM9 3h6l1 3 3 1 2 5-2 5-3 1-1 3H9l-1-3-3-1-2-5 2-5 3-1Z',
    arrow: 'M4 12h16m-6-6 6 6-6 6', play: 'm8 4 13 8-13 8V4Z', check: 'm4 12 5 5L20 6', wifi: 'M2 8a16 16 0 0 1 20 0M5 12a11 11 0 0 1 14 0M8 16a6 6 0 0 1 8 0M12 20v.1',
    shield: 'M12 2 21 6v7c0 5-6 8-9 9-3-1-9-4-9-9V6l9-4Zm-5 10 3 3 7-7', clock: 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm0 4v6l4 3', logout: 'M10 3H3v18h7M8 12h13m-5-5 5 5-5 5',
  };
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d={paths[name]}/></svg>;
}
export function Badge({ children, tone = 'neutral' }: { children: ReactNode; tone?: 'neutral' | 'success' | 'warning' | 'danger' | 'blue' }) {
  return <span className={`badge badge-${tone}`}>{children}</span>;
}
export const navigation = [
  { href: '/dashboard', label: 'Resumen', icon: 'grid' }, { href: '/dashboard/trips', label: 'Viajes', icon: 'route' },
  { href: '/dashboard/incidents', label: 'Incidentes', icon: 'alert' }, { href: '/dashboard/fleet', label: 'Flota', icon: 'bus' },
  { href: '/dashboard/drivers', label: 'Conductores', icon: 'shield' }, { href: '/dashboard/rest', label: 'Descansos', icon: 'clock' },
  { href: '/dashboard/reports', label: 'Historial y análisis', icon: 'chart' }, { href: '/dashboard/settings', label: 'Ajustes', icon: 'settings' },
] as const;
export function Empty({ title, children }: { title: string; children: ReactNode }) {
  return <div className="empty"><span className="empty-symbol"><Icon name="shield" size={26}/></span><h3>{title}</h3><p>{children}</p></div>;
}
export function Stat({ label, value, detail, tone = '' }: { label: string; value: number | string; detail: string; tone?: string }) {
  return <div className={`stat ${tone}`}><span className="eyebrow">{label}</span><strong>{value}</strong><span className="muted">{detail}</span></div>;
}
export function PublicHeader() {
  return <header className="public-header"><Mark/><nav aria-label="Navegación principal"><Link href="/#descargar">Descargar APK</Link><Link href="/dashboard">Admin / Operador</Link><Link href="/driver">Conductor</Link><Link href="/demo" className="button ghost small">Ver demo <Icon name="arrow" size={16}/></Link></nav></header>;
}
