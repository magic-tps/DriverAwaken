import Link from 'next/link';
import { Mark } from '@/components/ui';
export default function NotFound() { return <div className="access-page"><header><Mark/></header><main id="main" className="access-panel"><span className="eyebrow">404 / RUTA NO ENCONTRADA</span><h1>Volvamos al camino.</h1><p>Esta página no existe. Puedes abrir la demostración o volver al inicio.</p><Link href="/demo" className="button primary">Abrir demo</Link><Link href="/" className="button ghost">Inicio</Link></main></div>; }
