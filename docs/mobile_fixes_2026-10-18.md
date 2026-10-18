# Correcciones móviles — 18 de octubre de 2026

## Actualización 1.1.1+3: permisos antes del viaje y mapa permanente

La entrada normal y la recuperación de viajes pasan por «Antes de salir». La preparación solicita cámara, ubicación y micrófono antes de crear la sesión de conducción; el micrófono es opcional. Sin permiso de cámara no permite iniciar. El botón de inicio permanece fijo abajo y espera a que termine el diálogo y la app esté en primer plano. La vista previa del inicio y la cámara de conducción comprueban el permiso existente sin solicitarlo. Los comandos de voz tampoco abren un diálogo de micrófono durante el viaje si falta autorización.

El controlador invalida un arranque interrumpido durante preparación y espera una inicialización de cámara ya en curso antes de detenerla. Una respuesta tardía no puede volver a activar la sesión que se pausó. La recuperación confirmada desde preparación reanuda con cuenta atrás, siempre que la app no haya pasado a segundo plano durante el arranque.

El mapa ocupa la vista principal; cámara, aviso técnico y controles de pausa ocupan paneles pequeños dentro de ella. La pausa ya no usa una capa negra sobre toda la pantalla. El GPS autorizado se conserva durante la sesión en primer plano, se detiene al salir y se recupera al volver; desactivarlo explícitamente impide esa recuperación automática. Android solicita posiciones cada dos segundos con distancia mínima cero, sujeto a disponibilidad del sistema y precisión de la señal. El mapa oculta el marcador si la posición deja de ser válida. No se implementa seguimiento con la app cerrada.

La tarjeta de mapa permanece montada durante las actualizaciones faciales y conserva su proveedor de tiles. Las mediciones de fluidez en el teléfono deben distinguirse de estas mejoras de implementación.

Las secciones siguientes conservan la comprobación de la versión anterior y su APK; el artefacto 1.1.1+3 reemplaza esa compilación para probar esta actualización.

## Pausa y regreso desde el mapa

El tema de producción establece un ancho mínimo infinito para los botones principales. La pantalla de pausa los colocaba dentro de un `Row` sin limitar ese ancho, provocando errores de diseño. Ahora usa un panel de ancho limitado, botones verticales, área segura y desplazamiento para teléfonos pequeños y modo horizontal. La cámara detenida muestra «Cámara pausada» en lugar de un indicador de inicio permanente.

Al regresar del mapa, una sesión previamente activa reanuda con cuenta atrás. Una pausa manual se conserva. Un descanso declarado abierto también conserva la pausa. Los errores recuperables muestran controles para reintentar. Se impiden aperturas simultáneas de navegación.

El controlador conserva la cuenta atrás mientras recibe actualizaciones de cámara. Las operaciones de pausa y reanudación liberan sus futuros pendientes incluso cuando la petición es redundante, evitando que un segundo ciclo quede inhabilitado.

## Mapa y ubicación

Se retiraron la casilla y el interruptor previos a la activación. «Estoy estacionado · activar mapa y GPS» comunica la confirmación y habilita ambas funciones con una acción, conservando el permiso de Android y la explicación sobre proveedores. Un GPS que ya indica movimiento bloquea la configuración.

El estado `inactive` que Android emite al mostrar permisos ya no cancela la solicitud de GPS. El estado `paused` de segundo plano sigue deteniéndolo. La primera ubicación válida centra el mapa con zoom de calle; las siguientes mantienen el seguimiento y el zoom elegido. Sin ubicación válida no se dibuja un vehículo ficticio. La tarjeta no solicita mapas sin autorización.

## Comandos de voz

En «Alertas / Voz» y en la pantalla de pausa se puede abrir el panel de comandos. «Escuchar comando» activa una escucha breve y muestra su estado. Acepta «abrir mapa», «pausar», «reanudar» y «SOS»/«emergencia». El comando SOS conserva la confirmación del marcador.

El reconocedor usa una sola instancia durante la sesión de la app, selecciona un idioma español que Android ofrezca, procesa solo resultados finales y rechaza negaciones o frases que solo contengan parte de un comando. Cerrar el panel, salir de la pantalla o enviar la app al fondo invalida resultados pendientes y cancela la escucha. Se informa de errores y se permite reintentar. No existe palabra de activación ni escucha permanente.

Se añadió la consulta Android `android.speech.RecognitionService`, además del permiso de micrófono incorporado previamente. Se sustituyeron parámetros obsoletos por `SpeechListenOptions`. Los avisos de privacidad explican que el servicio de Android puede procesar audio por Internet; la app no persiste audio ni transcripciones.

Referencia del paquete: [speech_to_text](https://pub.dev/packages/speech_to_text). La versión usada queda fijada en `driveawake/pubspec.lock`.

## Verificación

- Pruebas con el tema real: pausa/reanudación en 390 × 844 y 740 × 360, sin errores de diseño.
- Prueba de abrir el mapa y retroceder: recupera una sesión activa y conserva una pausa manual.
- Prueba de activación de mapa/GPS y permiso Android simulado: una autorización, ubicación recibida y marcador actualizado.
- Pruebas de ciclos repetidos de pausa/reanudación, cancelación por segundo plano y análisis de comandos, incluidas negaciones.
- `flutter analyze`: sin incidencias.
- Suite completa `flutter test --reporter compact`: 144 pruebas aprobadas y una prueba de red opcional omitida.
- `flutter build apk --profile --target-platform android-arm64`: completado correctamente. Se usa modo perfil para probar una compilación AOT; no se ha medido todavía la fluidez en el celular.
- APK inspeccionado con `aapt`: paquete `driver_.awaken`, permiso `RECORD_AUDIO` presente.

APK local: `driveawake/build/app/outputs/flutter-apk/app-profile.apk`, 91 198 483 bytes. SHA256: `f09176a85ad27ccb379b7ec347a9f518154e0cc27cf43ee229863b0e34cb433c`.

Instalación conservando datos, con el teléfono conectado y autorizado:

```powershell
cd "D:\Escritorio\Apps Potenciales\DriveAwake\driveawake"
adb -s R3CY90SRW1Z install -r ".\build\app\outputs\flutter-apk\app-profile.apk"
adb -s R3CY90SRW1Z shell monkey -p driver_.awaken 1
```

La validación física de cámara, GPS y reconocimiento de voz queda pendiente: durante esta comprobación `adb devices` terminó sin dispositivos conectados. Las pruebas de interfaz utilizan recursos simulados y no demuestran precisión del detector ni rendimiento en el teléfono.
