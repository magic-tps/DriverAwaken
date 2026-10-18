'use client';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import { Badge, Icon, Mark } from './ui';

const slides = [
  { chapter: 'EL PROBLEMA', title: 'La señal importa.\nLa respuesta también.', text: 'En el transporte regional, una alerta aislada no cuenta toda la historia. La central necesita contexto, incluso después de un tramo sin internet.', accent: 'El reto: conectar prevención local con una respuesta operativa trazable.', diagram: ['Conductor', 'Señal local', '¿Respuesta?'] },
  { chapter: 'PARA QUIÉN', title: 'Un mismo viaje.\nDos necesidades.', text: 'El conductor necesita asistencia simple y alertas locales. El operador necesita saber qué ocurrió y documentar cómo respondió.', accent: 'Diseñado para flotas regionales; requiere validación con operadores y conductores.', diagram: ['Conductor · atención', 'Operador · contexto', 'Flota · seguimiento'] },
  { chapter: 'LA PROPUESTA', title: 'DriverAwaken\nGuardian.', text: 'Plataforma de asistencia preventiva y gestión de señales de fatiga: del procesamiento facial en Android a la central operativa.', accent: 'Sin cámaras transmitiendo a la nube. Sin automatizar la conducción.', diagram: ['Alerta local', 'Registro persistente', 'Acción humana'] },
  { chapter: 'CÓMO FUNCIONA', title: 'Del rostro al evento.\nDel evento a la acción.', text: 'El motor temporal evalúa cierre ocular, PERCLOS y otras señales. Un adaptador clasifica incidentes, evita duplicados y conserva el contexto.', accent: 'Señal insuficiente no equivale a somnolencia. El índice es heurístico.', diagram: ['Señal + calidad', 'Reglas temporales', 'Incidente explicable'] },
  { chapter: 'DEMOSTRACIÓN', title: 'Pierde la conexión.\nConserva la evidencia.', text: 'En la demo: desconecta, genera un cierre ocular prolongado, reconecta y registra una acción. Observa detección y recepción por separado.', accent: 'DEMO — DATOS SIMULADOS. Entorno público aislado de Firebase.', diagram: ['Desconectar', 'Generar alerta', 'Reconectar + responder'] },
  { chapter: 'ARQUITECTURA', title: 'Lo crítico, local.\nLo compartido, autorizado.', text: 'Flutter y el motor existente en el dispositivo. SQLite/Drift para persistencia. Firebase Auth y Firestore para acceso por organización. Next.js en la central.', accent: 'Las alertas locales no dependen de que Firebase esté disponible.', diagram: ['Android + SQLite', 'Auth + Firestore', 'Next.js · central'] },
  { chapter: 'DIFERENCIACIÓN', title: 'Diseñado para\nla señal intermitente.', text: 'Outbox con identidad estable, reintentos limitados y separación de tiempos. La acción del operador se agrega sin sobrescribir la detección.', accent: 'Privacidad por diseño: sin video, frames, landmarks ni vectores biométricos en la sincronización.', diagram: ['Offline primero', 'IDs estables', 'Auditoría humana'] },
  { chapter: 'VALIDACIÓN', title: 'Evidencia técnica.\nLímites explícitos.', text: 'El repositorio incluye pruebas del simulador, persistencia, deduplicación, acceso y flujo operativo. Los comandos ejecutados y resultados se documentan en TECHNICAL_VALIDATION.md.', accent: 'Sin estadísticas clínicas ni precisión inventada. El modelo TFLite incompatible permanece desactivado.', diagram: ['Pruebas reproducibles', 'Sin métricas inventadas', 'Validación de campo pendiente'] },
  { chapter: 'ADOPCIÓN', title: 'Empezar pequeño.\nAprender con la operación.', text: 'Propuesta: piloto voluntario con una flota, protocolos acordados y medición de señales, latencia y respuesta. El uso personal sigue disponible.', accent: 'Modelo de adopción por validar. No se afirma que existan clientes ni pilotos realizados.', diagram: ['Consentimiento', 'Piloto controlado', 'Medir y ajustar'] },
  { chapter: 'SIGUIENTE ETAPA', title: 'Cerrar el circuito.\nValidarlo en campo.', text: 'Verificar Android → Firestore → central en dispositivo autorizado. Medir falsos positivos, desempeño y continuidad. Definir retención y procesos antes de escalar.', accent: 'Buscamos aliados de transporte para validar utilidad y operación segura.', diagram: ['Integración real', 'Validación de campo', 'Adopción responsable'] },
];
export function Pitch() {
  const [index, setIndex] = useState(0);
  const [playing, setPlaying] = useState(false);
  const slide = slides[index];
  useEffect(() => {
    function key(event: KeyboardEvent) {
      if (['INPUT', 'TEXTAREA', 'SELECT'].includes((event.target as HTMLElement).tagName)) return;
      if (event.key === 'ArrowRight' || event.key === 'PageDown') { event.preventDefault(); setIndex(i => Math.min(9, i + 1)); }
      if (event.key === 'ArrowLeft' || event.key === 'PageUp') { event.preventDefault(); setIndex(i => Math.max(0, i - 1)); }
      if (event.key === 'Home') { event.preventDefault(); setIndex(0); }
      if (event.key === 'End') { event.preventDefault(); setIndex(9); }
    }
    window.addEventListener('keydown', key); return () => window.removeEventListener('keydown', key);
  }, []);
  useEffect(() => {
    if (!playing || index === 9) return;
    const timer = setTimeout(() => setIndex(i => Math.min(9, i + 1)), 18_000);
    return () => clearTimeout(timer);
  }, [playing, index]);
  return <div className="pitch-page"><header className="pitch-header"><Mark small/><Badge tone="blue">HACK THE ANDES 2026 · TRANSPORT</Badge><Link href="/demo" className="button secondary small">Demo interactiva <Icon name="arrow" size={16}/></Link></header><main id="main" className="pitch-stage" aria-live="polite"><div key={index} className="slide"><span className="pitch-chapter"><span>{String(index + 1).padStart(2, '0')}</span> / {slide.chapter}</span><h1>{slide.title.split('\n').map((line, i) => <span key={line} className={i === 1 ? 'accent' : ''}>{line}<br/></span>)}</h1><p className="pitch-description">{slide.text}</p><div className="pitch-diagram">{slide.diagram.map((label, i) => <div key={label}><span className="diagram-index">0{i + 1}</span><strong>{label}</strong>{i < 2 && <Icon name="arrow"/>}</div>)}</div><p className="pitch-accent">{slide.accent}</p>{index === 4 && <Link className="button primary" href="/demo">Abrir escenario de demostración <Icon name="play" size={17}/></Link>}</div><span className="slide-watermark" aria-hidden="true">{String(index + 1).padStart(2, '0')}</span></main><footer className="pitch-controls"><div><button className="button ghost small" disabled={index === 0} onClick={() => setIndex(i => i - 1)}>← Anterior</button><span className="slide-count">{index + 1} / 10</span><button className="button secondary small" disabled={index === 9} onClick={() => setIndex(i => i + 1)}>Siguiente →</button></div><div className="slide-dots" aria-label="Seleccionar diapositiva">{slides.map((s, i) => <button key={s.chapter} aria-label={`Diapositiva ${i + 1}: ${s.chapter}`} aria-current={i === index ? 'step' : undefined} className={i === index ? 'active' : ''} onClick={() => setIndex(i)}/>)}</div><button className="text-button" onClick={() => { if (index === 9) setIndex(0); setPlaying(v => !v); }}>{playing ? 'Pausar avance automático' : 'Auto · 18 s por diapositiva'}</button></footer><p className="pitch-shortcuts">← → para navegar · Inicio / Fin · 10 diapositivas / 3 minutos</p></div>;
}
