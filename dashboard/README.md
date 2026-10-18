# DriverAwaken Guardian — central web

Next.js + TypeScript + Tailwind CSS + Firebase JS SDK. Exportación estática para Firebase Hosting. No requiere servidor Next en producción.

## Ejecución

Node.js 22 recomendado (Next requiere >=20.9). Desde `dashboard/`:

```powershell
npm ci
npm run dev
```

Abrir `http://127.0.0.1:3000`. `/`, `/demo/` y `/pitch/` funcionan sin Firebase ni cuentas.

Para la central real, copiar `.env.example` a `.env.local` y completar la configuración pública de una aplicación web del proyecto Firebase autorizado. Habilitar Authentication con correo y contraseña, provisionar cuentas y ejecutar el bootstrap administrativo documentado en la raíz. **No usar credenciales Admin SDK en variables NEXT_PUBLIC**. No se copiaron credenciales personales del repositorio.

Las variables NEXT_PUBLIC se incorporan al bundle durante el build; reconstruir al cambiarlas. Configurar `NEXT_PUBLIC_USE_EMULATORS=true` exclusivamente para desarrollo local (Auth 9098, Firestore 8085). Los emuladores se inician usando las instrucciones de backend en la raíz.

## Rutas

- `/`: producto y recorrido operativo.
- `/demo/`: simulación sintética, local y separada de Firebase.
- `/pitch/`: 10 diapositivas, flechas / Inicio / Fin, avance opcional cada 18 segundos.
- `/dashboard/`: autenticación, membresía activa OPERATOR o ADMIN, resumen con snapshots.
- `/dashboard/trips/`: viajes y creación ADMIN con asignación de vehículo previa.
- `/dashboard/incidents/`: detección, reconocimiento, nota y resolución; todas las acciones se agregan en documentos independientes.
- `/dashboard/fleet/`: vehículos y registro ADMIN.
- `/dashboard/drivers/`: membresías DRIVER reales, viaje operativo o último conocido, riesgo reportado y frescura de observación.
- `/dashboard/rest/`: descansos finalizados compartidos voluntariamente; no infiere recuperación ni muestra GPS.
- `/dashboard/reports/`: filtros por fecha de detección en Lima, vehículo, conductor, viaje, severidad y tipo; gráfico, indicadores y CSV comparten el mismo alcance.
- `/dashboard/settings/`: organización, rol, cambio de organización y gestión ADMIN de membresías existentes.

La selección de organización se conserva en sessionStorage por UID. Se vuelve a verificar la membresía en cada página. No existe una consulta global que permita descubrir organizaciones ajenas. No se permite autorregistro ni elevación de privilegios desde la central.

## Demo reproducible

1. Abrir `/demo/`, pulsar **Reiniciar demostración**, seleccionar un destino ficticio e **Iniciar viaje simulado**.
2. **Simular pérdida de conectividad**.
3. **Simular cierre ocular prolongado**: conserva un incidente `QUEUED` en localStorage.
4. Recargar: el ID, tiempo de detección y evento pendiente permanecen.
5. **Restaurar conectividad**: el mismo ID pasa a `SYNCED`; la recepción ocurre después de la detección.
6. **Reconocer incidente**, escribir una nota y **Registrar acción**.
7. Agregar una nota de cierre y **Resolver incidente**; terminar o reiniciar escenario.

El evento también genera una recomendación Smart Rest. Los lugares son explícitamente ficticios; seleccionarlos no registra una pausa. Marcar la confirmación voluntaria e **Iniciar descanso simulado** pausa el monitoreo del escenario. **Terminar descanso simulado** cierra la sesión, registra su duración lógica y permite reanudar las señales. El historial persiste offline junto con los incidentes. No hay GPS, búsquedas de lugares reales, navegación ni mapas de proveedor en esta simulación web.

El reloj inicia en un instante fijo y avanza 30 segundos por interacción aceptada. Señales repetidas se agrupan durante un cooldown de 90 segundos por tipo. La outbox demo está acotada a 100 incidentes; el timeline conserva los últimos 120 pasos. La demo no ejecuta el detector, no usa Firebase, ni prueba el backoff del móvil. Si el navegador bloquea almacenamiento, se informa que la sesión no persistirá.

## Validación y exportación

```powershell
npm run typecheck
npm run lint
npm test
npm run build
npx playwright install chromium
npm run test:e2e
```

`build` crea `dashboard/out/`. Las pruebas E2E sirven esa exportación con `node scripts/serve.mjs` en `http://127.0.0.1:3100`; prueban escritorio y móvil. El servidor es una utilidad local de verificación, no un backend de producción.

Publicar únicamente después de autorización, desde la configuración de Firebase Hosting de la raíz. No se realizó publicación remota desde este módulo. El documento raíz `TECHNICAL_VALIDATION.md` registra qué comprobaciones se ejecutaron realmente.

## Límites de datos

La central carga hasta 200 viajes, 300 incidentes y 1000 acciones recientes, además de 300 vehículos, 300 membresías y 200 descansos finalizados autorizados. Los indicadores y el CSV describen esa ventana, no todo el histórico. Si un incidente tiene acciones fuera de la ventana, su estado derivado puede requerir una consulta histórica adicional. La outbox del teléfono es local: la central no inventa un conteo de eventos que todavía no recibió.

Un viaje ACTIVE no implica monitoreo continuo. Solo se cuenta como monitoreo con señal reciente si su estado es ACTIVE y su `lastSeenAt` tiene menos de dos minutos. Esto indica frescura de la última observación del teléfono confirmada por el servidor, no disponibilidad garantizada. La detección original no se modifica al reconocer o resolver; los intentos de acción conservan un ID para reintentos idempotentes y una transacción evita duplicar documentos.

