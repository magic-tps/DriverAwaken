# Demo para jurado — recorrido de 90 segundos

Abrir `/demo/` en el sitio publicado, o `http://127.0.0.1:3000/demo/` después de los comandos de `DEPLOYMENT.md`. La dirección local no es una URL pública. Mantener visible «DEMO — DATOS SIMULADOS». Flota, conductor, vehículo y ruta son ficticios. No se usa la cuenta del desarrollador.

1. **0–15 s:** «Reiniciar demostración», elegir un destino simulado e «Iniciar viaje simulado». Pulsar «Simular conducción normal». Identificar viaje activo, monitoreo y central conectada.
2. **15–30 s:** «Simular pérdida de conectividad» y «Simular cierre ocular prolongado». Mostrar que se crea el incidente y permanece pendiente en el dispositivo simulado.
3. **30–45 s:** «Restaurar conectividad». El mismo ID llega a la central; observar detección frente a recepción y el retraso.
4. **45–65 s:** Seleccionar el incidente recibido, «Reconocer incidente», escribir una nota operativa y «Registrar acción». El timeline conserva la detección original y anexa la intervención humana.
5. **65–90 s:** Mostrar Smart Rest y una parada ficticia. Confirmar voluntariamente el descanso simulado, iniciarlo y terminarlo. «Finalizar escenario» muestra el resumen de incidentes, acciones, descansos y pendientes. Abrir `/pitch/` desde la navegación pública.

También funcionan «Simular precaución» y el reinicio completo. La persistencia de la demo utiliza almacenamiento del navegador. Reiniciar elimina solo su propia clave de demo. Si el navegador bloquea almacenamiento, la interfaz debe informar el límite y conservar la sesión en memoria.

## Qué demuestra

Un recorrido navegable determinista con reloj lógico, cola simulada, reintentos idempotentes, estado operativo y acciones. No accede a Firestore, no ejecuta ML Kit ni mide rendimiento facial. No demuestra detección en personas ni accidentes evitados.

## Recorrido integrado local

`DEPLOYMENT.md` incluye el seed de emuladores y el dashboard autenticado con datos ficticios emitidos mediante SDK DRIVER contra las reglas reales. Esto verifica integración Firebase local, por separado del simulador. No sustituye la prueba física Android → Firestore → dashboard.

## Antes de presentar

- Abrir demo y pitch en una ventana privada del equipo que presentará.
- Revisar que no haya dependencias de localhost, cuenta personal o variables privadas.
- Mantener el lenguaje preventivo: se observan señales y se recomienda una parada segura; no se afirma detectar o evitar accidentes.
- Si todavía no se publicó, seguir `DEPLOYMENT.md` después de autorización. No entregar un enlace local.
