# Proceso de release (pendiente de credenciales)

El build `release` requiere `driveawake/android/key.properties` y un keystore externo al repositorio. CI debe reconstruir ambos desde secretos protegidos, compilar el AAB/APK sin fallback debug, calcular SHA-256 y publicar junto con versión de app, versión/hash del modelo y notas.

Antes de habilitar un workflow de publicación deben definirse propietario de firma, rotación, entorno protegido, aprobación manual y destino. No se incluyen valores ficticios. La validación local mínima es:

```text
flutter test
flutter build appbundle --release
sha256sum build/app/outputs/bundle/release/app-release.aab
```

Una release no debe continuar si falta metadata del modelo, el hash no coincide o aparece cualquier archivo de firma en `git ls-files`.
