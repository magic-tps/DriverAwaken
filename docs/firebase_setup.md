# Firebase: cuentas y copias de informes

## Configuración implementada

- Proyecto: `driverawaken`.
- Application ID Android: `driver_.awaken`, elegido por el propietario. Android instala esta variante como otra app; los datos de `com.magicdrive.alert` no se migran automáticamente.
- Namespace Kotlin y canal nativo: `com.magicdrive.alert`, conservados para los imports y la telemetría.
- Configuración local: `driveawake/android/app/google-services.json`, copiada del archivo suministrado en la raíz. Ambos archivos están excluidos de Git.
- Kotlin Gradle Plugin actualizado a `2.3.21` para los metadatos Kotlin 2.3 de Firebase Auth; compatible con Gradle 8.12 y AGP 8.9.1 según la [matriz oficial](https://kotlinlang.org/docs/gradle-configure-project.html).
- Firebase Authentication: correo/contraseña habilitados en el proyecto.
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
