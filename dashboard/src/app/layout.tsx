import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: { default: 'DriverAwaken Guardian · Seguridad que conecta', template: '%s · Guardian' },
  description: 'Asistencia preventiva local y gestión de incidentes de fatiga para flotas regionales. Demo pública con datos simulados.',
  robots: { index: false, follow: false },
};
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="es"><body><a className="skip-link" href="#main">Saltar al contenido</a>{children}</body></html>;
}
