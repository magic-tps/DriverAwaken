import Link from 'next/link';
import { Badge, Icon, PublicHeader } from '@/components/ui';

export default function Home() {
  return <>
    <PublicHeader />
    <main id="main" className="landing landing-v2">
      <section className="landing-hero" aria-labelledby="landing-title">
        <div className="landing-hero-copy">
          <div className="landing-kicker"><span className="status-dot" /> SEGURIDAD EN CADA TRAYECTO <span className="landing-kicker-line" /></div>
          <h1 id="landing-title">Atento a las señales.<br /><em>Listo para actuar.</em></h1>
          <p className="landing-lead">DriverAwaken observa señales de somnolencia en el dispositivo, emite alertas locales y conecta los incidentes autorizados con una central de flota.</p>
          <div className="download-module" id="descargar">
            <div className="download-heading"><span className="download-icon"><Icon name="shield" size={23} /></span><div><span className="eyebrow">APLICACIÓN PARA CONDUCTORES</span><h2>Descarga DriverAwaken para Android</h2></div></div>
            <a className="button primary download-button" href="https://github.com/magic-tps/DriverAwaken/releases/download/v1.1.1-debug.3/DriverAwaken-1.1.1-debug.apk">Descargar APK de prueba <Icon name="arrow" size={18} /></a>
            <div className="download-meta"><span>Android</span><span>Versión 1.1.1+3</span><Badge tone="warning">Compilación debug / pruebas</Badge></div>
            <p>Descarga alojada en el repositorio oficial de GitHub. Instala únicamente si confías en esta fuente. Android puede solicitar autorización para instalar un APK externo. Esta compilación es de prueba, no una publicación de tienda.</p>
          </div>
          <Link href="/demo" className="landing-text-link">Conocer el flujo en la demo <Icon name="arrow" size={16} /></Link>
        </div>
        <div className="landing-monitor" aria-label="Esquema ilustrativo del monitoreo local y la central de flota">
          <div className="monitor-top"><span>DRIVERAWAKEN / MONITOREO</span><span><i /> ESQUEMA DEL PRODUCTO</span></div>
          <div className="monitor-view">
            <span className="monitor-corner corner-tl" /><span className="monitor-corner corner-tr" /><span className="monitor-corner corner-bl" /><span className="monitor-corner corner-br" />
            <div className="monitor-reticle"><span className="reticle-left" /><span className="reticle-right" /><i /></div>
            <span className="monitor-view-label">CÁMARA FRONTAL · PROCESAMIENTO LOCAL</span>
          </div>
          <div className="monitor-flow"><div><span className="flow-index">01 / DISPOSITIVO</span><strong>Detecta señales</strong><small>Estado de ojos · bostezos · posición de cabeza</small></div><span className="flow-connector" aria-hidden="true" /><div><span className="flow-index">02 / RESPUESTA</span><strong>Alerta local</strong><small>Visual, sonora y vibratoria según el estado</small></div></div>
          <div className="monitor-bottom"><Icon name="wifi" size={17} /><span>La alerta local no depende de la conexión. La central recibe eventos autorizados cuando hay conectividad.</span></div>
        </div>
      </section>

      <section className="portal-section" aria-labelledby="portal-title"><div className="section-heading"><span className="section-number">ACCESO POR ROL / 01</span><h2 id="portal-title">Una plataforma.<br /><em>Dos espacios de trabajo.</em></h2><p>Elige el acceso que corresponde a tu función. Ambos paneles requieren iniciar sesión.</p></div><div className="portal-grid">
        <article className="portal-card portal-card-admin"><div className="portal-card-top"><span className="portal-card-index">01 / CENTRAL DE FLOTA</span><Icon name="grid" size={24} /></div><h3>Administrador<br />y operador</h3><p>Consulta viajes e incidentes, registra acciones de respuesta y supervisa el historial de la flota autorizado para tu organización.</p><Link href="/dashboard" className="portal-link">Entrar al panel de administración <Icon name="arrow" size={18} /></Link><span className="portal-card-note">Acceso con cuenta y permisos de flota</span></article>
        <article className="portal-card portal-card-driver"><div className="portal-card-top"><span className="portal-card-index">02 / ESPACIO PERSONAL</span><Icon name="shield" size={24} /></div><h3>Conductor</h3><p>Accede a tu espacio personal para consultar la información de conducción disponible para tu cuenta y tu relación con la flota.</p><Link href="/driver" className="portal-link">Entrar al panel del conductor <Icon name="arrow" size={18} /></Link><span className="portal-card-note">Acceso con cuenta de conductor</span></article>
      </div></section>

      <section className="safety-section" aria-labelledby="safety-title"><div className="safety-lead"><span className="section-number">CÓMO FUNCIONA / 02</span><h2 id="safety-title">Primero, la persona.<br /><em>Después, los datos.</em></h2><p>La tecnología acompaña la decisión de detenerse de forma segura; no reemplaza la atención del conductor ni los protocolos de emergencia.</p></div><ol className="safety-steps"><li><span>01</span><div><h3>Señales en el teléfono</h3><p>La cámara frontal analiza señales faciales localmente. No se sube video ni fotografía a la central.</p></div></li><li><span>02</span><div><h3>Alerta inmediata</h3><p>Ante señales sostenidas de fatiga, DriverAwaken avisa en el dispositivo y recomienda detenerse en un lugar seguro.</p></div></li><li><span>03</span><div><h3>Central informada</h3><p>Si hay consentimiento y conectividad, el incidente autorizado se sincroniza para que el personal de flota pueda responder.</p></div></li><li><span>04</span><div><h3>Mapas, por decisión del conductor</h3><p>Google Maps es externo. Solo se abre voluntariamente, con el vehículo detenido; el monitoreo se pausa al salir de la app.</p></div></li></ol></section>

      <section className="landing-endnote"><div><span className="eyebrow">EXPLORA ANTES DE INGRESAR</span><h2>Observa el recorrido de una alerta.</h2><p>La demo usa datos simulados y no requiere una cuenta.</p></div><Link href="/demo" className="button secondary">Abrir demo interactiva <Icon name="arrow" size={18} /></Link></section>
    </main>
    <footer className="public-footer"><span>DRIVERAWAKEN GUARDIAN</span><span>Proyecto en desarrollo · <Link href="/pitch">Conoce el proyecto</Link></span><p>Asistencia preventiva ante señales de fatiga. No es un diagnóstico médico ni garantiza evitar accidentes. Si existe peligro, detente en un lugar seguro y sigue los protocolos de emergencia.</p></footer>
  </>;
}
