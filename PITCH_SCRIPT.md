# Guion de pitch — máximo tres minutos

**0:00–0:20 · Problema.** En transporte regional de pasajeros y carga, una central necesita saber cuándo un viaje pierde monitoreo y cuándo una señal de fatiga merece atención. Un tramo sin conectividad no debe impedir la alerta al conductor ni borrar lo observado. Esta es la hipótesis de producto; todavía no presentamos entrevistas o adopción verificadas.

**0:20–0:40 · Personas y solución.** DriverAwaken Guardian une al conductor con el operador de una flota. La cámara se procesa en el teléfono; reglas temporales explican cierres oculares, PERCLOS, bostezos e inclinación. La alerta local funciona independientemente de internet. El conductor particular puede seguir usando el modo personal.

**0:40–1:35 · Demo.** Abrir `/demo/`. Señalar el rótulo de datos simulados. Desconectar, simular cierre ocular y mostrar el incidente en cola. Restaurar conexión: el mismo identificador llega a central con sus dos fechas. Reconocer y registrar «Contacto con conductor; recomendación de detenerse en un lugar seguro». Mostrar cómo la acción se añade sin cambiar la detección.

**1:35–2:05 · Ingeniería.** Se amplió una aplicación Flutter existente: SQLite/Drift conserva la cola; Firebase aplica membresías y roles por empresa; Next.js muestra la operación. El fin del viaje remoto espera a los incidentes encolados. Los datos faciales no salen del dispositivo. La demo pública está aislada de producción.

**2:05–2:30 · Evidencia y límites.** Mostrar los resultados concretos de `TECHNICAL_VALIDATION.md`, actualizados tras ejecutar las pruebas. Separar pruebas del motor, persistencia y reglas de la demostración simulada. El modelo TFLite histórico sigue desactivado por incompatibilidad de extracción. No tenemos accuracy independiente, validación física completa ni accidentes evitados que reportar.

**2:30–3:00 · Adopción y siguiente etapa.** Proponemos un piloto consentido con una flota regional: medir falsos positivos, salud del monitoreo, retraso de sincronización y utilidad de la respuesta humana. El modelo de adopción propuesto es suscripción por vehículo activo, con precio aún por validar. Antes del piloto debemos completar pruebas Android y definir responsable de datos, retención y canal de privacidad. Guardian entrega trazabilidad para decidir cuándo intervenir de forma segura.

## Preguntas previsibles

- **¿Es una probabilidad de accidente?** No. El score es heurístico y explica señales observadas.
- **¿Qué pasa sin internet?** Las alarmas son locales y la cola persiste; la central recibe los datos después. No puede observar un dispositivo desconectado en tiempo real.
- **¿Qué se construyó en el evento?** Ver la base Git y la separación en `HACKTHEANDES_2026.md`. El detector y la app personal ya existían.
- **¿Hay evidencia antifraude?** No. Reglas e identidad limitan acceso y estructura, pero un cliente puede falsificar lo que declara observar.
- **¿Existe tracción?** No se han documentado entrevistas, clientes o uso real verificables durante esta implementación.
- **¿Qué aporta Smart Rest?** Consume la decisión del motor existente y el tiempo de conducción. Ante señal crítica aconseja detenerse cuanto antes en un lugar seguro; no espera una consulta a internet. Permite buscar opciones reales con autorización y registrar un descanso declarado.
- **¿De dónde salen los lugares?** OpenStreetMap mediante proveedores separados. Los resultados pueden faltar o estar desactualizados; la app no certifica acceso para buses ni convierte distancias en línea recta en rutas de carretera.
- **¿Cuánto cuesta operar?** El prototipo no activó servicios Google facturables. Firebase, hosting y proveedores de mapas pueden generar consumo según el plan y volumen; todavía no hay un costo por vehículo medido.
- **¿Qué ocurre si falla la cámara?** La app muestra señal insuficiente o monitoreo no disponible, intenta recuperación limitada y conserva la finalización del viaje. No comunica un riesgo bajo a partir de falta de señal.
- **¿Cuál es la precisión?** No tenemos una cifra independiente defendible para conductores nuevos. Las pruebas verifican reglas y contratos; no sustituyen una evaluación con datos representativos.
- **¿Por qué una empresa lo usaría?** La hipótesis es mejorar el contexto y trazabilidad de respuesta ante señales observadas. Falta validar esa utilidad con operadores reales.

## Registro de feedback real

Usar [la plantilla de validación de campo](docs/pilot_feedback_template.md). Mantenerla vacía hasta entrevistar o probar con personas que consientan. No presentar fixtures de emuladores como usuarios o pilotos.
