import type { Metadata } from 'next';
import { DriverPortal } from '@/components/driver-portal';

export const metadata: Metadata = {
  title: 'Portal del conductor',
  description: 'Consulta privada de viajes, alertas recibidas y descansos compartidos por DriverAwaken.',
  robots: { index: false, follow: false },
};

export default function DriverPage() {
  return <DriverPortal />;
}
