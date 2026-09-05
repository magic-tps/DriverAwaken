# Fase 1 - Informe de seguridad

Fecha: 2026-07-17

## Problemas corregidos

- PERCLOS ya no conecta muestras separadas por rostro ausente ni huecos mayores
  de 600 ms. Ignora timestamps duplicados o fuera de orden y expone cobertura,
  duracion valida y suficiencia de señal.
- Pausar detiene el stream, procesamiento, telemetria, pantalla activa, audio y
  vibracion; reinicia el estado temporal. Reanudar exige una cuenta regresiva de
  tres segundos y evita streams duplicados.
- `AlertService.stopAllAlerts()` es idempotente e inyectable para pruebas.
- Atras abre un flujo de salida con continuar, finalizar/guardar o descartar con
  segunda confirmacion. Descartar elimina los eventos del viaje.
- Se guarda un borrador incremental y la app ofrece recuperar o descartar una
  sesion incompleta sin encender automaticamente camara o alarmas.
- Release ya no usa firma debug como fallback, habilita R8 y shrink de recursos.
- El modelo y el panel tecnico estan desactivados por defecto. El motor
  experimental no puede elevar una regla debil directamente a peligro.
- El cargador del modelo valida hash, shapes, metadata, probabilidades finitas y
  paridad del extractor. El modelo historico se rechaza de forma segura porque
  su paridad con ML Kit no esta verificada.

## Diseño final de PERCLOS

El tracker integra solamente intervalos entre dos muestras validas,
cronologicas y separadas por un maximo de 600 ms. Una muestra invalida rompe el
segmento. La cobertura se calcula respecto del tiempo observado dentro de la
ventana y se limita a `[0, 1]`. La señal solo queda lista cuando alcanza la
duracion valida y cobertura minimas configuradas.

## Diseño final de pausa

La pausa representa `Pausar monitoreo`. Conserva el borrador y estadisticas de
la sesion, pero deja en cero la actividad de camara y analisis. La sesion
recuperada siempre abre pausada. La reanudacion reinicia trackers antes de
volver a aceptar frames.

## Tests añadidos

- Diez escenarios de PERCLOS, incluidos huecos, cobertura y timestamps.
- Cancelacion idempotente de alertas con actuador falso.
- Serializacion, guardado y eliminacion de borradores.
- Preprocesamiento numerico compartido y metadata incompatible.

## Verificacion

- `dart format lib test`: aprobado.
- `dart analyze lib test`: `No issues found`.
- `flutter test`: 33 pruebas aprobadas tras corregir permisos del cache Flutter
  y registrar los delegates de localizacion espanola.
- `flutter build apk --debug`: aprobado; APK generado en
  `build/app/outputs/flutter-apk/app-debug.apk`.

## Riesgos restantes

- La pausa y recuperacion requieren validacion en dispositivo Android real.
- El borrador usa `SharedPreferences` hasta la migracion transaccional futura.
- El modelo historico permanece inutilizable intencionalmente hasta conseguir
  paridad de features y reentrenamiento por sujeto.
- R8 debe validarse con un build release firmado real; no se crean credenciales.
