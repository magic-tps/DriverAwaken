# Despliegue de DriverAwaken Guardian

Estado del 18 de octubre de 2026: la web está publicada en [GitHub Pages](https://magic-tps.github.io/DriverAwaken/) y el [APK universal de prueba](https://github.com/magic-tps/DriverAwaken/releases/tag/v1.1.1-debug.3) está disponible en GitHub Releases. La portada, `/dashboard/`, `/driver/`, `/demo/` y `/pitch/` respondieron HTTP 200; se comprobó la pantalla de acceso de ambos paneles en un navegador. Las reglas Firestore se publicaron en `driverawaken` y `magic-tps.github.io` quedó autorizado en Firebase Auth. No se probaron sesiones reales de administrador/conductor ni entrega push de extremo a extremo. El envío push automático sigue desactivado porque Cloud Functions requiere el plan Blaze; no se cambió la facturación ni se hizo entrega a una competencia.

## Requisitos

Flutter 3.35.3 / Dart 3.9.2 o versión compatible, Android SDK y licencias aceptadas por su propietario; Python 3.11; Node.js 22; Java 21 para el emulador; Firebase CLI (se probó 15.19.1). Las dependencias están fijadas en los lockfiles. No usar credenciales Admin en navegador o APK.

## Web sin Firebase: demo y pitch independientes

Desde la raíz, en PowerShell:

```powershell
cd dashboard
npm.cmd ci
npm.cmd run typecheck
npm.cmd run lint
npm.cmd test
npm.cmd run build
python -m http.server 3000 --bind 127.0.0.1 --directory out
```

Abrir `http://127.0.0.1:3000/demo/` y `/pitch/`. Son direcciones locales, no URLs de entrega. La exportación estática en `dashboard/out/` contiene todos los recursos; no necesita un servidor Next.js. La demo no configura Firebase ni usa datos reales.

## Firebase real: preparación revisable

1. Reutilizar el proyecto Firebase autorizado. Habilitar Auth correo/contraseña y Cloud Firestore. Añadir al dominio autorizado el hosting escogido.
2. Copiar `dashboard/.env.example` a `.env.local` y completar la configuración pública de la aplicación web desde la consola Firebase. No copiar credenciales de servicio. `NEXT_PUBLIC_USE_EMULATORS` debe ser `false` en producción. Volver a compilar después de cambiar variables: se insertan al build.
3. Crear una cuenta del administrador mediante Firebase Auth; obtener su UID. Configurar Application Default Credentials del administrador en el equipo local, fuera del repositorio.
4. Revisar bootstrap sin escritura:

```powershell
cd backend
npm.cmd ci
node scripts/bootstrap.mjs --project=ID_PROYECTO --org=ID_FLOTA --name="NOMBRE_AUTORIZADO" --admin=UID_ADMIN
```

La escritura privilegiada requiere añadir `--apply=true` y contar con autorización. El script verifica la existencia del usuario y se niega a sobrescribir una organización existente. No se ejecutó contra un proyecto real.

5. Publicación web actual: `.github/workflows/pages.yml` exporta `dashboard/` y despliega GitHub Pages desde `main`. La configuración pública de Firebase está en variables del repositorio GitHub; no se guarda una clave de servicio en el código. Las reglas Firestore ya se publicaron. Firebase Hosting se conserva como configuración alternativa, pero el plan Spark bloquea servir archivos `.apk`:

```powershell
firebase deploy --only firestore:rules --project ID_PROYECTO
cd dashboard
npm.cmd run build
cd ..
firebase deploy --only hosting --project ID_PROYECTO
```

`firebase.json` sirve `dashboard/out` si se usa Firebase Hosting y añade cabeceras básicas. El sitio público actual usa GitHub Pages; la descarga Android se aloja en GitHub Releases. Las cuentas y membresías reales siguen siendo necesarias para entrar a los paneles privados.

6. En `/dashboard/settings/`, ADMIN añade membresías usando UIDs de cuentas existentes. En Flota crea vehículos y en Viajes crea un viaje asignado a DRIVER; la asignación al vehículo se escribe antes del viaje. OPERATOR consulta incidentes y anexa acciones.
7. En Android iniciar sesión, abrir «Vincular flota», introducir ID de organización, consultar viajes y otorgar consentimiento explícito. Elegir el viaje antes de iniciar el modo conducción. Probar cámara/señales solamente en entorno estacionario o simulado.

## Emuladores: integración local reproducible sin datos reales

Desde la raíz, con Java 21 en PATH:

```powershell
firebase emulators:start --only "auth,firestore" --project demo-guardian
```

En otra terminal:

```powershell
cd backend
$env:FIRESTORE_EMULATOR_HOST="127.0.0.1:8085"
$env:FIREBASE_AUTH_EMULATOR_HOST="127.0.0.1:9098"
node scripts/seed-emulators.mjs
```

El seed rechaza hosts remotos. Crea la organización ficticia `andes-emulator` y cuentas exclusivas del emulador: `admin@guardian.test`, `operator@guardian.test`, `driver@guardian.test`, contraseña pública de fixture `GuardianDemo2026!`. Nunca usar estas credenciales en producción. El incidente del seed se emite con SDK cliente autenticado como DRIVER y atraviesa las reglas; Admin SDK solo prepara identidades/asignaciones.

Compilar la web con estas variables públicas de emulador en la terminal de dashboard:

```powershell
$env:NEXT_PUBLIC_FIREBASE_API_KEY="demo-guardian-emulator"
$env:NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN="demo-guardian.firebaseapp.com"
$env:NEXT_PUBLIC_FIREBASE_PROJECT_ID="demo-guardian"
$env:NEXT_PUBLIC_FIREBASE_APP_ID="guardian-emulator"
$env:NEXT_PUBLIC_USE_EMULATORS="true"
npm.cmd run build
$env:FIREBASE_E2E="true"
npm.cmd run test:e2e
```

Las pruebas de reglas usan `backend/firebase.test.json`, puerto 8185 y proyecto `demo-guardian-security`, separado del recorrido manual. Ejecutar `npm.cmd run test:emulator` desde `backend` con Java 21 en PATH. Limpian solamente ese proyecto de pruebas. Las pruebas web automatizadas tienen otra configuración aislada en `backend/firebase.web-test.json`; consultar `dashboard/README.md`. No limpiar ni detener un emulador de otro trabajo.

Para Android Emulator:

```powershell
cd driveawake
flutter run --dart-define=GUARDIAN_USE_EMULATORS=true --dart-define=GUARDIAN_EMULATOR_HOST=10.0.2.2
```

No se verificó en dispositivo. Para hardware físico, configurar acceso local al emulador con un host autorizado; nunca exponer sus puertos públicamente.

## Android

```powershell
cd driveawake
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Salida esperada del comando: `driveawake/build/app/outputs/flutter-apk/app-debug.apk`. Consultar `TECHNICAL_VALIDATION.md` para saber si se generó efectivamente. Instalar con `adb install -r RUTA_APK` en equipo de pruebas autorizado. La configuración `google-services.json` de Android permanece ignorada; sin ella funciona el modo personal. No reemplazar el archivo existente. La raíz también contiene configuración local ignorada que no debe publicarse.

Release formal: configurar keystore válido y `android/key.properties` fuera del control de versiones y ejecutar `flutter build apk --release`. No se genera una firma falsa ni se usa la debug para una publicación formal.

## Entrega oficial — solo después de autorización

Se verificó `andes project submit --help`: los cuatro flags siguientes existen. Sustituir ambos marcadores por URLs públicas comprobadas. No ejecutar con marcadores ni sin autorización:

```bash
andes project submit \
  --deployment-url URL_REAL_DEMO \
  --presentation-url URL_REAL_PITCH \
  --github-url https://github.com/magic-tps/DriverAwaken \
  --file ./proyecto.md
```

La CLI usa el nombre de equipo/proyecto registrado. No se cambia ese nombre ni se publica una bitácora sin instrucciones explícitas. En PowerShell puede usarse una única línea en lugar de `\`.
