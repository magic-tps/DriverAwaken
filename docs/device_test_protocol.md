# Protocolo de prueba prolongada por dispositivo

## Seguridad y preparación

Todas las pruebas son estacionarias. Coloca el vehículo apagado y estacionado, o usa una habitación estable; nunca ejecutes el protocolo mientras conduces. Monta el teléfono como se usaría normalmente, conecta `adb`, desactiva optimizaciones que cierren la app y registra la temperatura ambiente aproximada.

Compila la variante técnica:

```bash
cd driveawake
flutter pub get
flutter build apk --debug --dart-define=DRIVERAWAKE_TECHNICAL_FEATURES=true
flutter install --debug
```

Inicia una sesión nueva, confirma que el panel técnico muestre FPS, P95, drops, temperatura y salud, y registra batería/temperatura inicial. No compartas reportes sin revisar el JSON y confirmar el diálogo.

## Matriz de pruebas

### Prueba 1 — 30 minutos estable

- Rostro visible y centrado.
- Luz estable, pantalla encendida y sin interacción.
- Esperado: salud `healthy`; se admite `degraded` solo con motivo técnico explicable.
- Fallo crítico: `NORMAL` visible cuando no llegan frames válidos.

### Prueba 2 — 30 minutos con interrupciones

- Pausa y reanudación manual.
- Enviar a background y volver; comprobar que no se reactive sola.
- Bloquear/desbloquear pantalla.
- Cambiar orientación.
- Simular una llamada cuando el dispositivo/laboratorio lo permita.
- Esperado: alarmas detenidas en pausa/recuperación, reanudación explícita y un único stream.

### Prueba 3 — Baja iluminación

- Reducir y restaurar la luz de forma gradual y controlada.
- No simular conducción peligrosa ni forzar somnolencia.
- Esperado: señal insuficiente o salud degradada claramente indicada; nunca normal falso.

### Prueba 4 — Cámara parcialmente obstruida

- Cubrir parcialmente la cámara sin mover el dispositivo.
- Mantener la obstrucción hasta observar `degraded` o `unavailable`.
- Esperado: mensaje de precisión reducida o `MONITOREO NO DISPONIBLE`; no mostrar `NORMAL`.
- Retirar la obstrucción y confirmar recuperación con frames válidos antes de volver a `healthy`.

### Prueba 5 — Sesión prolongada

- Duración inicial: 90–120 minutos.
- Registrar cada 15 minutos batería, temperatura, memoria disponible cuando la API sea confiable, FPS, P95 y drops.
- Esperado: memoria sin crecimiento continuo atribuible a métricas, intentos de recuperación limitados y posibilidad de finalizar siempre.

## Registro por ejecución

| Campo | Valor |
|---|---|
| Fecha/hora | |
| Fabricante | |
| Modelo | |
| Android | |
| RAM | |
| Estado de carga inicial/final | |
| Temperatura ambiente aproximada | |
| Prueba y duración | |
| Resultado (aprobado/fallido) | |
| Errores observados | |
| P95 total máximo | |
| Frames recibidos/procesados | |
| Frames descartados y porcentaje | |
| Consumo de batería | |
| Temperatura máxima | |
| Reinicios/recuperaciones | |
| Archivo de reporte revisado | |

## Criterios de interrupción

Detén la prueba si el dispositivo supera el límite térmico recomendado por su fabricante, se deforma la batería, la aplicación interfiere con llamadas de emergencia o el equipo presenta comportamiento inseguro. `unavailable` no impide finalizar el viaje: usa `FINALIZAR VIAJE` y conserva el reporte solo si no contiene información sensible.

## Evidencia y cierre

1. Finaliza normalmente desde la app.
2. Abre el panel técnico y anota contadores/P95.
3. Si la variante técnica ofrece exportación, confirma manualmente y comparte solo con el canal de pruebas autorizado.
4. Verifica que no quede `driverawake-technical-*.json` en temporales después de compartir.
5. Adjunta el registro anterior y anota modelo exacto, Android, versión de app y condiciones de reproducción.
