# Firma release Android

Este proyecto ya esta configurado para firmar builds release si existe:

- `android/key.properties`
- `android/app/magicdrive-release-keystore.jks`

Ambos archivos son secretos locales y estan ignorados por git.

## Generar APK release

```powershell
cd D:\Escritorio\DriveAwake\driveawake
flutter build apk --release
```

Salida esperada:

```powershell
build\app\outputs\flutter-apk\app-release.apk
```

## Generar AAB release para Play Store

```powershell
flutter build appbundle --release
```

Salida esperada:

```powershell
build\app\outputs\bundle\release\app-release.aab
```

## Importante

- Guarda copia segura del keystore y de `android/key.properties`.
- Si pierdes el keystore de carga, no podras actualizar la misma app firmada con
  esa clave sin configurar recuperacion en Google Play.
- Para equipos, comparte el keystore por un canal seguro, nunca por git.

## Plantilla

Si necesitas recrear la configuracion en otra maquina, usa:

```powershell
Copy-Item android\key.properties.example android\key.properties
```

Luego edita los valores reales y coloca el `.jks` en la ruta indicada por
`storeFile`.
