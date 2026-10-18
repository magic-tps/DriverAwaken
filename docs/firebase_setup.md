# Firebase: cuentas y copias de informes

## Avisos a supervisores (implementados localmente; despliegue pendiente)

Los incidentes `WARNING` y `CRITICAL` de una flota activa pueden generar avisos web por Firebase Cloud Messaging. La función `backend/functions/index.mjs`, ubicada en `us-central1` junto a la base Firestore `nam5`, comprueba de nuevo la membresía `ADMIN`/`OPERATOR` activa antes de enviar; los eventos `INFO` no disparan push. El navegador del supervisor debe activar voluntariamente **Activar avisos** en la central. Los tokens quedan privados bajo `alertSubscriptions`, y al cerrar sesión o cambiar de organización se intenta revocar la suscripción. La función conserva un registro de despacho para evitar notificaciones repetidas ante reintentos. La alarma local del conductor no depende de FCM ni de Internet.

Para poner esta función en servicio hay que configurar `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID` y `NEXT_PUBLIC_FIREBASE_VAPID_KEY` en el dashboard, habilitar FCM/Web Push en el proyecto Firebase, compilar y publicar la web, instalar dependencias en `backend/functions` y desplegar **reglas y función** con credenciales de despliegue autorizadas. No se desplegó ni se verificó entrega a un navegador real en esta sesión. El SDK web instalado aún usa `getToken`; Firebase lo considera una API en transición, por lo que conviene migrar a `register`/FID cuando el Admin SDK de este proyecto admita envíos FID.

```powershell
cd backend/functions
npm install
npm test
cd ../..
firebase deploy --only firestore:rules,functions --project driverawaken
cd dashboard
npm run build
```

Después de publicar la central por HTTPS, se requiere una prueba de extremo a extremo con una cuenta de operador real y un incidente de prueba legítimo: conceder permiso de notificaciones, recibir un aviso en segundo plano, abrir el incidente, reconocerlo y comprobar que una membresía revocada ya no recibe mensajes. FCM no garantiza entrega instantánea ni sustituye la alerta local.

## Guardian — ampliación pendiente de publicación (2026-10-17)

La ampliación Guardian añade colecciones `organizations/{org}` con `members`, `vehicles`, `assignments`, `trips`, `incidents`, `operatorActions` y `restSessions`. Roles ADMIN/OPERATOR/DRIVER y aislamiento se aplican en `backend/firestore.rules`; `users/{uid}/reports/{id}` conserva su esquema y acceso personal. Las reglas se verificaron con 17 pruebas en emulador y se publicaron en `driverawaken` el 18 de octubre de 2026.

La organización y su primera membresía ADMIN solo se crean con `backend/scripts/bootstrap.mjs` y credenciales Admin autorizadas. Los clientes no pueden autoasignarse un rol. Incidentes solo para viajes activos propios y asignados; acciones del operador anexas e inmutables. No se envían imágenes ni vectores biométricos. El consentimiento para flota es distinto de la copia manual de informes personales.

La configuración pública de Firebase web vive en variables `NEXT_PUBLIC_FIREBASE_*`, nunca en una clave Admin. La guía operativa actual, cuentas ficticias de emulador, comandos exactos y pasos pendientes están en `DEPLOYMENT.md` de la raíz. Las afirmaciones históricas sobre la nube a continuación no certifican el estado actual del proyecto remoto: no se reconsultó ni modificó en esta sesión.

## Configuración implementada