ADMIN puede crear una asignación y después un viaje ASSIGNED. Si falla la creación del viaje, la asignación permanece; la pantalla lo explica. Las cuentas Auth deben existir previamente; la central no puede comprobar usuarios mediante un directorio privilegiado. Las reglas Firestore son la autoridad de acceso y validación.

Las imágenes y vectores faciales no forman parte de este contrato. Las preferencias de consentimiento pertenecen a Android. El índice de riesgo es heurístico, no una probabilidad de accidente, y el producto no sustituye los protocolos de seguridad.

## Integración de navegador con emuladores

Después de iniciar Auth/Firestore y ejecutar `backend/scripts/seed-emulators.mjs` según la documentación de la raíz:

```powershell
npm run build:emulator
npm run test:emulator
# Restaurar la exportación normal antes de publicar o compartir el artefacto:
npm run build
```

Estos scripts usan por defecto `demo-guardian`, localhost y las cuentas ficticias publicadas por el seed local. No requieren credenciales reales. Verifican autenticación por correo, incidente emitido por el SDK DRIVER, snapshot en la central, respuesta OPERATOR, denegación de DRIVER y creación ADMIN de membresía/vehículo/viaje. Es integración de navegador + SDK + reglas en emuladores; no demuestra ejecución Android ni Firebase de producción. La suite de seguridad del backend limpia sus datos: usar configuraciones y puertos aislados si se ejecutan simultáneamente.

Para ejecutar la integración web en paralelo con otras suites, `backend/firebase.web-test.json` reserva Firestore **8285**, Auth **9298**, hub 4425 y logging 4525 para el proyecto ficticio **demo-guardian-web**. Los puertos de desarrollo predeterminados continúan siendo 8085/9098. Desde `backend/`, iniciar `firebase emulators:start --only auth,firestore --project demo-guardian-web --config firebase.web-test.json` y esperar «All emulators ready». En otra terminal de `backend/`:

```powershell
$env:FIRESTORE_EMULATOR_HOST='127.0.0.1:8285'
$env:FIREBASE_AUTH_EMULATOR_HOST='127.0.0.1:9298'
$env:GUARDIAN_EMULATOR_PROJECT='demo-guardian-web'
node scripts/seed-emulators.mjs
```

Después, desde `dashboard/`:

```powershell
$env:GUARDIAN_EMULATOR_PROJECT='demo-guardian-web'
$env:GUARDIAN_AUTH_EMULATOR_PORT='9298'
$env:GUARDIAN_FIRESTORE_EMULATOR_PORT='8285'
npm run build:emulator
npm run test:emulator
npm run build
```

El seed rechaza hosts distintos de `127.0.0.1`, puertos inválidos y proyectos sin prefijo `demo-`. El wrapper incorpora los puertos validados a variables públicas únicamente en su proceso hijo. El build normal final restaura una exportación sin activar los emuladores; no se deben publicar artefactos de `build:emulator`.

La integración aislada del 17 de octubre completó **10 pruebas E2E** (escritorio y móvil) con salida 0: evento del SDK DRIVER, respuesta OPERATOR, rechazo de acceso DRIVER, membresías, descansos declarados, filtros y contenido real del CSV descargado, además de altas ADMIN. Los emuladores de esta prueba fueron detenidos sin alterar el emulador que ya estaba abierto en 8085/9098.

Referencias oficiales: [exportación estática Next.js](https://nextjs.org/docs/app/guides/static-exports), [snapshots de Firestore](https://firebase.google.com/docs/firestore/query-data/listen), [transacciones de Firestore](https://firebase.google.com/docs/firestore/manage-data/transactions).

El tiempo medio a reconocimiento usa la primera acción ACKNOWLEDGED válida por incidente filtrado, desde la detección e incluyendo demoras de conectividad. Sin reconocimientos, muestra un guion; no fabrica ceros. Los viajes finalizados o asignados nunca muestran monitoreo en curso, aunque conserven una última observación reciente. El resumen final de la demo expone duración lógica, incidentes, acciones, descansos y eventos pendientes.

## Validación local del 17 de octubre de 2026

`npm run typecheck`, `npm run lint`, `npm test` (24 pruebas) y `npm run build` completaron sin errores. La exportación incluye 13 rutas, entre ellas Conductores y Descansos. Las nuevas pruebas unitarias verifican frescura y estado de monitoreo, orden de detección frente a recepción tardía, prioridad de viajes activos, fechas de Lima, combinación de filtros, tiempo al primer reconocimiento válido y que una señal insuficiente se muestre como «No evaluable» en lugar de bajo riesgo. El build y estas pruebas no demuestran una conexión Firebase de producción ni ejecución física Android.

La suite pública de navegador completó 14 casos en Chrome de escritorio y Pixel 7 emulado: navegación, aislamiento de Firebase, persistencia offline, reconexión, respuesta humana, resumen final, descansos voluntarios, pitch, rutas protegidas, ancho responsive y foco de teclado. En este entorno Windows se ejecutó con `GUARDIAN_BROWSER_EXECUTABLE` apuntando al Chrome instalado y `node node_modules/@playwright/test/cli.js test e2e/public.spec.ts --workers=2`; la primera ejecución mediante npm completó los casos pero quedó esperando el cierre de su servidor. La ejecución con CLI Node terminó correctamente.