- Proyecto: `driverawaken`.
- Application ID Android: `driver_.awaken`, elegido por el propietario. Android instala esta variante como otra app; los datos de `com.magicdrive.alert` no se migran automáticamente.
- Namespace Kotlin y canal nativo: `com.magicdrive.alert`, conservados para los imports y la telemetría.
- Configuración local: `driveawake/android/app/google-services.json`, copiada del archivo suministrado en la raíz. Ambos archivos están excluidos de Git.
- Kotlin Gradle Plugin actualizado a `2.3.21` para los metadatos Kotlin 2.3 de Firebase Auth; compatible con Gradle 8.12 y AGP 8.9.1 según la [matriz oficial](https://kotlinlang.org/docs/gradle-configure-project.html).
- Firebase Authentication: correo/contraseña habilitados en el proyecto.
- Dominio `magic-tps.github.io` autorizado para la web pública de GitHub Pages desde el 18 de octubre de 2026.
- Cloud Firestore: base `(default)` existente en `nam5`, con reglas publicadas desde `backend/firestore.rules`.
- No se añadieron Analytics ni carga de imágenes, video o frames.

## Uso

Al abrir la app aparece **Iniciar sesión / Crear cuenta** si no hay una sesión guardada. Se puede elegir **Continuar sin cuenta** para usar la cámara y el almacenamiento local. Una sesión guardada entra directamente a Inicio.

Inicio muestra la cuenta conectada y **Subir informes a la nube**, o el acceso a login cuando se usa sin cuenta. Historial ofrece un acceso con texto a la nube. Cada resumen local incluye **Subir informe a la nube**, que selecciona únicamente ese viaje. La confirmación identifica la cuenta destinataria y los datos enviados.

La pantalla de nube muestra el número de informes devuelto por el servidor y la hora de la última consulta correcta. **Comprobar nube** repite esa consulta. La subida solo se anuncia como confirmada después de la respuesta de Firestore; un fallo al consultar no se presenta como una lista vacía. Las copias abiertas desde la nube se identifican expresamente en su resumen.

Las copias se guardan bajo `users/{uid}/reports/{id}`. El ID deriva del identificador y fecha de inicio del viaje, por lo que volver a copiarlo actualiza el mismo documento. La pantalla consulta los últimos 100 informes de la cuenta y permite abrirlos y borrarlos. Para borrar una cuenta y todas sus copias se exige de nuevo la contraseña.

SQLite sigue siendo la fuente local: ni la cámara ni los viajes esperan a Firebase. Firebase se inicializa al abrir la app para restaurar la sesión; se puede continuar sin cuenta mientras se realiza ese intento. La pantalla de nube ofrece un error recuperable si falta configuración o conexión. Las copias requieren conexión; no se descargan al historial SQLite. Borrar el historial local o aplicar su retención no borra las copias remotas, que se conservan hasta eliminarlas expresamente.

El caché persistente de Firestore está deshabilitado. Si vence el tiempo de espera de una escritura, la app informa que la operación puede completarse al recuperar conexión; no anuncia éxito sin confirmación. Volver a copiar un viaje es idempotente.

## Compilación y despliegue

```powershell
Copy-Item google-services.json driveawake/android/app/google-services.json
cd driveawake
flutter pub get
flutter build apk --debug
```

El JSON debe corresponder a `driver_.awaken`. Un checkout público sin ese archivo compila con funciones locales; la pantalla de nube muestra que no pudo conectarse.

Desde la raíz, para publicar las reglas usando una sesión Firebase autorizada:

```powershell
firebase deploy --only firestore:rules --project driverawaken
```

## Validación

- Prueba real de alta con correo, escritura, actualización, lectura, consulta y borrado.
- Rechazo de acceso sin sesión y lectura/escritura/borrado desde otra cuenta.
- Rechazo de campos adicionales y riesgo inválido.
- Las dos cuentas sintéticas y su informe se eliminan al terminar la prueba.
- Pruebas Flutter de serialización, identidad estable, minimización de datos y mensajes de confirmación pendiente.

La prueba remota requiere ejecución explícita: `node scripts/firebase_smoke_test.mjs --live`. No utiliza ni modifica informes del usuario y no envía correos.

Fuentes: [configuración Android](https://firebase.google.com/docs/android/setup), [autenticación Flutter](https://firebase.google.com/docs/auth/flutter/password-auth), [reglas por usuario](https://firebase.google.com/docs/rules/basics), [pruebas REST con tokens de usuario](https://firebase.google.com/docs/firestore/use-rest-api).
